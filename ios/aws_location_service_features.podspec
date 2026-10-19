#
# CocoaPods fallback. The Amazon Location Mobile SDKs and the AWS SDK for
# Swift ship through Swift Package Manager only, so with CocoaPods the plugin
# builds without them: Maps, Places, Routes and geofencing work (they are pure
# Dart), and cloud tracking reports UNSUPPORTED. Use Swift Package Manager
# (`flutter config --enable-swift-package-manager`) for cloud tracking.
#
Pod::Spec.new do |s|
  s.name             = 'aws_location_service_features'
  s.version          = '0.1.0'
  s.summary          = 'Amazon Location Service for Flutter.'
  s.description      = <<-DESC
Maps, Places, Routes, geofencing and device tracking with Amazon Location Service.
                       DESC
  s.homepage         = 'https://aws.amazon.com/location/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'aws_location_service_features authors' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'aws_location_service_features/Sources/aws_location_service_features/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.resource_bundles = {'aws_location_service_features_privacy' => ['aws_location_service_features/Sources/aws_location_service_features/PrivacyInfo.xcprivacy']}
end
