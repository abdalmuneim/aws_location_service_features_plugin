package com.devmnem.aws_location_service_features

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Bridges `MethodChannelAwsLocation` (Dart) to [CloudTracking], which wraps
 * the Amazon Location Mobile Auth and Tracking SDKs.
 *
 * Maps, Places and Routes need no native code: the Dart side calls those
 * REST APIs directly on every platform.
 */
class AwsLocationServiceFeaturesPlugin :
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var tracking: CloudTracking

    private val main = Handler(Looper.getMainLooper())
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    @Volatile
    private var sink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        tracking = CloudTracking(binding.applicationContext, scope, ::emit)
        methodChannel = MethodChannel(binding.binaryMessenger, "aws_location_service_features/tracking")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "aws_location_service_features/tracking/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        tracking.dispose()
        scope.cancel()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun emit(event: Map<String, Any?>) {
        main.post { sink?.success(event) }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()
        when (call.method) {
            "configure" -> async(result) { tracking.configure(args) }
            "start" -> sync(result) { tracking.start() }
            "stop" -> sync(result) { tracking.stop() }
            "startBackground" -> sync(result) { tracking.startBackground(args["mode"] as? String ?: "active") }
            "stopBackground" -> sync(result) { tracking.stopBackground() }
            "isTracking" -> sync(result) { tracking.isTracking() }
            "latestPosition" -> async(result) { tracking.latestPosition() }
            "positionHistory" -> async(result) { tracking.positionHistory(args) }
            else -> result.notImplemented()
        }
    }

    private fun sync(result: Result, block: () -> Any?) {
        try {
            result.success(block().takeUnless { it == Unit })
        } catch (e: Exception) {
            fail(result, e)
        }
    }

    private fun async(result: Result, block: suspend () -> Any?) {
        scope.launch {
            try {
                result.success(block())
            } catch (e: Exception) {
                fail(result, e)
            }
        }
    }

    private fun fail(result: Result, e: Exception) {
        when (e) {
            is PluginError -> result.error(e.code, e.message, null)
            else -> result.error("PLATFORM_ERROR", CloudTracking.rootMessage(e), null)
        }
    }
}
