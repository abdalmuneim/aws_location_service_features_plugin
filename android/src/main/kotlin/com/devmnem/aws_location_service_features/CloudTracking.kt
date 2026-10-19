package com.devmnem.aws_location_service_features

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.content.ContextCompat
import aws.sdk.kotlin.services.location.LocationClient
import aws.sdk.kotlin.services.location.model.AccessDeniedException
import aws.sdk.kotlin.services.location.model.DevicePosition
import aws.sdk.kotlin.services.location.model.GetDevicePositionHistoryRequest
import aws.sdk.kotlin.services.location.model.GetDevicePositionRequest
import aws.sdk.kotlin.services.location.model.ResourceNotFoundException
import aws.smithy.kotlin.runtime.time.Instant
import aws.smithy.kotlin.runtime.time.epochMilliseconds
import aws.smithy.kotlin.runtime.time.fromEpochMilliseconds
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import software.amazon.location.auth.AuthHelper
import software.amazon.location.auth.LocationCredentialsProvider
import software.amazon.location.tracking.LocationTracker
import software.amazon.location.tracking.aws.LocationTrackingCallback
import software.amazon.location.tracking.config.LocationTrackerConfig
import software.amazon.location.tracking.config.NotificationConfig
import software.amazon.location.tracking.database.LocationEntry
import software.amazon.location.tracking.filters.AccuracyLocationFilter
import software.amazon.location.tracking.filters.DistanceLocationFilter
import software.amazon.location.tracking.filters.LocationFilter
import software.amazon.location.tracking.filters.TimeLocationFilter
import software.amazon.location.tracking.providers.BackgroundLocationService
import software.amazon.location.tracking.providers.BackgroundTrackingWorker
import software.amazon.location.tracking.providers.DeviceIdProvider
import software.amazon.location.tracking.util.BackgroundTrackingMode
import software.amazon.location.tracking.util.ServiceCallback
import software.amazon.location.tracking.util.TrackingSdkLogLevel

/** An error reported to Dart as a PlatformException with [code]. */
internal class PluginError(val code: String, message: String?) : Exception(message)

/**
 * Cloud tracking with the Amazon Location Mobile Auth and Tracking SDKs:
 * Cognito credentials from [AuthHelper], positions uploaded by
 * [LocationTracker] (foreground) or its BackgroundLocationService /
 * WorkManager job (background).
 *
 * All public methods are called on the main thread. [emit] receives event
 * maps and is safe to call from any thread.
 */
internal class CloudTracking(
    private val context: Context,
    private val scope: CoroutineScope,
    private val emit: (Map<String, Any?>) -> Unit,
) {
    private val main = Handler(Looper.getMainLooper())

    private var provider: LocationCredentialsProvider? = null
    private var trackerConfig: LocationTrackerConfig? = null
    private var filters: List<LocationFilter> = emptyList()
    private var tracker: LocationTracker? = null
    private var trackerName: String = ""
    private var foreground = false
    private var watchdog: Job? = null
    private var lastRebuild = 0L
    private var rebuildPending = false

    init {
        SdkCrashGuard.install()
    }

    suspend fun configure(args: Map<*, *>): String {
        val poolId = args["identityPoolId"] as? String
        val name = args["trackerName"] as? String
        if (poolId.isNullOrBlank() || name.isNullOrBlank()) {
            throw PluginError("INVALID_ARGUMENTS", "identityPoolId and trackerName are required.")
        }
        val region = (args["region"] as? String) ?: poolId.substringBefore(':')
        stopForeground()

        val credentials = try {
            AuthHelper.withCognitoIdentityPool(poolId, region, context)
        } catch (e: Exception) {
            throw PluginError("AUTH_FAILED", rootMessage(e))
        }

        val timeMillis = (args["timeFilterMillis"] as? Number)?.toLong()
        val distance = (args["distanceFilterMeters"] as? Number)?.toDouble()
        val accuracy = args["accuracyFilter"] == true
        filters = buildList {
            if (timeMillis != null) add(TimeLocationFilter(timeMillis))
            if (distance != null) add(DistanceLocationFilter(distance))
            if (accuracy) add(AccuracyLocationFilter())
        }

        val notification = args["notification"] as? Map<*, *>
        val defaults = NotificationConfig()
        val iconName = notification?.get("iconName") as? String
        val iconId = iconName
            ?.let { context.resources.getIdentifier(it, "drawable", context.packageName) }
            ?.takeIf { it != 0 }
            ?: defaults.notificationImageId

        trackerConfig = LocationTrackerConfig(
            trackerName = name,
            locationFilters = filters.toMutableList(),
            logLevel = TrackingSdkLogLevel.ERROR,
            persistentNotificationConfig = NotificationConfig(
                notificationChannelName = (notification?.get("channelName") as? String)
                    ?: defaults.notificationChannelName,
                notificationTitle = (notification?.get("title") as? String)
                    ?: defaults.notificationTitle,
                notificationDescription = (notification?.get("description") as? String)
                    ?: defaults.notificationDescription,
                notificationImageId = iconId,
            ),
        )
        provider = credentials
        trackerName = name
        buildTracker()
        return deviceId()
    }

    fun deviceId(): String = DeviceIdProvider.getInstance(context).getDeviceID()

    fun start() {
        val tracker = requireTracker()
        requireLocationPermission()
        if (foreground) return
        startForegroundUpdates(tracker)
        foreground = true
        startWatchdog()
    }

    fun stop() = stopForeground()

    fun startBackground(mode: String) {
        val tracker = requireTracker()
        requireLocationPermission()
        val sdkMode = when (mode) {
            "batterySaver" -> BackgroundTrackingMode.BATTERY_SAVER_TRACKING
            else -> BackgroundTrackingMode.ACTIVE_TRACKING
        }
        tracker.startBackground(
            sdkMode,
            object : ServiceCallback {
                override fun serviceStopped() {
                    emit(event("backgroundStopped"))
                }
            },
        )
    }

    fun stopBackground() {
        tracker?.stopBackgroundService()
            ?: run {
                // Not configured in this process, but the service may still
                // run from an earlier launch.
                context.stopService(
                    android.content.Intent(context, BackgroundLocationService::class.java),
                )
                if (BackgroundTrackingWorker.isWorkRunning(context)) {
                    BackgroundTrackingWorker.cancelWork(context)
                }
            }
    }

    fun isTracking(): Boolean =
        foreground ||
            BackgroundLocationService.isRunning ||
            BackgroundTrackingWorker.isWorkRunning(context)

    suspend fun latestPosition(): Map<String, Any?>? = withClient { client ->
        try {
            val response = client.getDevicePosition(
                GetDevicePositionRequest {
                    trackerName = this@CloudTracking.trackerName
                    deviceId = deviceId()
                },
            )
            positionMap(
                lng = response.position[0],
                lat = response.position[1],
                sampleTime = response.sampleTime.epochMilliseconds,
                receivedTime = response.receivedTime.epochMilliseconds,
                accuracy = response.accuracy?.horizontal,
                deviceId = response.deviceId,
            )
        } catch (e: ResourceNotFoundException) {
            null
        }
    }

    suspend fun positionHistory(args: Map<*, *>): List<Map<String, Any?>> = withClient { client ->
        val from = (args["from"] as? Number)?.toLong()
        val to = (args["to"] as? Number)?.toLong()
        val max = (args["maxResults"] as? Number)?.toInt()
        val out = mutableListOf<Map<String, Any?>>()
        var next: String? = null
        do {
            val remaining = if (max == null) 100 else max - out.size
            val response = client.getDevicePositionHistory(
                GetDevicePositionHistoryRequest {
                    trackerName = this@CloudTracking.trackerName
                    deviceId = deviceId()
                    startTimeInclusive = from?.let { Instant.fromEpochMilliseconds(it) }
                    endTimeExclusive = to?.let { Instant.fromEpochMilliseconds(it) }
                    maxResults = remaining.coerceIn(1, 100)
                    nextToken = next
                },
            )
            response.devicePositions.forEach { out += it.toMap() }
            next = response.nextToken
        } while (next != null && (max == null || out.size < max))
        out
    }

    /** Called when the engine goes away: the foreground callback dies with it. */
    fun dispose() {
        stopForeground()
        SdkCrashGuard.listener = null
    }

    // ---- internals

    private fun requireTracker(): LocationTracker =
        tracker ?: throw PluginError("NOT_CONFIGURED", "Call configure before using the tracker.")

    private fun requireLocationPermission() {
        val granted = listOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        ).any { ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED }
        if (!granted) throw PluginError("PERMISSION_DENIED", "Location permission is not granted.")
    }

    private fun buildTracker() {
        val provider = provider ?: return
        val config = trackerConfig ?: return
        val tracker = LocationTracker(context, provider, config.copy(locationFilters = filters.toMutableList()))
        // The SDK only applies filters that are switched on.
        listOf(TimeLocationFilter(), DistanceLocationFilter(), AccuracyLocationFilter()).forEach { kind ->
            val enabled = filters.firstOrNull { it::class == kind::class }
            if (enabled != null) tracker.enableFilter(enabled) else tracker.disableFilter(kind)
        }
        this.tracker = tracker
        SdkCrashGuard.listener = ::onSdkFailure
    }

    @SuppressLint("MissingPermission") // Checked by requireLocationPermission.
    private fun startForegroundUpdates(tracker: LocationTracker) {
        tracker.start(callback)
    }

    @SuppressLint("MissingPermission")
    private fun stopForeground() {
        if (foreground) {
            try {
                tracker?.stop()
            } catch (e: Exception) {
                Log.w(TAG, "stop failed", e)
            }
        }
        foreground = false
        watchdog?.cancel()
        watchdog = null
    }

    /** Refreshes expired Cognito credentials while foreground tracking runs. */
    private fun startWatchdog() {
        watchdog?.cancel()
        watchdog = scope.launch {
            while (isActive) {
                delay(60_000)
                if (foreground && !credentialsValid()) rebuild("credentials expired")
            }
        }
    }

    private fun credentialsValid(): Boolean = try {
        provider?.isCredentialsValid() ?: false
    } catch (e: Exception) {
        false
    }

    /**
     * The SDK's own coroutine scope dies after an upload fails for good, and
     * its client keeps the credentials it was created with. A new tracker
     * fixes both; queued positions stay in the SDK's database.
     */
    private fun rebuild(reason: String) {
        scope.launch {
            val wasForeground = foreground
            stopForeground()
            try {
                if (!credentialsValid()) provider?.verifyAndRefreshCredentials()
                buildTracker()
                if (wasForeground) start()
            } catch (e: Exception) {
                emit(event("error", "message" to "Could not restart tracking ($reason): ${rootMessage(e)}"))
            }
        }
    }

    private fun onSdkFailure(error: Throwable) {
        emit(event("error", "message" to rootMessage(error)))
        main.post {
            if (rebuildPending) return@post
            rebuildPending = true
            // At most one rebuild per 30 s, so being offline doesn't spin.
            val wait = (lastRebuild + 30_000 - System.currentTimeMillis()).coerceAtLeast(1_000)
            main.postDelayed({
                rebuildPending = false
                lastRebuild = System.currentTimeMillis()
                if (foreground) rebuild("upload failed")
            }, wait)
        }
    }

    private suspend fun <T> withClient(block: suspend (LocationClient) -> T): T {
        val provider = provider ?: throw PluginError("NOT_CONFIGURED", "Call configure before using the tracker.")
        if (!credentialsValid()) {
            try {
                provider.verifyAndRefreshCredentials()
            } catch (e: Exception) {
                throw PluginError("AUTH_FAILED", rootMessage(e))
            }
        }
        return try {
            LocationClient(provider.getLocationClientConfig()).use { block(it) }
        } catch (e: AccessDeniedException) {
            throw PluginError("ACCESS_DENIED", e.message)
        } catch (e: PluginError) {
            throw e
        } catch (e: Exception) {
            throw PluginError("PLATFORM_ERROR", rootMessage(e))
        }
    }

    private val callback = object : LocationTrackingCallback {
        override fun onLocationReceived(location: LocationEntry) {
            emit(event("position", "position" to location.toMap()))
        }

        override fun onUploadStarted(entries: List<LocationEntry>) {
            emit(event("uploadStarted", "positions" to entries.map { it.toMap() }))
        }

        override fun onUploaded(entries: List<LocationEntry>) {
            emit(event("uploaded", "positions" to entries.map { it.toMap() }))
        }

        override fun onUploadSkipped(entries: LocationEntry) {
            emit(event("uploadSkipped", "position" to entries.toMap()))
        }

        override fun onLocationAvailabilityChanged(locationAvailable: Boolean) {
            emit(event("availability", "available" to locationAvailable))
        }
    }

    private fun LocationEntry.toMap(): Map<String, Any?> = positionMap(
        lng = longitude,
        lat = latitude,
        sampleTime = time,
        receivedTime = null,
        accuracy = accuracy.toDouble().takeIf { it > 0 },
        deviceId = null,
    )

    private fun DevicePosition.toMap(): Map<String, Any?> = positionMap(
        lng = position[0],
        lat = position[1],
        sampleTime = sampleTime.epochMilliseconds,
        receivedTime = receivedTime.epochMilliseconds,
        accuracy = accuracy?.horizontal,
        deviceId = deviceId,
    )

    companion object {
        private const val TAG = "AwsLocationService"

        fun event(type: String, vararg fields: Pair<String, Any?>): Map<String, Any?> =
            mapOf("type" to type, "time" to System.currentTimeMillis(), *fields)

        fun positionMap(
            lng: Double,
            lat: Double,
            sampleTime: Long,
            receivedTime: Long?,
            accuracy: Double?,
            deviceId: String?,
        ): Map<String, Any?> = mapOf(
            "latitude" to lat,
            "longitude" to lng,
            "sampleTime" to sampleTime,
            "receivedTime" to receivedTime,
            "accuracy" to accuracy,
            "deviceId" to deviceId,
        )

        fun rootMessage(e: Throwable): String {
            var current: Throwable = e
            while (current.cause != null && current.cause !== current) current = current.cause!!
            return current.message ?: e.message ?: e.javaClass.simpleName
        }
    }
}

/**
 * The Tracking SDK uploads from a coroutine scope without an exception
 * handler, so an upload that still fails after its retries (offline,
 * AccessDenied) would crash the app. This handler intercepts only such
 * failures: thrown on a coroutine worker thread by the AWS SDK or the
 * Amazon Location SDKs. Everything else goes to the previous handler.
 */
internal object SdkCrashGuard {
    @Volatile
    var listener: ((Throwable) -> Unit)? = null

    @Volatile
    private var installed = false

    fun install() {
        if (installed) return
        synchronized(this) {
            if (installed) return
            val previous = Thread.getDefaultUncaughtExceptionHandler()
            Thread.setDefaultUncaughtExceptionHandler { thread, error ->
                val handler = listener
                if (handler != null && thread.name.startsWith("DefaultDispatcher") && isSdkError(error)) {
                    Log.w("AwsLocationService", "Tracking SDK error intercepted", error)
                    handler(error)
                } else if (previous != null) {
                    previous.uncaughtException(thread, error)
                } else {
                    throw error
                }
            }
            installed = true
        }
    }

    private val sdkPackages = listOf("software.amazon.location.", "aws.sdk.kotlin.", "aws.smithy.kotlin.")

    private fun isSdkError(error: Throwable): Boolean =
        generateSequence(error) { it.cause.takeIf { cause -> cause !== it } }.any { t ->
            sdkPackages.any { t.javaClass.name.startsWith(it) } ||
                t.stackTrace.any { frame -> sdkPackages.any { frame.className.startsWith(it) } }
        }
}
