/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.app.Dialog
import android.content.Context
import android.content.DialogInterface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import android.view.Window
import androidx.appcompat.app.AppCompatDialogFragment
import androidx.fragment.app.FragmentManager
import eu.weblibre.flutter_mozilla_components.DownloadManagerPreference
import eu.weblibre.flutter_mozilla_components.databinding.DialogDownloadAppChooserBinding
import mozilla.components.feature.downloads.NegativeActionCallback
import mozilla.components.feature.downloads.ThirdPartyDownloaderAppChosenCallback
import mozilla.components.feature.downloads.ThirdPartyDownloaderApps
import mozilla.components.feature.downloads.ui.DownloaderApp
import mozilla.components.feature.downloads.ui.DownloaderAppAdapter
import mozilla.components.support.utils.ext.getParcelableArrayListCompat

/**
 * The download manager chooser, with the "Always use this app" choice that
 * Mozilla's own chooser has no room for.
 *
 * Plugged into `DownloadsFeature` through its public third-party dialog
 * delegate ([show]) and forwarding predicate ([shouldForwardToThirdParties]),
 * so the download routing itself stays Mozilla's: `DownloadsFeature` decides
 * when there is a choice to make and which apps can take the download, and
 * starts or cancels it through the callbacks it hands over.
 *
 * A remembered app is used only when it is among the apps offered for *this*
 * download; otherwise the chooser shows as if nothing were remembered, and the
 * choice stays for the downloads the app can take.
 *
 * @param context resolves the profile-scoped preference; any context works.
 * @param fragmentManager hosts the dialog, the same one `DownloadsFeature` was
 * given for its first-party confirmation.
 */
internal class DownloadAppChooser(
    private val context: Context,
    private val fragmentManager: FragmentManager,
) {
    /** For `DownloadsFeature.shouldForwardToThirdParties`. */
    fun shouldForwardToThirdParties(): Boolean =
        DownloadManagerPreference.shouldForwardToThirdParties(context)

    /** For `DownloadsFeature.customThirdPartyDownloadDialog`. */
    fun show(
        apps: ThirdPartyDownloaderApps,
        onAppChosen: ThirdPartyDownloaderAppChosenCallback,
        onCancel: NegativeActionCallback,
    ) {
        val preferred = DownloadManagerPreference.resolve(
            DownloadManagerPreference.read(context),
            apps.value,
        )
        if (preferred != null) {
            findDialog()?.dismissSilently()
            onAppChosen.value(preferred)
            return
        }

        if (fragmentManager.isDestroyed || fragmentManager.isStateSaved) {
            // The request stays pending on the tab. `DownloadsFeature` stops with
            // the fragment and offers the pending download again when it starts.
            return
        }

        val existing = findDialog()
        val dialog = when {
            existing == null -> DownloadAppChooserDialog.newInstance(apps.value)
            // The same request offered again: after the fragment was recreated,
            // or the feature restarted. The shown dialog keeps its state and
            // only needs the new callbacks.
            !existing.isSettled && existing.offers(apps.value) -> existing
            else -> {
                // A dialog for a request that has since been replaced. Its apps
                // carry the old download's URL, so they must not be offered for
                // this one.
                existing.dismissSilently()
                DownloadAppChooserDialog.newInstance(apps.value)
            }
        }

        dialog.onAppSelected = { app, remember ->
            if (remember) {
                DownloadManagerPreference.write(context, DownloadManagerPreference.Choice.of(app))
            }
            onAppChosen.value(app)
        }
        dialog.onCancelled = { onCancel.value() }

        if (!dialog.isAdded) {
            dialog.showNow(fragmentManager, DownloadAppChooserDialog.FRAGMENT_TAG)
        }
    }

    /**
     * Closes the chooser without answering it, for `DownloadsFeature`'s
     * navigation cleanup — which cancels the request itself, so answering it
     * here as well would cancel it twice.
     */
    fun dismiss() {
        findDialog()?.dismissSilently()
    }

    private fun findDialog(): DownloadAppChooserDialog? =
        fragmentManager.findFragmentByTag(DownloadAppChooserDialog.FRAGMENT_TAG)
            as? DownloadAppChooserDialog
}

/**
 * The chooser itself. Answers at most once: the app picked, or a cancel — never
 * both, never twice, and nothing when it is closed for it ([dismissSilently]) or
 * torn down with its host.
 *
 * The callbacks live on the instance and are lost when the fragment is
 * recreated; [DownloadAppChooser.show] sets them again when `DownloadsFeature`
 * re-offers the pending download, which it does whenever it starts.
 */
internal class DownloadAppChooserDialog : AppCompatDialogFragment() {
    var onAppSelected: ((app: DownloaderApp, remember: Boolean) -> Unit)? = null
    var onCancelled: (() -> Unit)? = null

    /** Whether this dialog has answered, or was closed without answering. */
    var isSettled = false
        private set

    private val apps: List<DownloaderApp>
        get() = requireArguments().getParcelableArrayListCompat(KEY_APPS, DownloaderApp::class.java)
            ?: emptyList()

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = Dialog(requireContext())
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        // As Mozilla's chooser: a stray tap beside it should not cancel a download.
        dialog.setCanceledOnTouchOutside(false)

        val binding = DialogDownloadAppChooserBinding.inflate(LayoutInflater.from(requireContext()))
        binding.appsList.adapter = DownloaderAppAdapter(requireContext(), apps) { app ->
            val remember = binding.alwaysUse.isChecked
            settle { onAppSelected?.invoke(app, remember) }
            dismissAllowingStateLoss()
        }
        binding.closeButton.setOnClickListener { dialog.cancel() }

        dialog.addContentView(
            binding.root,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )

        return dialog
    }

    /** Back, or the close button. */
    override fun onCancel(dialog: DialogInterface) {
        super.onCancel(dialog)
        settle { onCancelled?.invoke() }
    }

    fun offers(other: List<DownloaderApp>): Boolean =
        apps.map { it.identity } == other.map { it.identity }

    fun dismissSilently() {
        isSettled = true
        dismissAllowingStateLoss()
    }

    private inline fun settle(block: () -> Unit) {
        if (isSettled) return
        isSettled = true
        block()
    }

    /**
     * What makes two offers the same. Not [DownloaderApp.equals]: its
     * `ResolveInfo` compares by identity, and is a fresh object every time the
     * apps are queried.
     */
    private val DownloaderApp.identity
        get() = listOf(packageName, activityName, url, contentType)

    companion object {
        const val FRAGMENT_TAG = "WEBLIBRE_DOWNLOAD_APP_CHOOSER"
        private const val KEY_APPS = "apps"

        fun newInstance(apps: List<DownloaderApp>) = DownloadAppChooserDialog().apply {
            arguments = Bundle().apply { putParcelableArrayList(KEY_APPS, ArrayList(apps)) }
        }
    }
}
