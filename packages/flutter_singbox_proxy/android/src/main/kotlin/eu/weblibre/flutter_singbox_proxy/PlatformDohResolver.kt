package eu.weblibre.flutter_singbox_proxy

import java.io.IOException
import java.util.concurrent.TimeUnit
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

/**
 * RFC 8484 DoH client used as the bootstrap resolver for sing-box's
 * `type: "local"` DNS transport.
 *
 * Sing-box calls the platform LocalDNSTransport whenever a DNS server's own
 * hostname (or any other hostname referenced by `domain_resolver` /
 * `default_domain_resolver`) needs resolving. We bounce the wire-format query
 * straight to a configured DoH endpoint so no query ever hits Android's
 * system resolver.
 *
 * The DoH endpoint's own hostname is resolved exactly once by the JVM HTTP
 * stack. Configure the URL with an IP literal (e.g. `https://1.1.1.1/dns-query`)
 * if even that one lookup must not leak.
 */
class PlatformDohResolver(
    private val connectTimeoutMillis: Int = 5_000,
    private val readTimeoutMillis: Int = 5_000,
) {
    private val client: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(connectTimeoutMillis.toLong(), TimeUnit.MILLISECONDS)
        .readTimeout(readTimeoutMillis.toLong(), TimeUnit.MILLISECONDS)
        .build()

    /** Send [request] as a DoH POST and return the raw DNS wire-format reply. */
    @Throws(IOException::class)
    fun exchange(url: String, request: ByteArray): ByteArray {
        val httpRequest = Request.Builder()
            .url(url)
            .header("Accept", DNS_MESSAGE_MIME)
            .post(request.toRequestBody(DNS_MESSAGE_MEDIA_TYPE))
            .build()

        client.newCall(httpRequest).execute().use { response ->
            if (!response.isSuccessful) {
                throw IOException(
                    "DoH endpoint returned HTTP ${response.code} via ${response.protocol}"
                )
            }
            val contentType = response.header("Content-Type").orEmpty()
            if (!contentType.startsWith(DNS_MESSAGE_MIME, ignoreCase = true)) {
                throw IOException(
                    "DoH endpoint returned unexpected Content-Type: $contentType"
                )
            }

            val body = response.body ?: throw IOException("DoH endpoint returned no body")
            val contentLength = body.contentLength()
            if (contentLength > MAX_DNS_RESPONSE) {
                throw IOException("DoH response exceeds maximum DNS message size")
            }

            return body.bytes().also { bytes ->
                if (bytes.size > MAX_DNS_RESPONSE) {
                    throw IOException("DoH response exceeds maximum DNS message size")
                }
            }
        }
    }

    private companion object {
        const val DNS_MESSAGE_MIME = "application/dns-message"
        val DNS_MESSAGE_MEDIA_TYPE = DNS_MESSAGE_MIME.toMediaType()
        // EDNS0 typically caps responses at 4 KiB; we allow a little slack.
        const val MAX_DNS_RESPONSE = 8 * 1024
    }
}
