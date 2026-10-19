#if canImport(AmazonLocationiOSTrackingSDK)
  import AWSLocation
  import AmazonLocationiOSAuthSDK
  import AmazonLocationiOSTrackingSDK
  import CoreLocation
  import Flutter
  import Foundation

  /// An error reported to Dart as a PlatformException with `code`.
  struct PluginError: Error {
    let code: String
    let message: String
  }

  /// Cloud tracking with the Amazon Location Mobile Auth and Tracking SDKs:
  /// Cognito credentials from `AuthHelper`, positions uploaded by
  /// `LocationTracker`.
  ///
  /// The SDK's tracker signs with the credentials it was created with, so
  /// this class re-creates it whenever the identity pool provider has
  /// refreshed them (about once an hour). Queued positions survive in the
  /// SDK's Core Data store.
  ///
  /// Used on the main thread only: Flutter calls `handle` there and every
  /// async continuation hops back with `Task { @MainActor in ... }`.
  final class CloudTracking {
    private let emit: ([String: Any]) -> Void

    private var identityPoolId: String?
    private var region: String?
    private var trackerName: String?
    private var trackerConfig: LocationTrackerConfig?

    private var cognito: AmazonLocationCognitoCredentialsProvider?
    private var authHelper: AuthHelper?
    private var tracker: LocationTracker?
    private var trackerExpiry: Date?

    private var foreground = false
    private var backgroundMode: BackgroundTrackingMode?
    private var timer: Timer?
    private var lastPositionTime: Date?
    private var rebuilding = false

    init(emit: @escaping ([String: Any]) -> Void) {
      self.emit = emit
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let args = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "configure": run(result) { try await self.configure(args) }
      case "start":
        runSync(result) {
          try self.start()
          return nil
        }
      case "stop":
        runSync(result) {
          self.stop()
          return nil
        }
      case "startBackground":
        runSync(result) {
          try self.startBackground(args["mode"] as? String ?? "active")
          return nil
        }
      case "stopBackground":
        runSync(result) {
          self.stopBackground()
          return nil
        }
      case "isTracking": runSync(result) { self.foreground || self.backgroundMode != nil }
      case "latestPosition": run(result) { try await self.latestPosition() }
      case "positionHistory": run(result) { try await self.positionHistory(args) }
      default: result(FlutterMethodNotImplemented)
      }
    }

    // MARK: - Calls

    private func configure(_ args: [String: Any]) async throws -> String {
      guard let poolId = args["identityPoolId"] as? String, !poolId.isEmpty,
        let name = args["trackerName"] as? String, !name.isEmpty
      else {
        throw PluginError(
          code: "INVALID_ARGUMENTS", message: "identityPoolId and trackerName are required.")
      }
      stopEverything()
      let region =
        args["region"] as? String ?? String(poolId.split(separator: ":").first ?? "")

      let timeMillis = (args["timeFilterMillis"] as? NSNumber)?.doubleValue
      let distance = (args["distanceFilterMeters"] as? NSNumber)?.doubleValue
      let accuracy = args["accuracyFilter"] as? Bool ?? false
      var filters: [LocationFilter] = []
      if timeMillis != nil { filters.append(TimeLocationFilter()) }
      if distance != nil { filters.append(DistanceLocationFilter()) }
      if accuracy { filters.append(AccuracyLocationFilter()) }

      // Fresh credentials; the provider then refreshes itself a minute
      // before they expire and stores them in the keychain.
      let cognito = AmazonLocationCognitoCredentialsProvider(
        identityPoolId: poolId, region: region)
      do {
        try await cognito.refreshCognitoCredentials()
      } catch {
        throw PluginError(code: "AUTH_FAILED", message: error.localizedDescription)
      }
      guard cognito.getCognitoCredentials() != nil else {
        throw PluginError(code: "AUTH_FAILED", message: "Cognito returned no credentials.")
      }

      self.identityPoolId = poolId
      self.region = region
      self.trackerName = name
      self.cognito = cognito
      self.trackerConfig = LocationTrackerConfig(
        locationFilters: filters,
        // Also the location manager's distance filter, so 0 when off.
        trackingDistanceInterval: distance ?? 0,
        trackingTimeInterval: timeMillis.map { $0 / 1000 })
      try await buildTracker()
      return tracker?.getDeviceId() ?? ""
    }

    private func start() throws {
      let tracker = try requireTracker()
      do {
        try tracker.startTracking()
      } catch TrackingLocationError.permissionDenied {
        throw PluginError(code: "PERMISSION_DENIED", message: "Location permission denied.")
      }
      foreground = true
      startTimer()
    }

    private func stop() {
      foreground = false
      // Background tracking shares the same location subscription.
      if backgroundMode == nil {
        tracker?.stopTracking()
        stopTimer()
      }
    }

    private func startBackground(_ mode: String) throws {
      let tracker = try requireTracker()
      let sdkMode: BackgroundTrackingMode = mode == "batterySaver" ? .BatterySaving : .Active
      do {
        try tracker.startBackgroundTracking(mode: sdkMode)
      } catch TrackingLocationError.permissionDenied {
        throw PluginError(code: "PERMISSION_DENIED", message: "Location permission denied.")
      }
      backgroundMode = sdkMode
      startTimer()
    }

    private func stopBackground() {
      guard backgroundMode != nil else { return }
      tracker?.stopBackgroundTracking()
      backgroundMode = nil
      emit(Self.event("backgroundStopped"))
      if foreground {
        try? tracker?.startTracking()
      } else {
        stopTimer()
      }
    }

    private func latestPosition() async throws -> [String: Any]? {
      let (client, deviceId, name) = try clientContext()
      do {
        let output = try await client.getDevicePosition(
          input: GetDevicePositionInput(deviceId: deviceId, trackerName: name))
        let position: [Double]? = output.position
        let sampleTime: Date? = output.sampleTime
        let receivedTime: Date? = output.receivedTime
        let accuracy: LocationClientTypes.PositionalAccuracy? = output.accuracy
        let outputDeviceId: String? = output.deviceId
        return Self.positionMap(
          position: position, sampleTime: sampleTime, receivedTime: receivedTime,
          accuracy: accuracy?.horizontal, deviceId: outputDeviceId)
      } catch is AWSLocation.ResourceNotFoundException {
        return nil
      } catch {
        throw Self.mapAwsError(error)
      }
    }

    private func positionHistory(_ args: [String: Any]) async throws -> [[String: Any]] {
      let (client, deviceId, name) = try clientContext()
      let from = (args["from"] as? NSNumber).map { Self.date($0) }
      let to = (args["to"] as? NSNumber).map { Self.date($0) }
      let max = (args["maxResults"] as? NSNumber)?.intValue
      var out: [[String: Any]] = []
      var next: String?
      do {
        repeat {
          let remaining = max.map { $0 - out.count } ?? 100
          let output = try await client.getDevicePositionHistory(
            input: GetDevicePositionHistoryInput(
              deviceId: deviceId,
              endTimeExclusive: to,
              maxResults: Swift.max(1, Swift.min(100, remaining)),
              nextToken: next,
              startTimeInclusive: from,
              trackerName: name))
          let positions: [LocationClientTypes.DevicePosition]? = output.devicePositions
          for p in positions ?? [] {
            let position: [Double]? = p.position
            let sampleTime: Date? = p.sampleTime
            let receivedTime: Date? = p.receivedTime
            let accuracy: LocationClientTypes.PositionalAccuracy? = p.accuracy
            let positionDeviceId: String? = p.deviceId
            if let map = Self.positionMap(
              position: position, sampleTime: sampleTime, receivedTime: receivedTime,
              accuracy: accuracy?.horizontal, deviceId: positionDeviceId)
            {
              out.append(map)
            }
          }
          next = output.nextToken
        } while next != nil && (max == nil || out.count < max!)
      } catch {
        throw Self.mapAwsError(error)
      }
      return out
    }

    // MARK: - Tracker lifecycle

    private func requireTracker() throws -> LocationTracker {
      guard let tracker = tracker else {
        throw PluginError(code: "NOT_CONFIGURED", message: "Call configure before using the tracker.")
      }
      return tracker
    }

    private func clientContext() throws -> (LocationClient, String, String) {
      guard let authHelper = authHelper, let tracker = tracker, let name = trackerName,
        let deviceId = tracker.getDeviceId()
      else {
        throw PluginError(code: "NOT_CONFIGURED", message: "Call configure before using the tracker.")
      }
      return (LocationClient(config: authHelper.getLocationClientConfig()), deviceId, name)
    }

    private func buildTracker() async throws {
      guard let poolId = identityPoolId, let region = region, let name = trackerName else {
        throw PluginError(code: "NOT_CONFIGURED", message: "Call configure before using the tracker.")
      }
      let helper: AuthHelper
      do {
        helper = try await AuthHelper.withIdentityPoolId(identityPoolId: poolId, region: region)
      } catch {
        throw PluginError(code: "AUTH_FAILED", message: error.localizedDescription)
      }
      tracker = try LocationTracker(authHelper: helper, trackerName: name, config: trackerConfig)
      authHelper = helper
      trackerExpiry = cognito?.getCognitoCredentials()?.expiration
    }

    /// Re-creates the tracker once newer credentials exist (or the current
    /// ones are about to expire), then resumes what was running.
    private func refreshIfNeeded() {
      guard !rebuilding, let expiry = trackerExpiry else { return }
      let latest = cognito?.getCognitoCredentials()?.expiration
      let refreshed = latest.map { $0 > expiry } ?? false
      guard refreshed || Date().addingTimeInterval(30) >= expiry else { return }
      rebuilding = true
      let wasForeground = foreground
      let mode = backgroundMode
      Task { @MainActor in
        defer { self.rebuilding = false }
        if !refreshed { try? await self.cognito?.refreshCognitoCredentials() }
        self.tracker?.stopBackgroundTracking()
        self.tracker?.stopTracking()
        do {
          try await self.buildTracker()
          if let mode = mode {
            try self.tracker?.startBackgroundTracking(mode: mode)
          } else if wasForeground {
            try self.tracker?.startTracking()
          }
        } catch {
          self.emit(
            Self.event("error", ["message": "Could not refresh credentials: \(error.localizedDescription)"]))
        }
      }
    }

    private func stopEverything() {
      tracker?.stopBackgroundTracking()
      tracker?.stopTracking()
      foreground = false
      backgroundMode = nil
      stopTimer()
    }

    /// The iOS SDK has no callbacks, so poll the last position it accepted
    /// for upload, and check the credentials while at it.
    private func startTimer() {
      guard timer == nil else { return }
      timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
        Task { @MainActor in self?.tick() }
      }
    }

    private func stopTimer() {
      timer?.invalidate()
      timer = nil
    }

    private var ticks = 0

    private func tick() {
      if let entity = tracker?.getDeviceLocation(), let time = entity.timestamp,
        time != lastPositionTime
      {
        lastPositionTime = time
        if let map = Self.positionMap(
          position: [entity.longitude, entity.latitude], sampleTime: time, receivedTime: nil,
          accuracy: entity.accuracy > 0 ? entity.accuracy : nil, deviceId: nil)
        {
          emit(Self.event("position", ["position": map]))
        }
      }
      ticks += 1
      if ticks % 30 == 0 { refreshIfNeeded() }
    }

    // MARK: - Helpers

    private func run(_ result: @escaping FlutterResult, _ body: @escaping () async throws -> Any?) {
      Task { @MainActor in
        do {
          result(try await body())
        } catch {
          result(Self.flutterError(error))
        }
      }
    }

    private func runSync(_ result: @escaping FlutterResult, _ body: () throws -> Any?) {
      do {
        result(try body())
      } catch {
        result(Self.flutterError(error))
      }
    }

    private static func flutterError(_ error: Error) -> FlutterError {
      if let e = error as? PluginError {
        return FlutterError(code: e.code, message: e.message, details: nil)
      }
      return FlutterError(code: "PLATFORM_ERROR", message: error.localizedDescription, details: nil)
    }

    private static func mapAwsError(_ error: Error) -> Error {
      if error is PluginError { return error }
      if error is AWSLocation.AccessDeniedException {
        return PluginError(code: "ACCESS_DENIED", message: "\(error)")
      }
      return PluginError(code: "PLATFORM_ERROR", message: "\(error)")
    }

    private static func event(_ type: String, _ fields: [String: Any] = [:]) -> [String: Any] {
      var map = fields
      map["type"] = type
      map["time"] = millis(Date())
      return map
    }

    private static func positionMap(
      position: [Double]?, sampleTime: Date?, receivedTime: Date?, accuracy: Double?,
      deviceId: String?
    ) -> [String: Any]? {
      guard let position = position, position.count >= 2, let sampleTime = sampleTime else {
        return nil
      }
      var map: [String: Any] = [
        "longitude": position[0],
        "latitude": position[1],
        "sampleTime": millis(sampleTime),
      ]
      if let receivedTime = receivedTime { map["receivedTime"] = millis(receivedTime) }
      if let accuracy = accuracy { map["accuracy"] = accuracy }
      if let deviceId = deviceId { map["deviceId"] = deviceId }
      return map
    }

    private static func millis(_ date: Date) -> Int64 {
      Int64((date.timeIntervalSince1970 * 1000).rounded())
    }

    private static func date(_ millis: NSNumber) -> Date {
      Date(timeIntervalSince1970: millis.doubleValue / 1000)
    }
  }
#endif
