package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.ContextWrapper
import android.content.ComponentCallbacks
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import androidx.annotation.RequiresApi
import eu.weblibre.flutter_mozilla_components.startup.ProfileUuid
import mozilla.components.support.base.log.logger.Logger
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
    private val databasesDir: File get() = File(customDataDir, "databases")
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
        return File(databasesDir, name).apply {
            parentFile?.mkdirs()
            adoptSharedDatabase(name, this)
        }
    }

    override fun openOrCreateDatabase(
        name: String,
        mode: Int,
        factory: SQLiteDatabase.CursorFactory?,
    ): SQLiteDatabase = openOrCreateDatabase(name, mode, factory, null)

    /**
     * Opens [name] at [getDatabasePath], which is what API 27 and later do on
     * their own.
     *
     * Android 8.0's `SQLiteOpenHelper`, and with it Room, opens by name through
     * here, and `ContextWrapper` hands that to the framework context, which looks
     * the name up in the app's own `databases/` folder. Every profile then
     * shared one downloads list, one set of site permissions, one set of PWA
     * manifests and one list of recently closed tabs.
     */
    override fun openOrCreateDatabase(
        name: String,
        mode: Int,
        factory: SQLiteDatabase.CursorFactory?,
        errorHandler: DatabaseErrorHandler?,
    ): SQLiteDatabase {
        val path = getDatabasePath(name)

        var flags = SQLiteDatabase.CREATE_IF_NECESSARY
        if ((mode and MODE_ENABLE_WRITE_AHEAD_LOGGING) != 0) {
            flags = flags or SQLiteDatabase.ENABLE_WRITE_AHEAD_LOGGING
        }
        if ((mode and MODE_NO_LOCALIZED_COLLATORS) != 0) {
            flags = flags or SQLiteDatabase.NO_LOCALIZED_COLLATORS
        }
        return SQLiteDatabase.openDatabase(path.path, factory, flags, errorHandler)
    }

    // Both would otherwise act on the app's global folder, on every API level:
    // deleting a profile's database deleted the global one of that name. Past
    // getDatabasePath, so deleting a profile's database never takes over the
    // shared one only to delete it.
    override fun deleteDatabase(name: String): Boolean =
        SQLiteDatabase.deleteDatabase(File(databasesDir, name))

    override fun databaseList(): Array<String> = databasesDir.list() ?: emptyArray()

    /**
     * Moves a database Android 8.0 kept in the global folder into this profile,
     * the first time a profile asks for it here. Whichever profile is opened
     * first after the update gets the shared file, others start empty: its rows
     * carry no profile, so they cannot be split.
     *
     * On every API level, not just 8.0: a device updated to a later Android
     * before this ran still has the files there. Nothing else opens these names
     * outside a profile, so a global copy is always one 8.0 left.
     *
     * The main file moves first. A journal left behind without it costs the
     * last writes; one moved ahead of it would be replayed into a new file.
     */
    private fun adoptSharedDatabase(name: String, path: File) {
        if (name !in SHARED_ON_ANDROID_8_0 || path.exists()) return

        val shared = base.getDatabasePath(name)
        if (shared == path || !shared.exists()) return

        for (suffix in listOf("", "-wal", "-journal", "-shm")) {
            val from = File(shared.path + suffix)
            if (from.exists() && !from.renameTo(File(path.path + suffix))) {
                logger.warn("Could not move $name$suffix into $relativePath")
                return
            }
        }
        logger.info("Moved $name into $relativePath")
    }

    override fun getSharedPreferences(name: String, mode: Int): SharedPreferences {
        return base.getSharedPreferences("${profilePrefix}_$name", mode)
    }

    companion object {
        private val logger = Logger("ProfileContext")

        /**
         * The Room databases AC opens through a profile's context, which Android
         * 8.0 kept in the app's global folder (see [openOrCreateDatabase]). Names
         * are AC internals, so check them on every AC upgrade.
         */
        internal val SHARED_ON_ANDROID_8_0 = setOf(
            "mozac_downloads_database", // DownloadStorage
            "site_permissions_database", // OnDiskSitePermissionsStorage
            "recently_closed_tabs", // RecentlyClosedTabsStorage
            "manifests", // ManifestStorage
        )
    }
}

/**
 * The app's application context, also for a [ProfileContext], whose application
 * context is itself. For state every profile shares, which a profile context
 * would put under its own prefix or folder.
 */
internal val Context.rootApplicationContext: Context
    get() = (this as? ProfileContext)?.rootApplicationContext ?: applicationContext
