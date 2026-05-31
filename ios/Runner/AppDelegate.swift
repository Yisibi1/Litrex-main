import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // iOS Screen Security Logic (App Switcher Obscuring) - DISABLED DUE TO CRASHES
  // private var secureField: UITextField?

  // override func applicationWillResignActive(_ application: UIApplication) {
  //   if secureField == nil {
  //       secureField = UITextField()
  //       secureField?.isSecureTextEntry = true
  //       self.window?.addSubview(secureField!)
  //       self.window?.layer.superlayer?.addSublayer(secureField!.layer)
  //       secureField?.layer.sublayers?.last?.addSublayer(self.window!.layer)
  //   }
  // }

  // override func applicationDidBecomeActive(_ application: UIApplication) {
  //   secureField?.removeFromSuperview()
  //   secureField = nil
  // }
}
