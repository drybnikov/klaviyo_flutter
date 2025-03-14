package com.rightbite.denisr

import android.app.Application
import android.content.Context
import com.klaviyo.analytics.Klaviyo
import com.klaviyo.analytics.model.Event
import com.klaviyo.analytics.model.EventKey
import com.klaviyo.analytics.model.EventMetric
import com.klaviyo.analytics.model.Profile
import com.klaviyo.analytics.model.ProfileKey
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.Serializable

private const val METHOD_UPDATE_PROFILE = "updateProfile"
private const val METHOD_INITIALIZE = "initialize"
private const val METHOD_SEND_TOKEN = "sendTokenToKlaviyo"
private const val METHOD_LOG_EVENT = "logEvent"
private const val METHOD_HANDLE_PUSH = "handlePush"
private const val METHOD_SET_EXTERNAL_ID = "setExternalId"
private const val METHOD_GET_EXTERNAL_ID = "getExternalId"
private const val METHOD_RESET_PROFILE = "resetProfile"
private const val METHOD_SET_EMAIL = "setEmail"
private const val METHOD_GET_EMAIL = "getEmail"
private const val METHOD_SET_PHONE_NUMBER = "setPhoneNumber"
private const val METHOD_GET_PHONE_NUMBER = "getPhoneNumber"
private const val METHOD_SET_FIRST_NAME = "setFirstName"
private const val METHOD_SET_LAST_NAME = "setLastName"
private const val METHOD_SET_ORGANIZATION = "setOrganization"
private const val METHOD_SET_TITLE = "setTitle"
private const val METHOD_SET_IMAGE = "setImage"
private const val METHOD_SET_ADDRESS1 = "setAddress1"
private const val METHOD_SET_ADDRESS2 = "setAddress2"
private const val METHOD_SET_CITY = "setCity"
private const val METHOD_SET_COUNTRY = "setCountry"
private const val METHOD_SET_LATITUDE = "setLatitude"
private const val METHOD_SET_LONGITUDE = "setLongitude"
private const val METHOD_SET_REGION = "setRegion"
private const val METHOD_SET_ZIP = "setZip"
private const val METHOD_SET_TIMEZONE = "setTimezone"
private const val METHOD_SET_CUSTOM_ATTRIBUTE = "setCustomAttribute"

private const val PROFILE_PROPERTIES_KEY = "properties"

private const val TAG = "KlaviyoFlutterPlugin"

class KlaviyoFlutterPlugin : MethodCallHandler, FlutterPlugin {
    private var applicationContext: Context? = null
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        applicationContext = null
        channel.setMethodCallHandler(null)
    }



    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        fun setProfileAttribute(key: ProfileKey, name: String, argumentKey: String) {
            try {
                val value: String = call.argument<String>(argumentKey)
                    ?: return result.error("Bad Request", "$name should not be null", null)
                Klaviyo.setProfileAttribute(
                    propertyKey = key,
                    value = value,
                )
                Log.i(TAG, "$name updated")
                return result.success("$name updated")
            } catch (e: Exception) {
                return result.error("Set profile attribute error", e.message, e)
            }

        }

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
                try {
                    val profilePropertiesRaw = call.arguments<Map<String, Any>?>()
                            ?: throw RuntimeException("Profile properties not exist")

                    var profileProperties = convertMapToSeralizedMap(profilePropertiesRaw)

                    val customProperties =
                            profileProperties[PROFILE_PROPERTIES_KEY] as Map<String, Serializable>?

                    if (customProperties != null) {
                        // as Android Klaviyo SDK requests properties to be on same Map level
                        // we should unwrap properties
                        profileProperties = profileProperties.minus(PROFILE_PROPERTIES_KEY)
                        profileProperties = profileProperties.plus(customProperties)
                    }

                    val profile = Profile(
                            profileProperties.map { (key, value) ->
                                ProfileKey.CUSTOM(key) to value
                            }.toMap()
                    )

                    Klaviyo.setProfile(profile)
                    Log.d(
                            TAG,
                            "Profile updated: ${Klaviyo.getExternalId()}, profileMap: $profileProperties"
                    )


                    result.success("Profile updated")
                } catch (e: Exception) {
                    result.error("Profile update error", e.message, e)
                }
            }

            METHOD_LOG_EVENT -> {
                val eventName = call.argument<String>("name")
                val metaDataRaw = call.argument<Map<String, Any>?>("metaData")

                if (eventName != null && metaDataRaw != null) {
                    val event = Event(EventMetric.CUSTOM(eventName))

                    val metaData = convertMapToSeralizedMap(metaDataRaw)
                    for (item in metaData) {
                        event.setProperty(EventKey.CUSTOM(item.key), value = item.value)
                    }
                    Klaviyo.createEvent(event)

                    Log.d(TAG, "Event created: $event, metric: ${event.metric}, value:${event.value} eventMap: ${event.toMap()}")
                    result.success("Event[$eventName] created with metadataMap: $metaData")
                }
            }

            METHOD_HANDLE_PUSH -> {
                val metaData =
                        call.argument<HashMap<String, String>>("message") ?: emptyMap<String, String>()

                if (isKlaviyoPush(metaData)) {
                    val event = Event(EventMetric.CUSTOM("\$opened_push"), metaData.mapKeys {
                        EventKey.CUSTOM(it.key)
                    })
                    return try {
                        Klaviyo.getPushToken()?.let { event[EventKey.CUSTOM("push_token")] = it }

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

            METHOD_SET_EXTERNAL_ID -> {
                val id: String = call.argument<String>("id")
                    ?: return result.error("Bad Request", "ID should not be null", null)
                Klaviyo.setExternalId(id)
                return result.success(null)
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

            METHOD_SET_FIRST_NAME -> {
                setProfileAttribute(ProfileKey.FIRST_NAME, "First name", "firstName")
            }

            METHOD_SET_LAST_NAME -> {
                setProfileAttribute(ProfileKey.LAST_NAME, "Last name", "lastName")
            }

            METHOD_SET_ORGANIZATION -> {
                setProfileAttribute(ProfileKey.ORGANIZATION, "Organization", "organization")
            }

            METHOD_SET_TITLE -> {
                setProfileAttribute(ProfileKey.TITLE, "Title", "title")
            }

            METHOD_SET_IMAGE -> {
                setProfileAttribute(ProfileKey.IMAGE, "Image", "image")
            }

            METHOD_SET_ADDRESS1 -> {
                setProfileAttribute(ProfileKey.ADDRESS1, "Address 1", "address")
            }

            METHOD_SET_ADDRESS2 -> {
                setProfileAttribute(ProfileKey.ADDRESS2, "Address 2", "address")
            }

            METHOD_SET_CITY -> {
                setProfileAttribute(ProfileKey.CITY, "City", "city")
            }

            METHOD_SET_COUNTRY -> {
                setProfileAttribute(ProfileKey.COUNTRY, "Country", "country")
            }

            METHOD_SET_LATITUDE -> {
                setProfileAttribute(ProfileKey.LATITUDE, "Latitude", "latitude")
            }

            METHOD_SET_LONGITUDE -> {
                setProfileAttribute(ProfileKey.LONGITUDE, "Longitude", "longitude")
            }

            METHOD_SET_REGION -> {
                setProfileAttribute(ProfileKey.REGION, "Region", "region")
            }

            METHOD_SET_ZIP -> {
                setProfileAttribute(ProfileKey.ZIP, "Zip", "zip")
            }

            METHOD_SET_TIMEZONE -> {
                setProfileAttribute(ProfileKey.TIMEZONE, "Timezone", "timezone")
            }

            METHOD_SET_CUSTOM_ATTRIBUTE -> {
                val key: String = call.argument<String>("key")
                    ?: return result.error("Bad Request", "Key must not be null", null)
                val value: String = call.argument<String>("value")
                    ?: return result.error("Bad Request", "Value must not be null", null)
                Klaviyo.setProfileAttribute(propertyKey = ProfileKey.CUSTOM(key), value)
                return result.success("Attribute '$key' updated")
            }


            else -> result.notImplemented()
        }
    }

    private fun isKlaviyoPush(payload: Map<String, String>) = payload.containsKey("_k")

    companion object {
        private const val CHANNEL_NAME = "com.rightbite.denisr/klaviyo"
    }
}

private fun convertMapToSeralizedMap(map: Map<String, Any>): Map<String, Serializable> {
    val convertedMap = mutableMapOf<String, Serializable>()

    for ((key, value) in map) {
        if (value is Serializable) {
            convertedMap[key] = value
        } else {
            // Handle non-serializable values here if needed
            // For example, you could skip them or throw an exception
            // depending on your requirements.
        }
    }

    return convertedMap
}