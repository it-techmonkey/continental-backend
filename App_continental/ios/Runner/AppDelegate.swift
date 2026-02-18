import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register plugins first
    GeneratedPluginRegistrant.register(with: self)
    
    // Then provide the API key
    GMSServices.provideAPIKey("AIzaSyAg1QBIXXbGLiNO26G6GvHQwmdJJ0usUV0")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
