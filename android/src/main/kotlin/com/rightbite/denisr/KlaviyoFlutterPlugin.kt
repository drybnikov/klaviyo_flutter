package com.rightbite.denisr

import android.content.Context
import androidx.annotation.VisibleForTesting
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
private const val METHOD_SET_BADGE_COUNT = "setBadgeCount"

private const val PROFILE_PROPERTIES_KEY = "properties"

// Maps standard profile keys to their Kotlin object suffix names.
// We need reflection because the underlying ProfileKey objects are marked `internal`.
private val PROFILE_KEY_CLASS_SUFFIX =
    mapOf(
        "external_id" to "EXTERNAL_ID",
        "email" to "EMAIL",
        "phone_number" to "PHONE_NUMBER",
        "first_name" to "FIRST_NAME",
        "last_name" to "LAST_NAME",
        "organization" to "ORGANIZATION",
        "title" to "TITLE",
        "image" to "IMAGE",
        "address1" to "ADDRESS1",
        "address2" to "ADDRESS2",
        "city" to "CITY",
        "country" to "COUNTRY",
        "region" to "REGION",
        "zip" to "ZIP",
        "timezone" to "TIMEZONE",
        "latitude" to "LATITUDE",
        "longitude" to "LONGITUDE",
    )

private val profileKeyCache = mutableMapOf<String, ProfileKey?>()

private const val TAG = "KlaviyoFlutterPlugin"

class KlaviyoFlutterPlugin :
    MethodCallHandler,
    FlutterPlugin {
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

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        fun setProfileAttribute(
            key: ProfileKey,
            name: String,
            argumentKey: String,
        ) {
            try {
                val value: String =
                    call.argument<String>(argumentKey)
                        ?: return result.error("Bad Request", "$name should not be null", null)
                Klaviyo.setProfileAttribute(
                    propertyKey = key,
                    value = value,
                )
                logInfo("$name updated")
                return result.success("$name updated")
            } catch (e: Exception) {
                return result.error("Set profile attribute error", e.message, e)
            }
        }

        when (call.method) {
            METHOD_INITIALIZE -> {
                val apiKey = call.argument<String>("apiKey")
                Klaviyo.initialize(apiKey!!, applicationContext!!)
                logDebug("initialized apiKey: $apiKey")
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
                    val profilePropertiesRaw =
                        call.arguments<Map<String, Any>?>()
                            ?: throw RuntimeException("Profile properties not exist")

                    val serializedProperties = convertMapToSeralizedMap(profilePropertiesRaw)
                    val profileAttributes = buildProfileAttributes(serializedProperties)

                    val profile = Profile(profileAttributes)

                    Klaviyo.setProfile(profile)
                    logDebug("Profile updated: ${Klaviyo.getExternalId()}, profileMap: $serializedProperties")

                    result.success("Profile updated")
                } catch (e: Exception) {
                    result.error("Profile update error", e.message, e)
                }
            }

            METHOD_LOG_EVENT -> {
                val eventName =
                    call.argument<String>("name")
                        ?: return result.error("Bad Request", "Event name should not be null", null)
                val metaDataRaw = call.argument<Map<String, Any>?>("metaData")

                val event = Event(EventMetric.CUSTOM(eventName))

                if (metaDataRaw != null) {
                    val metaData = convertMapToSeralizedMap(metaDataRaw)
                    metaData.forEach { (key, value) ->
                        event.setProperty(EventKey.CUSTOM(key), value = value)
                    }
                }

                Klaviyo.createEvent(event)

                val metadataKeys = metaDataRaw?.keys?.joinToString(prefix = "[", postfix = "]")
                logDebug("Event created for '$eventName' with metadata keys $metadataKeys")
                result.success("Event[$eventName] created")
            }

            METHOD_HANDLE_PUSH -> {
                val metaData =
                    call.argument<HashMap<String, String>>("message") ?: emptyMap<String, String>()

                if (isKlaviyoPush(metaData)) {
                    val event =
                        Event(
                            EventMetric.CUSTOM("\$opened_push"),
                            metaData.mapKeys {
                                EventKey.CUSTOM(it.key)
                            },
                        )
                    return try {
                        Klaviyo.getPushToken()?.let { event[EventKey.CUSTOM("push_token")] = it }

                        Klaviyo.createEvent(event)
                        result.success(true)
                    } catch (e: Exception) {
                        logError("Failed handle push metaData:$metaData", e)
                        result.error("Failed handle push metaData", e.message, null)
                    }
                } else {
                    return result.success(false)
                }
            }

            METHOD_SET_EXTERNAL_ID -> {
                val id: String =
                    call.argument<String>("id")
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
                val latitude: Double =
                    call.argument<Double>("latitude")
                        ?: return result.error("Bad Request", "Latitude should not be null", null)
                Klaviyo.setProfileAttribute(ProfileKey.LATITUDE, latitude)
                logInfo("Latitude updated")
                result.success("Latitude updated")
            }

            METHOD_SET_LONGITUDE -> {
                val longitude: Double =
                    call.argument<Double>("longitude")
                        ?: return result.error("Bad Request", "Longitude should not be null", null)
                Klaviyo.setProfileAttribute(ProfileKey.LONGITUDE, longitude)
                logInfo("Longitude updated")
                result.success("Longitude updated")
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
                val key: String =
                    call.argument<String>("key")
                        ?: return result.error("Bad Request", "Key must not be null", null)
                val value: String =
                    call.argument<String>("value")
                        ?: return result.error("Bad Request", "Value must not be null", null)
                Klaviyo.setProfileAttribute(propertyKey = ProfileKey.CUSTOM(key), value)
                return result.success("Attribute '$key' updated")
            }

            METHOD_SET_BADGE_COUNT -> {
                val count: Int =
                    call.argument<Int>("count")
                        ?: return result.error("Bad Request", "count must not be null", null)
                logInfo("setBadgeCount($count) is not supported on Android; ignoring")
                return result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun isKlaviyoPush(payload: Map<String, String>) = payload.containsKey("_k")

    private fun logDebug(message: String) = runCatching { Log.d(TAG, message) }

    private fun logInfo(message: String) = runCatching { Log.i(TAG, message) }

    private fun logError(
        message: String,
        throwable: Throwable? = null,
    ) = runCatching {
        if (throwable != null) {
            Log.e(TAG, message, throwable)
        } else {
            Log.e(TAG, message)
        }
    }

    companion object {
        private const val CHANNEL_NAME = "com.rightbite.denisr/klaviyo"
    }
}

@VisibleForTesting
internal fun buildProfileAttributes(profileProperties: Map<String, Serializable>): Map<ProfileKey, Serializable> {
    val attributes = mutableMapOf<ProfileKey, Serializable>()
    val processedKeys = mutableSetOf<String>()

    // Process standard profile keys
    PROFILE_KEY_CLASS_SUFFIX.forEach { (rawKey, _) ->
        val value = profileProperties[rawKey] ?: return@forEach
        val profileKey = resolveStandardProfileKey(rawKey)
        if (profileKey != null) {
            attributes[profileKey] = value
            processedKeys.add(rawKey)
        }
    }

    // Process nested custom properties
    val customProperties = profileProperties[PROFILE_PROPERTIES_KEY] as? Map<*, *>
    customProperties?.forEach { (rawKey, rawValue) ->
        val key = rawKey as? String ?: return@forEach
        val value = rawValue as? Serializable ?: return@forEach
        attributes[ProfileKey.CUSTOM(key)] = value
    }

    // Process any remaining properties as custom attributes
    profileProperties.forEach { (key, value) ->
        if (!processedKeys.contains(key) && key != PROFILE_PROPERTIES_KEY) {
            attributes[ProfileKey.CUSTOM(key)] = value
        }
    }

    return attributes
}

@VisibleForTesting
internal fun resolveStandardProfileKey(rawKey: String): ProfileKey? =
    profileKeyCache.getOrPut(rawKey) {
        PROFILE_KEY_CLASS_SUFFIX[rawKey]?.let { suffix ->
            runCatching {
                val className = "com.klaviyo.analytics.model.ProfileKey$$suffix"
                val clazz = Class.forName(className)
                val instanceField = clazz.getField("INSTANCE")
                instanceField.get(null) as? ProfileKey
            }.getOrNull()
        }
    }

private fun convertMapToSeralizedMap(map: Map<String, Any?>): Map<String, Serializable> {
    val convertedMap = mutableMapOf<String, Serializable>()

    for ((key, value) in map) {
        // Only include non-null serializable values
        // Null values are skipped (cannot clear fields via this method)
        if (value is Serializable) {
            convertedMap[key] = value
        }
    }

    return convertedMap
}
