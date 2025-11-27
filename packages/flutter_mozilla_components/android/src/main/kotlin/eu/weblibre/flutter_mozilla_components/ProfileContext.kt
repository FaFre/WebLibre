package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.ContextWrapper
import android.content.pm.ApplicationInfo
import android.os.Build
import androidx.annotation.RequiresApi
import java.io.File

class ProfileContext(private val base: Context, private val relativePath: String) :
    ContextWrapper(base) {

    private val subfolderRoot =
        File(base.filesDir, relativePath) // /data/user/0/com.app/profiles/default

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
}
