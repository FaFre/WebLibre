package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.ContextCompat
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.interceptor.AppRequestInterceptor
import eu.weblibre.flutter_mozilla_components.services.DownloadService
import eu.weblibre.flutter_mozilla_components.EngineProvider
import eu.weblibre.flutter_mozilla_components.PermissionStorage
import eu.weblibre.flutter_mozilla_components.services.MediaSessionService
import eu.weblibre.flutter_mozilla_components.activities.NotificationActivity
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.ext.getPreferenceKey
import eu.weblibre.flutter_mozilla_components.middleware.FlutterEventMiddleware
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import kotlinx.coroutines.FlowPreview
import mozilla.components.browser.engine.gecko.permission.GeckoSitePermissionsStorage
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.session.storage.SessionStorage
import mozilla.components.browser.state.engine.EngineMiddleware
import mozilla.components.browser.state.engine.middleware.SessionPrioritizationMiddleware
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.browser.storage.sync.PlacesHistoryStorage
import mozilla.components.browser.thumbnails.ThumbnailsMiddleware
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.engine.DefaultSettings
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy
import mozilla.components.concept.engine.fission.WebContentIsolationStrategy
import mozilla.components.concept.engine.mediaquery.PreferredColorScheme
import mozilla.components.concept.fetch.Client
import mozilla.components.feature.addons.AddonManager
import mozilla.components.feature.addons.amo.AMOAddonsProvider
import mozilla.components.feature.addons.migration.DefaultSupportedAddonsChecker
import mozilla.components.feature.addons.update.DefaultAddonUpdater
import mozilla.components.feature.customtabs.store.CustomTabsServiceStore
import mozilla.components.feature.downloads.DownloadMiddleware
import mozilla.components.feature.media.MediaSessionFeature
import mozilla.components.feature.media.middleware.RecordingDevicesMiddleware
import mozilla.components.feature.prompts.file.FileUploadsDirCleaner
import mozilla.components.feature.readerview.ReaderViewMiddleware
import mozilla.components.feature.session.HistoryDelegate
import mozilla.components.feature.session.middleware.LastAccessMiddleware
import mozilla.components.feature.sitepermissions.OnDiskSitePermissionsStorage
import mozilla.components.feature.webnotifications.WebNotificationFeature
import mozilla.components.support.base.worker.Frequency
import java.util.concurrent.TimeUnit

private const val DAY_IN_MINUTES = 24 * 60L

class Core(private val context: Context,
           private val components: Components,
           private val flutterEvents: GeckoStateEvents,
           private val extensionEvents: BrowserExtensionEvents
) {
    val prefs by lazy {
        PreferenceManager.getDefaultSharedPreferences(context)
    }

    val engineSettings by lazy {
        DefaultSettings(
            //historyTrackingDelegate = HistoryDelegate(lazyHistoryStorage)
            requestInterceptor = AppRequestInterceptor(context),
            historyTrackingDelegate = HistoryDelegate(lazyHistoryStorage),
            testingModeEnabled = false,
            remoteDebuggingEnabled = false,
            automaticFontSizeAdjustment = true,
            fontInflationEnabled = true,
            suspendMediaWhenInactive = false,
            getDesktopMode = {
                store.state.desktopMode
            },
            enterpriseRootsEnabled = false,
            emailTrackerBlockingPrivateBrowsing = true,
//            clearColor = ContextCompat.getColor(
//                context,
//                R.color.fx_mobile_layer_color_1,
//            ),

            trackingProtectionPolicy = createTrackingProtectionPolicy(TrackingProtectionPolicy.strict()),
            //FP Protection is handled by trackingPolicy
            //fingerprintingProtection
            //fingerprintingProtectionPrivateBrowsing
            httpsOnlyMode = Engine.HttpsOnlyMode.ENABLED,
            globalPrivacyControlEnabled = true,
            preferredColorScheme = PreferredColorScheme.Dark,
            cookieBannerHandlingMode = EngineSession.CookieBannerHandlingMode.REJECT_ALL,
            cookieBannerHandlingModePrivateBrowsing = EngineSession.CookieBannerHandlingMode.REJECT_ALL,
            cookieBannerHandlingGlobalRules = true,
            cookieBannerHandlingGlobalRulesSubFrames = true,
            webContentIsolationStrategy = WebContentIsolationStrategy.ISOLATE_HIGH_VALUE
        )
    }

    val engine: Engine by lazy {
        EngineProvider.createEngine(context, engineSettings, extensionEvents)
    }

    /**
     * The [Client] implementation (`concept-fetch`) used for HTTP requests.
     */
    val client: Client by lazy {
        EngineProvider.createClient(context)
    }

    val thumbnailStorage by lazy { ThumbnailStorage(context) }

    val icons by lazy { BrowserIcons(context, client) }

    /**
     * A storage component for site permissions.
     */
    val geckoSitePermissionsStorage by lazy {
        val geckoRuntime = EngineProvider.getOrCreateRuntime(context)
        GeckoSitePermissionsStorage(geckoRuntime, OnDiskSitePermissionsStorage(context))
    }

    // Addons
    val addonManager by lazy {
        AddonManager(store, engine, addonsProvider, addonUpdater)
    }

    val addonUpdater by lazy {
        DefaultAddonUpdater(
            context,
            Frequency(1, TimeUnit.DAYS),
            components.notificationsDelegate
        )
    }

    val addonsProvider by lazy {
        AMOAddonsProvider(
            context,
            client,
            collectionName = "7dfae8669acc4312a65e8ba5553036",
            maxCacheAgeInMinutes = DAY_IN_MINUTES,
        )
    }

    val supportedAddonsChecker by lazy {
        DefaultSupportedAddonsChecker(context, Frequency(1, TimeUnit.DAYS))
    }

    val fileUploadsDirCleaner: FileUploadsDirCleaner by lazy {
        FileUploadsDirCleaner { context.cacheDir }
    }

    @OptIn(FlowPreview::class)
    val store by lazy {
        BrowserStore(
            middleware = listOf(
                FlutterEventMiddleware(flutterEvents),
                DownloadMiddleware(context, DownloadService::class.java),
                ThumbnailsMiddleware(thumbnailStorage),
                ReaderViewMiddleware(),
//                UndoMiddleware(),
                LastAccessMiddleware(),
//                PromptMiddleware(),
                SessionPrioritizationMiddleware(),
                RecordingDevicesMiddleware(context, components.notificationsDelegate),
            ) + EngineMiddleware.create(
                engine,
                // We are disabling automatic suspending of engine sessions under memory pressure.
                // Instead we solely rely on GeckoView and the Android system to reclaim memory
                // when needed. For details, see:
                // https://bugzilla.mozilla.org/show_bug.cgi?id=1752594
                // https://github.com/mozilla-mobile/fenix/issues/12731
                // https://github.com/mozilla-mobile/android-components/issues/11300
                // https://github.com/mozilla-mobile/android-components/issues/11653
                trimMemoryAutomatically = false,
            )
        ).apply {
            components.events.registerFlowEvents(this)

            icons.install(engine, this)

            WebNotificationFeature(
                context,
                engine,
                icons,
                R.drawable.ic_launcher_foreground,
                geckoSitePermissionsStorage,
                NotificationActivity::class.java,
                notificationsDelegate = components.notificationsDelegate,
            )

            MediaSessionFeature(context, MediaSessionService::class.java, this).start()
        }
    }

    /**
     * The [CustomTabsServiceStore] holds global custom tabs related data.
     */
    val customTabsStore by lazy { CustomTabsServiceStore() }

    /**
     * The storage component for persisting browser tab sessions.
     */
    val sessionStorage: SessionStorage by lazy {
        SessionStorage(context, engine)
    }

    /**
     * The storage component to persist browsing history (with the exception of
     * private sessions).
     */
    val lazyHistoryStorage = lazy { PlacesHistoryStorage(context) }

    /**
     * A convenience accessor to the [PlacesHistoryStorage].
     */
    val historyStorage by lazy { lazyHistoryStorage.value }

    val permissionStorage by lazy { PermissionStorage( geckoSitePermissionsStorage ) }

    /**
     * Constructs a [TrackingProtectionPolicy] based on current preferences.
     *
     * @param prefs the shared preferences to use when reading tracking
     * protection settings.
     * @param normalMode whether or not tracking protection should be enabled
     * in normal browsing mode, defaults to the current preference value.
     * @param privateMode whether or not tracking protection should be enabled
     * in private browsing mode, default to the current preference value.
     * @return the constructed tracking protection policy based on preferences.
     */
    private fun createTrackingProtectionPolicy(
        trackingPolicy: EngineSession. TrackingProtectionPolicyForSessionTypes,
        normalMode: Boolean = true,
        privateMode: Boolean = true,
    ): TrackingProtectionPolicy {
        return when {
            normalMode && privateMode -> trackingPolicy
            normalMode && !privateMode -> trackingPolicy.forRegularSessionsOnly()
            !normalMode && privateMode -> trackingPolicy.forPrivateSessionsOnly()
            else -> TrackingProtectionPolicy.none()
        }
    }

}