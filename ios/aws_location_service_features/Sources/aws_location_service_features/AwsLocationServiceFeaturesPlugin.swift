import Flutter
import UIKit

/// Bridges `MethodChannelAwsLocation` (Dart) to `CloudTracking`, which wraps
/// the Amazon Location Mobile Auth and Tracking SDKs.
///
/// Maps, Places and Routes need no native code: the Dart side calls those
/// REST APIs directly on every platform.
public class AwsLocationServiceFeaturesPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  #if canImport(AmazonLocationiOSTrackingSDK)
    private lazy var tracking = CloudTracking { [weak self] event in
      DispatchQueue.main.async { self?.eventSink?(event) }
    }
  #endif

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AwsLocationServiceFeaturesPlugin()
    let channel = FlutterMethodChannel(
      name: "aws_location_service_features/tracking", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
    let events = FlutterEventChannel(
      name: "aws_location_service_features/tracking/events", binaryMessenger: registrar.messenger())
    events.setStreamHandler(instance)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    #if canImport(AmazonLocationiOSTrackingSDK)
      tracking.handle(call, result: result)
    #else
      if call.method == "isTracking" {
        result(false)
      } else {
        result(
          FlutterError(
            code: "SDK_UNAVAILABLE",
            message:
              "Cloud tracking needs the Amazon Location SDKs, which are only available through "
              + "Swift Package Manager. Enable it with `flutter config --enable-swift-package-manager`.",
            details: nil))
      }
    #endif
  }
}
