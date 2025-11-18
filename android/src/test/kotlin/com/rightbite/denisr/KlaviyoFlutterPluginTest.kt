package com.rightbite.denisr

import com.klaviyo.analytics.Klaviyo
import com.klaviyo.analytics.model.Event
import com.klaviyo.analytics.model.ProfileKey
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.clearAllMocks
import io.mockk.every
import io.mockk.mockkObject
import io.mockk.slot
import io.mockk.unmockkAll
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import java.io.Serializable

class KlaviyoFlutterPluginTest {
    @Before
    fun setUp() {
        mockkObject(Klaviyo)
    }

    @Test
    fun `setBadgeCount returns success`() {
        val plugin = KlaviyoFlutterPlugin()
        val result = TestResult()

        plugin.onMethodCall(
            MethodCall("setBadgeCount", mapOf("count" to 5)),
            result,
        )

        assertEquals(null, result.successValue)
    }

    @After
    fun tearDown() {
        clearAllMocks()
        unmockkAll()
    }

    @Test
    fun `logEvent succeeds without metadata`() {
        val eventSlot = slot<Event>()
        every { Klaviyo.createEvent(capture(eventSlot)) } returns Klaviyo

        val plugin = KlaviyoFlutterPlugin()
        val result = TestResult()

        plugin.onMethodCall(
            MethodCall("logEvent", mapOf<String, Any?>("name" to "event")),
            result,
        )

        assertTrue(eventSlot.isCaptured)
        assertEquals("Event[event] created", result.successValue)
    }

    @Test
    fun `logEvent handles empty metadata`() {
        val eventSlot = slot<Event>()
        every { Klaviyo.createEvent(capture(eventSlot)) } returns Klaviyo

        val plugin = KlaviyoFlutterPlugin()
        val result = TestResult()

        plugin.onMethodCall(
            MethodCall(
                "logEvent",
                mapOf<String, Any?>(
                    "name" to "event",
                    "metaData" to emptyMap<String, Any>(),
                ),
            ),
            result,
        )

        assertTrue(eventSlot.isCaptured)
        assertEquals("Event[event] created", result.successValue)
    }

    @Test
    fun `logEvent forwards metadata values`() {
        val eventSlot = slot<Event>()
        every { Klaviyo.createEvent(capture(eventSlot)) } returns Klaviyo

        val plugin = KlaviyoFlutterPlugin()
        val result = TestResult()

        val metadata =
            mapOf(
                "string" to "value",
                "number" to 42,
                "bool" to true,
            )
        plugin.onMethodCall(
            MethodCall(
                "logEvent",
                mapOf<String, Any?>(
                    "name" to "event",
                    "metaData" to metadata,
                ),
            ),
            result,
        )

        assertTrue(eventSlot.isCaptured)
        assertEquals("Event[event] created", result.successValue)
    }

    @Test
    fun `buildProfileAttributes maps standard fields and custom properties`() {
        val properties =
            linkedMapOf<String, Serializable>(
                "external_id" to "ext-123",
                "email" to "test@example.com",
                "phone_number" to "+1234567890",
                "first_name" to "First",
                "last_name" to "Last",
                "organization" to "Org",
                "title" to "Title",
                "image" to "https://example.com/avatar.png",
                "address1" to "Line1",
                "address2" to "Line2",
                "city" to "City",
                "country" to "Country",
                "region" to "Region",
                "zip" to "12345",
                "timezone" to "UTC",
                "latitude" to 10.5,
                "longitude" to -45.2,
                "favorite_color" to "blue",
                "properties" to
                    linkedMapOf<String, Serializable>(
                        "app_version" to "1.0.0",
                        "loyalty" to true,
                    ),
            )

        val attributes = buildProfileAttributes(properties)

        val externalIdKey = requireNotNull(resolveStandardProfileKey("external_id"))
        val emailKey = requireNotNull(resolveStandardProfileKey("email"))
        val latitudeKey = requireNotNull(resolveStandardProfileKey("latitude"))
        val longitudeKey = requireNotNull(resolveStandardProfileKey("longitude"))

        assertEquals("ext-123", attributes[externalIdKey])
        assertEquals("test@example.com", attributes[emailKey])
        assertEquals(10.5, attributes[latitudeKey])
        assertEquals(-45.2, attributes[longitudeKey])
        assertEquals("blue", attributes[ProfileKey.CUSTOM("favorite_color")])
        assertEquals("1.0.0", attributes[ProfileKey.CUSTOM("app_version")])
        assertEquals(true, attributes[ProfileKey.CUSTOM("loyalty")])
    }
}

private class TestResult : MethodChannel.Result {
    var successValue: Any? = null
    var errorValue: Triple<String, String?, Any?>? = null
    var notImplementedCalled: Boolean = false

    override fun success(result: Any?) {
        successValue = result
    }

    override fun error(
        errorCode: String,
        errorMessage: String?,
        errorDetails: Any?,
    ) {
        errorValue = Triple(errorCode, errorMessage, errorDetails)
    }

    override fun notImplemented() {
        notImplementedCalled = true
    }
}
