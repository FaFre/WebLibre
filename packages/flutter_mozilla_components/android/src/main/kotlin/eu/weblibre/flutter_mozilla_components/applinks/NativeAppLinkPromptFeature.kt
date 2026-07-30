/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AlertDialog
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptOwner
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.support.base.feature.LifecycleAwareFeature
import java.util.concurrent.ConcurrentHashMap

/**
 * Process-level registry of the *started* [NativeAppLinkPromptFeature] instances, keyed by tabId.
 * The [WebLibreAppLinksInterceptor] runs on an engine thread and creates prompt requests
 * asynchronously; a Custom Tab feature only queries the store at lifecycle start, so without this a
 * request created after start would sit unshown (its navigation already denied) until a rotation or
 * restart. The interceptor pings [notifyPromptAvailable] so the feature re-queries immediately.
 */
object NativeAppLinkPromptNotifier {
    private val features = ConcurrentHashMap<String, NativeAppLinkPromptFeature>()

    fun register(tabId: String, feature: NativeAppLinkPromptFeature) {
        features[tabId] = feature
    }

    fun unregister(tabId: String, feature: NativeAppLinkPromptFeature) {
        features.remove(tabId, feature)
    }

    fun notifyPromptAvailable(tabId: String) {
        features[tabId]?.onPromptAvailable()
    }
}

/**
 * Presents the minimal native app-link prompt for Custom Tab sessions that have no
 * Flutter engine (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.6). Title, message,
 * open/cancel — **no remember checkbox**, so native never creates policy.
 *
 * Queries [PendingAppLinkStore] for its own tab on start (and re-queries after each
 * resolution); a request that is rotated/backgrounded away stays pending and is
 * re-presented on the next start. Owner is fixed to [AppLinkPromptOwner.NATIVE_EXTERNAL].
 */
class NativeAppLinkPromptFeature(
    private val context: Context,
    private val tabId: String,
    private val store: PendingAppLinkStore,
    private val launcher: AppLinkLauncher,
    private val sessionUseCases: SessionUseCases,
) : LifecycleAwareFeature {
    private var dialog: AlertDialog? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun start() {
        NativeAppLinkPromptNotifier.register(tabId, this)
        showNext()
    }

    override fun stop() {
        NativeAppLinkPromptNotifier.unregister(tabId, this)
        // Dismissing on stop is not a user dismissal: the request stays pending and
        // is re-presented on the next start().
        dialog?.setOnDismissListener(null)
        dialog?.dismiss()
        dialog = null
    }

    /**
     * A new pending request may have been created for this tab (interceptor, engine thread) after
     * [start] already queried. Re-check on the main thread; [showNext] is idempotent (a no-op while a
     * dialog is up or when nothing pends).
     */
    fun onPromptAvailable() {
        mainHandler.post { showNext() }
    }

    private fun showNext() {
        if (dialog != null) return

        val request = store.getPending(AppLinkPromptOwner.NATIVE_EXTERNAL)
            .firstOrNull { it.tabId == tabId }
            ?: return

        val title = request.appName?.let {
            context.getString(R.string.weblibre_app_link_prompt_title_named, it)
        } ?: context.getString(R.string.weblibre_app_link_prompt_title_generic)

        dialog = AlertDialog.Builder(context)
            .setTitle(title)
            .setMessage(context.getString(R.string.weblibre_app_link_prompt_message))
            .setPositiveButton(R.string.weblibre_app_link_prompt_open) { _, _ ->
                resolveOpen(request)
            }
            .setNegativeButton(R.string.weblibre_app_link_prompt_cancel) { _, _ ->
                resolveCancel(request)
            }
            .setOnCancelListener {
                // Back / touch-outside is an explicit passive dismissal (§2.6).
                resolveCancel(request)
            }
            .setOnDismissListener { dialog = null }
            .show()
    }

    private fun resolveOpen(request: PendingAppLinkRequest) {
        val consumed = store.consume(request.requestId) ?: return afterResolve()
        val mode = if (consumed.isMarketplace) {
            AppLinkLaunchMode.MARKETPLACE
        } else {
            AppLinkLaunchMode.MANUAL
        }
        // Fresh prompt-open: no remembered package binding to enforce (§2.5); the
        // launcher's pre-launch re-resolution still validates the handler.
        // Honour the package captured when the prompt was created for a *named*
        // (non-ambiguous) target, so a change in handlers before the user taps Open
        // can't launch a different app (§2.5/§2.7). Ambiguous/chooser prompts store a
        // null expectedPackage, so this stays null and the chooser still opens.
        val result = launcher.launch(consumed.url, mode, expectedPackage = consumed.expectedPackage)
        if (result != AppLinkLaunchResult.LAUNCHED) {
            consumed.fallbackUrl?.let { fallback ->
                // Guard the fallback load against immediately bouncing back out to an
                // app (§2.7): a validated fallback can itself resolve externally.
                store.recordFallbackReentry(fallback)
                sessionUseCases.loadUrl(url = fallback, sessionId = consumed.tabId)
            }
        }
        afterResolve()
    }

    private fun resolveCancel(request: PendingAppLinkRequest) {
        val consumed = store.consume(request.requestId) ?: return afterResolve()
        store.recordSuppression(consumed.tabId, consumed.targetFingerprint)
        afterResolve()
    }

    private fun afterResolve() {
        dialog = null
        showNext()
    }
}
