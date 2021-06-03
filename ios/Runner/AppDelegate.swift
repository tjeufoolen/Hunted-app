import UIKit
import Flutter
import GoogleMaps

// import header
#import "FlutterConfigPlugin.h"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NSString *googleMapsApiKey = [FlutterConfigPlugin envFor:@"GOOGLE_MAPS_API_KEY"];
    GMSServices.proveAPIKey(googleMapsApiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
