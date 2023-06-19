package com.rightbite.denisr

import android.app.Application
import android.content.Context
import com.klaviyo.analytics.Klaviyo
import com.klaviyo.analytics.model.Event
import com.klaviyo.analytics.model.EventKey
import com.klaviyo.analytics.model.EventType
import com.klaviyo.analytics.model.Profile
import com.klaviyo.analytics.model.ProfileKey
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

private const val METHOD_UPDATE_PROFILE = "updateProfile"
private const val METHOD_INITIALIZE = "initialize"
private const val METHOD_SEND_TOKEN = "sendTokenToKlaviyo"
private const val METHOD_LOG_EVENT = "logEvent"
private const val METHOD_HANDLE_PUSH = "handlePush"
private const val METHOD_GET_EXTERNAL_ID = "getExternalId"
private const val METHOD_RESET_PROFILE = "resetProfile"
private const val METHOD_SET_EMAIL = "setEmail"
private const val METHOD_GET_EMAIL = "getEmail"
private const val METHOD_SET_PHONE_NUMBER = "setPhoneNumber"
private const val METHOD_GET_PHONE_NUMBER = "getPhoneNumber"

private const val TAG = "KlaviyoFlutterPlugin"

class KlaviyoFlutterPlugin : MethodCallHandler, FlutterPlugin {
    private var applicationContext: Context? = null
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        if (applicationContext is Application) {
            val app = applicationContext as Application
            app.registerActivityLifecycleCallbacks(Klaviyo.lifecycleCallbacks)
        } else {
            Log.w(
                TAG,
                "Context $applicationContext was not an application, can't register for lifecycle callbacks. Some notification events may be dropped as a result."
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        applicationContext = null
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_INITIALIZE -> {
                val apiKey = call.argument<String>("apiKey")
                Klaviyo.initialize(apiKey!!, applicationContext!!)
                Log.d(TAG, "initialized apiKey: $apiKey")
                result.success("Klaviyo initialized")
            }

            METHOD_SEND_TOKEN -> {
                val pushToken = call.argument<String>("token")
                if (pushToken != null) {
                    Klaviyo.setPushToken(pushToken)

                    result.success("Token sent to Klaviyo")
                }
            }

            METHOD_UPDATE_PROFILE -> {
                call.arguments<HashMap<String, String>>()?.let { profileMap ->
                    val profile = Profile(
                        profileMap.map { (key, value) ->
                            ProfileKey.CUSTOM(key) to value
                        }.toMap()
                    )

                    Klaviyo.setProfile(profile)
                    Log.d(
                        TAG,
                        "Profile updated: ${Klaviyo.getExternalId()}, profileMap: $profileMap"
                    )
                }

                result.success("Profile updated")
            }

            METHOD_LOG_EVENT -> {
                val eventName = call.argument<String>("name")
                val metaData = call.argument<HashMap<String, String>>("metaData")
                if (eventName != null) {
                    val event = Event(EventType.CUSTOM(eventName))

                    metaData?.let { metaDataMap ->
                        for (item in metaDataMap) {
                            event.setProperty(key = item.key, value = item.value)
                        }
                    }
                    Klaviyo.createEvent(event)
                    result.success("Event[$eventName] created with metadata size: ${metaData?.size}")
                }
            }

            METHOD_HANDLE_PUSH -> {
                val metaData =
                    call.argument<HashMap<String, String>>("message") ?: emptyMap<String, String>()
                if (Klaviyo.isKlaviyoPush(metaData)) {
                    val event = Event(EventType.OPENED_PUSH, metaData.mapKeys {
                        EventKey.CUSTOM(it.key)
                    })
                    return try {
                        Klaviyo.getPushToken()?.let { event[EventKey.PUSH_TOKEN] = it }

                        Klaviyo.createEvent(event)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(
                            TAG, "Failed handle push metaData:$metaData. Cause: $e"
                        )
                        result.error("Failed handle push metaData", e.message, null)
                    }
                } else {
                    return result.success(false)
                }
            }

            METHOD_GET_EXTERNAL_ID -> result.success(Klaviyo.getExternalId())

            METHOD_RESET_PROFILE -> {
                Klaviyo.resetProfile()
                result.success(true)
            }

            METHOD_GET_EMAIL -> result.success(Klaviyo.getEmail())
            METHOD_GET_PHONE_NUMBER -> result.success(Klaviyo.getPhoneNumber())

            METHOD_SET_EMAIL -> {
                call.argument<String>("email")?.let { newEmail ->
                    Klaviyo.setEmail(newEmail)
                    result.success("Email updated")
                }
            }

            METHOD_SET_PHONE_NUMBER -> {
                call.argument<String>("phoneNumber")?.let { newPhone ->
                    Klaviyo.setPhoneNumber(newPhone)
                    result.success("Phone number updated")
                }
            }

            else -> result.notImplemented()
        }
    }

    companion object {
        private const val CHANNEL_NAME = "com.rightbite.denisr/klaviyo"
    }
}
