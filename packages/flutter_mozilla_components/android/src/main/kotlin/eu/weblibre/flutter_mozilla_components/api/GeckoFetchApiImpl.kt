package eu.weblibre.flutter_mozilla_components.api

import android.os.Build
import androidx.annotation.RequiresApi
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFetchApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFetchCookiePolicy
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFetchMethod
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFetchRedircet
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFetchRequest
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFetchResponse
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoHeader
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.fetch.MutableHeaders
import mozilla.components.concept.fetch.Request
import java.util.concurrent.TimeUnit

class GeckoFetchApiImpl : GeckoFetchApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    }

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    override fun fetch(
        request: GeckoFetchRequest,
        callback: (Result<GeckoFetchResponse>) -> Unit
    ) {
        val headers = MutableHeaders()
        for (header in request.headers) {
            headers.append(header.key, header.value)
        }

        val request = Request(
            url = request.url,
            method = when (request.method) {
                GeckoFetchMethod.GET -> Request.Method.GET
                GeckoFetchMethod.HEAD -> Request.Method.HEAD
                GeckoFetchMethod.POST -> Request.Method.POST
                GeckoFetchMethod.PUT -> Request.Method.PUT
                GeckoFetchMethod.DELETE -> Request.Method.DELETE
                GeckoFetchMethod.CONNECT -> Request.Method.CONNECT
                GeckoFetchMethod.OPTIONS -> Request.Method.OPTIONS
                GeckoFetchMethod.TRACE -> Request.Method.TRACE
            },
            headers = headers,
            connectTimeout = if (request.connectTimeoutMillis != null) Pair(
                request.connectTimeoutMillis,
                TimeUnit.MILLISECONDS
            ) else null,
            readTimeout = if (request.readTimeoutMillis != null) Pair(
                request.readTimeoutMillis,
                TimeUnit.MILLISECONDS
            ) else null,
            body = if (request.body != null) Request.Body.fromString(request.body) else null,
            redirect = when (request.redirect) {
                GeckoFetchRedircet.FOLLOW -> Request.Redirect.FOLLOW
                GeckoFetchRedircet.MANUAL -> Request.Redirect.MANUAL
            },
            cookiePolicy = when (request.cookiePolicy) {
                GeckoFetchCookiePolicy.INCLUDE -> Request.CookiePolicy.INCLUDE
                GeckoFetchCookiePolicy.OMIT -> Request.CookiePolicy.OMIT
            },
            useCaches = request.useCaches,
            private = request.private,
            useOhttp = request.useOhttp,
            referrerUrl = request.referrerUrl,
            conservative = request.conservative
        )

        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val response = components.core.client.fetch(request)
                callback(
                    Result.success(
                    GeckoFetchResponse(
                    url = response.url,
                    status = response.status.toLong(),
                    body = response.body.useStream { stream -> stream.readAllBytes() },
                    headers = response.headers.map { it -> GeckoHeader(it.name, it.value) }
                )))
            }
        }
    }
}