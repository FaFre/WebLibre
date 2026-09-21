/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.CookieManagerFeature
import eu.weblibre.flutter_mozilla_components.feature.awaitResult
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

    private suspend fun handleRequest(action: String, args: JSONObject) {
        awaitResult({ CookieManagerFeature.scheduleRequest(action, args, it) }) { }
    }

    override suspend fun getCookie(
        firstPartyDomain: String?,
        name: String,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String
    ): Cookie {
        val args = createBaseArgs(firstPartyDomain, partitionKey, storeId, url).apply {
            put("name", name)
        }

        return awaitResult({ CookieManagerFeature.scheduleRequest("get", args, it) }) { result ->
            cookieFromJSON(result.getJSONObject("result"))
        }
    }

    override suspend fun getAllCookies(
        domain: String?,
        firstPartyDomain: String?,
        name: String?,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String
    ): List<Cookie> {
        val args = createBaseArgs(firstPartyDomain, partitionKey, storeId, url).apply {
            putNullable("domain", domain)
            putNullable("name", name)
        }

        return awaitResult({ CookieManagerFeature.scheduleRequest("getAll", args, it) }) { result ->
            result.getJSONArray("result").let { jsonArray ->
                List(jsonArray.length()) { cookieFromJSON(jsonArray.getJSONObject(it)) }
            }
        }
    }

    override suspend fun setCookie(
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
        value: String?
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

        handleRequest("set", args)
    }

    override suspend fun removeCookie(
        firstPartyDomain: String?,
        name: String,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String
    ) {
        val args = createBaseArgs(firstPartyDomain, partitionKey, storeId, url).apply {
            put("name", name)
        }

        handleRequest("remove", args)
    }
}
