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
  private let METHOD_HANDLE_PUSH = "handlePush"

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
          klaviyo.set(pushToken: Data(hexString: tokenData))
          result("Token sent to Klaviyo")

        case METHOD_UPDATE_PROFILE:
          let arguments = call.arguments as! [String: Any]
          let profile = Profile(
            email: arguments["email"] as? String,
            phoneNumber: arguments["phone_number"] as? String,
            externalId: arguments["external_id"] as? String,
            firstName: arguments["first_name"] as? String,
            lastName: arguments["last_name"] as? String,
            location: Profile.Location(
                address1: arguments["address1"] as? String,
                latitude: (arguments["latitude"] as? String)?.toDouble,
                longitude: (arguments["latitude"] as? String)?.toDouble,
                region: arguments["region"] as? String)
            )
          klaviyo.set(profile: profile)
          result("Profile updated")

        case METHOD_LOG_EVENT:
          let arguments = call.arguments as! [String: Any]
          let event = Event(
            name: Event.EventName.CustomEvent(arguments["name"] as! String),
            properties: arguments["metaData"] as? [String: Any])

          klaviyo.create(event: event)
          result("Event [\(event.uniqueId)] created")

        case METHOD_HANDLE_PUSH:
          let arguments = call.arguments as! [String: Any]

          if let properties = arguments["message"] as? [String: Any],
            let _ = properties["_k"] {
              klaviyo.create(event: Event(name: .OpenedPush, properties: properties, profile: [:]))

              return result(true)
          }
          result(false)

        default:
          result(FlutterMethodNotImplemented)
    }
  }
}

extension String {
    var toDouble: Double {
        return Double(self) ?? 0.0
    }
}

extension Data {
    init(hexString: String) {
        self = hexString
            .dropFirst(hexString.hasPrefix("0x") ? 2 : 0)
            .compactMap { $0.hexDigitValue.map { UInt8($0) } }
            .reduce(into: (data: Data(capacity: hexString.count / 2), byte: nil as UInt8?)) { partialResult, nibble in
                if let p = partialResult.byte {
                    partialResult.data.append(p + nibble)
                    partialResult.byte = nil
                } else {
                    partialResult.byte = nibble << 4
                }
            }.data
    }
}
