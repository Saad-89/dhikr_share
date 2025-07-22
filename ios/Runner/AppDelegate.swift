import UIKit
import Flutter
import AudioToolbox
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // CRITICAL: Initialize Firebase first
    FirebaseApp.configure()
    
    // Enable Firebase Auth debugging (optional - remove in production)
    #if DEBUG
    FirebaseConfiguration.shared.setLoggerLevel(.debug)
    #endif
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let hapticChannel = FlutterMethodChannel(name: "haptic_feedback", binaryMessenger: controller.binaryMessenger)
    
    hapticChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      // Debug logging
      print("iOS: Haptic method called: \(call.method)")
      
      // Check if device supports haptic feedback
      if #available(iOS 10.0, *) {
        switch call.method {
        case "lightImpact":
          DispatchQueue.main.async {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            print("iOS: Light impact triggered")
          }
          result(nil)
          
        case "mediumImpact":
          DispatchQueue.main.async {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            print("iOS: Medium impact triggered")
          }
          result(nil)
          
        case "heavyImpact":
          DispatchQueue.main.async {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            print("iOS: Heavy impact triggered")
          }
          result(nil)
          
        case "selectionChanged":
          DispatchQueue.main.async {
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.prepare()
            selectionFeedback.selectionChanged()
            print("iOS: Selection changed triggered")
          }
          result(nil)
          
        case "notificationSuccess":
          DispatchQueue.main.async {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(.success)
            print("iOS: Notification success triggered")
          }
          result(nil)
          
        case "notificationWarning":
          DispatchQueue.main.async {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(.warning)
            print("iOS: Notification warning triggered")
          }
          result(nil)
          
        case "notificationError":
          DispatchQueue.main.async {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(.error)
            print("iOS: Notification error triggered")
          }
          result(nil)
          
        case "vibrate":
          DispatchQueue.main.async {
            // Fallback vibration using system sound
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            print("iOS: System vibrate triggered")
          }
          result(nil)
          
        default:
          print("iOS: Method not implemented: \(call.method)")
          result(FlutterMethodNotImplemented)
        }
      } else {
        // Fallback for older iOS versions
        print("iOS: Haptic feedback not available, using system vibrate")
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        result(nil)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


// import UIKit
// import Flutter
// import AudioToolbox

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
  
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
    
//     let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
//     let hapticChannel = FlutterMethodChannel(name: "haptic_feedback", binaryMessenger: controller.binaryMessenger)
    
//     hapticChannel.setMethodCallHandler({
//       (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
//       // Debug logging
//       print("iOS: Haptic method called: \(call.method)")
      
//       // Check if device supports haptic feedback
//       if #available(iOS 10.0, *) {
//         switch call.method {
//         case "lightImpact":
//           DispatchQueue.main.async {
//             let impactFeedback = UIImpactFeedbackGenerator(style: .light)
//             impactFeedback.prepare()
//             impactFeedback.impactOccurred()
//             print("iOS: Light impact triggered")
//           }
//           result(nil)
          
//         case "mediumImpact":
//           DispatchQueue.main.async {
//             let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
//             impactFeedback.prepare()
//             impactFeedback.impactOccurred()
//             print("iOS: Medium impact triggered")
//           }
//           result(nil)
          
//         case "heavyImpact":
//           DispatchQueue.main.async {
//             let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
//             impactFeedback.prepare()
//             impactFeedback.impactOccurred()
//             print("iOS: Heavy impact triggered")
//           }
//           result(nil)
          
//         case "selectionChanged":
//           DispatchQueue.main.async {
//             let selectionFeedback = UISelectionFeedbackGenerator()
//             selectionFeedback.prepare()
//             selectionFeedback.selectionChanged()
//             print("iOS: Selection changed triggered")
//           }
//           result(nil)
          
//         case "notificationSuccess":
//           DispatchQueue.main.async {
//             let notificationFeedback = UINotificationFeedbackGenerator()
//             notificationFeedback.prepare()
//             notificationFeedback.notificationOccurred(.success)
//             print("iOS: Notification success triggered")
//           }
//           result(nil)
          
//         case "notificationWarning":
//           DispatchQueue.main.async {
//             let notificationFeedback = UINotificationFeedbackGenerator()
//             notificationFeedback.prepare()
//             notificationFeedback.notificationOccurred(.warning)
//             print("iOS: Notification warning triggered")
//           }
//           result(nil)
          
//         case "notificationError":
//           DispatchQueue.main.async {
//             let notificationFeedback = UINotificationFeedbackGenerator()
//             notificationFeedback.prepare()
//             notificationFeedback.notificationOccurred(.error)
//             print("iOS: Notification error triggered")
//           }
//           result(nil)
          
//         case "vibrate":
//           DispatchQueue.main.async {
//             // Fallback vibration using system sound
//             AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//             print("iOS: System vibrate triggered")
//           }
//           result(nil)
          
//         default:
//           print("iOS: Method not implemented: \(call.method)")
//           result(FlutterMethodNotImplemented)
//         }
//       } else {
//         // Fallback for older iOS versions
//         print("iOS: Haptic feedback not available, using system vibrate")
//         AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//         result(nil)
//       }
//     })
    
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

