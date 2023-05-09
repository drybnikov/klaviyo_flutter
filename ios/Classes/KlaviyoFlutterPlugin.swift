import UIKit
import Flutter
import KlaviyoSwift

/// A class that receives and handles calls from Flutter to complete the payment.
public class KlaviyoFlutterPlugin: NSObject, FlutterPlugin {
  private static let methodChannelName = "com.rightbite.denisr/klaviyo"
    
  private let METHOD_UPDATE_PROFILE = "updateProfile"
  private let METHOD_INITIALIZE = "initialize"
  private let METHOD_SEND_TOKEN = "sendTokenToKlaviyo"
  private let METHOD_LOG_EVENT = "logEvent"
  
  private let klaviyo = KlaviyoSDK()
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: messenger)
    registrar.addMethodCallDelegate(KlaviyoFlutterPlugin(), channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case METHOD_INITIALIZE:
          let arguments = call.arguments as! [String: Any]
          klaviyo.initialize(with: arguments["apiKey"] as! String)
          result("Klaviyo initialized")
        
        case METHOD_SEND_TOKEN:
          let arguments = call.arguments as! [String: Any]
          let tokenData = arguments["token"] as! String
          klaviyo.set(pushToken: Data(tokenData.utf8))
          result("Token sent to Klaviyo")
        
        case METHOD_UPDATE_PROFILE:
          let arguments = call.arguments as! [String: Any]
          let profile = Profile(
            email: (arguments["email"] as! String),
            firstName: arguments["firstName"] as? String,
            lastName: arguments["lastName"] as? String)
          klaviyo.set(profile: profile)
          result("Profile updated")

        case METHOD_LOG_EVENT:
          let arguments = call.arguments as! [String: Any]
          let event = Event(
            name: Event.EventName.CustomEvent(arguments["name"] as! String),
            properties: arguments["metaData"] as? [String: Any])
        
          klaviyo.create(event: event)
          result("Event [\(event.uniqueId)] created")

        default:
          result(FlutterMethodNotImplemented)
    }
  }
}
