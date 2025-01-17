import Flutter
import UIKit
import MMKV
import home_widget

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      // my code
      let appGroupId = "group.com.josecollazzi.counter_mmkv_g"
          
          // Get the App Group directory
      guard let groupDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?.path else {
            fatalError("Failed to get App Group directory for ID \(appGroupId)")
      }
          
          // Initialize MMKV with the group directory
      //MMKV.initialize(rootDir: groupDir)
      MMKV.initialize(rootDir: groupDir, logLevel: .info)
      
      if #available(iOS 17, *) {
       HomeWidgetBackgroundWorker.setPluginRegistrantCallback { registry in
           GeneratedPluginRegistrant.register(with: registry)
       }
      }
      //
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
