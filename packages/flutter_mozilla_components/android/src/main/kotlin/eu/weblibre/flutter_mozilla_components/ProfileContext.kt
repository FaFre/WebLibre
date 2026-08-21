package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.ContextWrapper
import android.content.ComponentCallbacks
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.os.Build
import androidx.annotation.RequiresApi
import eu.weblibre.flutter_mozilla_components.startup.ProfileUuid
import java.io.File

class ProfileContext(private val base: Context, val relativePath: String) :
    ContextWrapper(base) {

    internal val rootApplicationContext: Context
        get() = base.applicationContext

    private val subfolderRoot =
        File(base.filesDir, relativePath) // /data/user/0/com.app/profiles/default

    private val profilePrefix = File(relativePath).name

    /**
     * The canonical UUID of the profile this context serves, or null if the path
     * does not name one.
     *
     * Callers doing cross-profile work need the id of the profile they are holding
     * a context for, and deriving it from [relativePath] at each call site is how
     * two of them end up disagreeing.
     */
    val profileId: String? = ProfileUuid.fromDirName(profilePrefix)

    private var customFilesDir: File = File(subfolderRoot, "files")
    private var customNoBackupFilesDir: File = File(subfolderRoot, "no_backup")
    private var customObbDir: File = File(subfolderRoot, "obb")
    private var customCacheDir: File = File(subfolderRoot, "cache")
    private var customCodeCacheDir: File = File(subfolderRoot, "code_cache")
    private var customDataDir: File = subfolderRoot
    private var customExternalCacheDir: File? =
        base.externalCacheDir?.parentFile?.let { File(File(it, relativePath), "cache") }
    private var customExternalFilesDir: File? =
        base.getExternalFilesDir(null)?.parentFile?.let { File(File(it, relativePath), "files") }

    private val customApplicationInfo: ApplicationInfo by lazy {
        val original = base.applicationInfo
        ApplicationInfo(original).apply {
            dataDir = customDataDir.absolutePath
            sourceDir = original.sourceDir
            publicSourceDir = original.publicSourceDir
            nativeLibraryDir = original.nativeLibraryDir
            deviceProtectedDataDir = customDataDir.absolutePath

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                deviceProtectedDataDir = customDataDir.absolutePath
            }
        }
    }

    init {
        // Constructing a profile-scoped context must not change global preference
        // routing. It used to assign `ActiveProfile.prefix` here, so merely
        // instantiating this class for *any* profile silently repointed every
        // profile-sensitive preference file in the process. The committed profile
        // is now the only thing that decides the prefix.
        customFilesDir.mkdirs()
        customNoBackupFilesDir.mkdirs()
        customObbDir.mkdirs()
        customCacheDir.mkdirs()
        customCodeCacheDir.mkdirs()
        customDataDir.mkdirs()
        customExternalCacheDir?.mkdirs()
        customExternalFilesDir?.mkdirs()
    }

    override fun getApplicationInfo(): ApplicationInfo {
        return customApplicationInfo
    }

    override fun getApplicationContext(): Context {
        return this
    }

    override fun registerComponentCallbacks(callback: ComponentCallbacks) {
        base.applicationContext.registerComponentCallbacks(callback)
    }

    override fun unregisterComponentCallbacks(callback: ComponentCallbacks) {
        base.applicationContext.unregisterComponentCallbacks(callback)
    }

    override fun getFilesDir(): File {
        return customFilesDir
    }

    override fun getFileStreamPath(name: String): File {
        return File(customFilesDir, name)
    }

    override fun getNoBackupFilesDir(): File {
        return customNoBackupFilesDir
    }

    override fun getObbDir(): File {
        return customObbDir
    }

    override fun getCacheDir(): File {
        return customCacheDir
    }

    override fun getCodeCacheDir(): File {
        return customCodeCacheDir
    }

    @RequiresApi(Build.VERSION_CODES.N)
    override fun getDataDir(): File {
        return customDataDir
    }

    override fun getExternalCacheDir(): File? {
        return customExternalCacheDir
    }

    override fun getExternalFilesDir(type: String?): File? {
        return if (type == null) {
            customExternalFilesDir
        } else {
            base.getExternalFilesDir(type)?.parentFile?.let {
                File(File(it, relativePath), type)
            }?.apply { mkdirs() }
        }
    }

    override fun getExternalFilesDirs(type: String?): Array<File> {
        return base.getExternalFilesDirs(type).map {
            File(File(it.parentFile!!, relativePath), type ?: "files").apply { mkdirs() }
        }.toTypedArray()
    }

    override fun getExternalCacheDirs(): Array<File> {
        return base.externalCacheDirs.map {
            File(File(it.parentFile!!, relativePath), "cache").apply { mkdirs() }
        }.toTypedArray()
    }

    override fun getExternalMediaDirs(): Array<File> {
        return base.externalMediaDirs.map {
            File(File(it.parentFile!!, relativePath), "media").apply { mkdirs() }
        }.toTypedArray()
    }

    override fun getDir(name: String, mode: Int): File {
        return File(customDataDir, name).apply { mkdirs() }
    }

    override fun getDatabasePath(name: String): File {
        return File(File(customDataDir, "databases"), name).apply {
            parentFile?.mkdirs()
        }
    }

    override fun getSharedPreferences(name: String, mode: Int): SharedPreferences {
        return base.getSharedPreferences("${profilePrefix}_$name", mode)
    }
}
