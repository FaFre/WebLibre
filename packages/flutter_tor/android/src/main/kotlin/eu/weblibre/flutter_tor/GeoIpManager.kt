package eu.weblibre.flutter_tor

import android.content.Context
import android.util.Log
import java.io.File
import java.io.FileOutputStream

/**
 * Manages GeoIP database files for country-based node selection
 * GeoIP files are provided by the tor-android library
 */
class GeoIpManager(private val context: Context) {

    companion object {
        private const val TAG = "GeoIpManager"
        private const val GEOIP_FILE = "geoip"
        private const val GEOIP6_FILE = "geoip6"
    }

    /**
     * Get the GeoIP file path, extracting from assets if necessary
     * @param installDir Directory to install GeoIP files
     * @return GeoIP file or null if not available
     */
    fun getGeoIpFile(installDir: File): File? {
        val geoipFile = File(installDir, GEOIP_FILE)
        if (!geoipFile.exists()) {
            extractAsset(GEOIP_FILE, geoipFile)
        }
        return if (geoipFile.exists()) geoipFile else null
    }

    /**
     * Get the GeoIP6 file path, extracting from assets if necessary
     * @param installDir Directory to install GeoIP files
     * @return GeoIP6 file or null if not available
     */
    fun getGeoIp6File(installDir: File): File? {
        val geoip6File = File(installDir, GEOIP6_FILE)
        if (!geoip6File.exists()) {
            extractAsset(GEOIP6_FILE, geoip6File)
        }
        return if (geoip6File.exists()) geoip6File else null
    }

    /**
     * Extract asset file to destination
     * Note: tor-android library should provide these files in its assets
     */
    private fun extractAsset(assetName: String, destFile: File) {
        try {
            context.assets.open(assetName).use { input ->
                destFile.parentFile?.mkdirs()
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            }
            Log.d(TAG, "Extracted $assetName to ${destFile.absolutePath}")
        } catch (e: Exception) {
            Log.w(TAG, "Could not extract $assetName from assets: ${e.message}")
            // GeoIP files are optional - Tor will work without them
            // but country-based node selection won't be available
        }
    }

    /**
     * Check if GeoIP files are available
     * @param installDir Directory where GeoIP files should be
     * @return true if both geoip and geoip6 exist
     */
    fun areGeoIpFilesAvailable(installDir: File): Boolean {
        val geoip = File(installDir, GEOIP_FILE)
        val geoip6 = File(installDir, GEOIP6_FILE)
        return geoip.exists() && geoip6.exists()
    }
}
