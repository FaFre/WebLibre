/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.CookieManagerFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.pigeons.*
import org.json.JSONObject

class GeckoCookieApiImpl : GeckoCookieApi {
    private companion object {
        const val ERROR_INVALID_KEY = "Invalid map key"
    }

    private fun JSONObject.putNullable(key: String, value: Any?) {
        put(key, value ?: JSONObject.NULL)
    }

    private fun JSONObject.getValueOrNull(key: String): Any? {
        if (!has(key)) throw RuntimeException(ERROR_INVALID_KEY)
        return if (!isNull(key)) get(key) else null
    }

    private fun CookiePartitionKey.toJSON() = JSONObject().apply {
        put("topLevelSite", topLevelSite)
    }

    private fun cookiePartitionKeyFromJSON(json: JSONObject) = CookiePartitionKey(
        topLevelSite = json.getString("topLevelSite")
    )

    private fun cookieFromJSON(json: JSONObject): Cookie {
        val partitionKeyJson = json.getValueOrNull("partitionKey") as JSONObject?
        val partitionKey = partitionKeyJson?.takeUnless { it.length() == 0 }?.let {
            cookiePartitionKeyFromJSON(it)
        }

        return Cookie(
            domain = json.getString("domain"),
            expirationDate = (json.getValueOrNull("expirationDate") as Int?)?.toLong(),
            firstPartyDomain = json.getString("firstPartyDomain"),
            hostOnly = json.getBoolean("hostOnly"),
            httpOnly = json.getBoolean("httpOnly"),
            name = json.getString("name"),
            partitionKey = partitionKey,
            path = json.getString("path"),
            secure = json.getBoolean("secure"),
            session = json.getBoolean("session"),
            sameSite = parseSameSiteStatus(json.getString("sameSite")),
            storeId = json.getString("storeId"),
            value = json.getString("value")
        )
    }

    private fun parseSameSiteStatus(status: String) = when(status) {
        "no_restriction" -> CookieSameSiteStatus.NO_RESTRICTION
        "lax" -> CookieSameSiteStatus.LAX
        "strict" -> CookieSameSiteStatus.STRICT
        else -> CookieSameSiteStatus.UNSPECIFIED
    }

    private fun sameSiteToString(status: CookieSameSiteStatus) = when(status) {
        CookieSameSiteStatus.NO_RESTRICTION -> "no_restriction"
        CookieSameSiteStatus.LAX -> "lax"
        CookieSameSiteStatus.STRICT -> "strict"
        CookieSameSiteStatus.UNSPECIFIED -> ""
    }

    private fun createBaseArgs(
        firstPartyDomain: String?,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String
    ) = JSONObject().apply {
        putNullable("firstPartyDomain", firstPartyDomain)
        putNullable("partitionKey", partitionKey?.toJSON())
        putNullable("storeId", storeId)
        put("url", url)
    }

    private fun handleRequest(
        action: String,
        args: JSONObject,
        callback: (Result<Unit>) -> Unit
    ) {
        CookieManagerFeature.scheduleRequest(action, args, object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(Unit))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

    override fun getCookie(
        firstPartyDomain: String?,
        name: String,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String,
        callback: (Result<Cookie>) -> Unit
    ) {
        val args = createBaseArgs(firstPartyDomain, partitionKey, storeId, url).apply {
            put("name", name)
        }

        CookieManagerFeature.scheduleRequest("get", args, object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(cookieFromJSON(result.getJSONObject("result"))))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

    override fun getAllCookies(
        domain: String?,
        firstPartyDomain: String?,
        name: String?,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String,
        callback: (Result<List<Cookie>>) -> Unit
    ) {
        val args = createBaseArgs(firstPartyDomain, partitionKey, storeId, url).apply {
            putNullable("domain", domain)
            putNullable("name", name)
        }

        CookieManagerFeature.scheduleRequest("getAll", args, object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                val cookies = result.getJSONArray("result").let { jsonArray ->
                    List(jsonArray.length()) { cookieFromJSON(jsonArray.getJSONObject(it)) }
                }
                callback(Result.success(cookies))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

    override fun setCookie(
        domain: String?,
        expirationDate: Long?,
        firstPartyDomain: String?,
        httpOnly: Boolean?,
        name: String?,
        partitionKey: CookiePartitionKey?,
        path: String?,
        sameSite: CookieSameSiteStatus?,
        secure: Boolean?,
        storeId: String?,
        url: String,
        value: String?,
        callback: (Result<Unit>) -> Unit
    ) {
        val args = createBaseArgs(firstPartyDomain, partitionKey, storeId, url).apply {
            putNullable("domain", domain)
            putNullable("expirationDate", expirationDate)
            putNullable("httpOnly", httpOnly)
            putNullable("name", name)
            putNullable("path", path)
            putNullable("sameSite", sameSite?.let { sameSiteToString(it) })
            putNullable("secure", secure)
            putNullable("value", value)
        }

        handleRequest("set", args, callback)
    }

    override fun removeCookie(
        firstPartyDomain: String?,
        name: String,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String,
        callback: (Result<Unit>) -> Unit
    ) {
        val args = createBaseArgs(firstPartyDomain, partitionKey, storeId, url).apply {
            put("name", name)
        }

        handleRequest("remove", args, callback)
    }
}
