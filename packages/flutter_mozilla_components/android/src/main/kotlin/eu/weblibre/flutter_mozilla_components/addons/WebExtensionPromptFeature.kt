/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import androidx.annotation.VisibleForTesting
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.FragmentManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.mapNotNull
import mozilla.components.browser.state.action.WebExtensionAction
import mozilla.components.browser.state.state.extension.WebExtensionPromptRequest
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.webextension.PermissionPromptResponse
import mozilla.components.concept.engine.webextension.WebExtensionInstallException
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.ui.AddonInstallationDialogFragment
import mozilla.components.feature.addons.ui.PermissionsDialogFragment
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.ktx.android.content.appVersionName
import mozilla.components.ui.widgets.withCenterAlignedButtons
import eu.weblibre.flutter_mozilla_components.R
import mozilla.components.feature.addons.R as MozComp

/**
 * Feature implementation for handling [WebExtensionPromptRequest] and showing the respective UI.
 */
class WebExtensionPromptFeature(
    private val store: BrowserStore,
    private val context: Context,
    private val fragmentManager: FragmentManager,
) : LifecycleAwareFeature {

    /**
     * Whether or not an add-on installation is in progress.
     */
    private var isInstallationInProgress = false
    private var scope: CoroutineScope? = null

    /**
     * Starts observing the selected session to listen for window requests
     * and opens / closes tabs as needed.
     */
    override fun start() {
        scope = store.flowScoped { flow ->
            flow.mapNotNull { state ->
                state.webExtensionPromptRequest
            }.distinctUntilChanged().collect { promptRequest ->
                when (promptRequest) {
                    is WebExtensionPromptRequest.AfterInstallation -> {
                        handleAfterInstallationRequest(promptRequest)
                    }

                    is WebExtensionPromptRequest.BeforeInstallation.InstallationFailed -> {
                        handleBeforeInstallationRequest(promptRequest)
                        consumePromptRequest()
                    }
                }
            }
        }
        tryToReAttachButtonHandlersToPreviousDialog()
    }

    private fun handleAfterInstallationRequest(promptRequest: WebExtensionPromptRequest.AfterInstallation) {
        // The install flow in Fenix relies on an [Addon] object so let's convert the (GeckoView)
        // extension into a minimal add-on. The missing metadata will be fetched when the user
        // opens the add-ons manager.
        val addon = Addon.newFromWebExtension(promptRequest.extension)
        when (promptRequest) {
            is WebExtensionPromptRequest.AfterInstallation.Permissions.Required -> handlePermissionRequest(
                addon,
                promptRequest,
            )

            is WebExtensionPromptRequest.AfterInstallation.PostInstallation -> handlePostInstallationRequest(
                addon,
            )

            is WebExtensionPromptRequest.AfterInstallation.Permissions.Optional -> handleOptionalPermissionsRequest(
                addon,
                promptRequest,
            )
        }
    }

    private fun handlePostInstallationRequest(
        addon: Addon,
    ) {
        showPostInstallationDialog(addon)
    }

    private fun handlePermissionRequest(
        addon: Addon,
        promptRequest: WebExtensionPromptRequest.AfterInstallation.Permissions.Required,
    ) {
        if (hasExistingPermissionDialogFragment()) return
        showPermissionDialog(
            addon = addon,
            promptRequest = promptRequest,
            permissions = promptRequest.permissions,
            origins = promptRequest.origins,
        )
    }

    private fun handleOptionalPermissionsRequest(
        addon: Addon,
        promptRequest: WebExtensionPromptRequest.AfterInstallation.Permissions.Optional,
    ) {
        val shouldGrantWithoutPrompt = Addon.localizePermissions(promptRequest.permissions, context).isEmpty()

        // If we don't have any promptable permissions, just proceed.
        if (shouldGrantWithoutPrompt) {
            promptRequest.onConfirm(true)
            consumePromptRequest()
            return
        }

        showPermissionDialog(
            // This is a bit of a hack so that the permission prompt only lists
            // the optional permissions that are requested.
            addon = addon.copy(permissions = promptRequest.permissions),
            promptRequest = promptRequest,
            permissions = promptRequest.permissions,
            forOptionalPermissions = true,
        )
    }

    private fun showPostInstallationDialog(addon: Addon) {
        if (!isInstallationInProgress && !hasExistingAddonPostInstallationDialogFragment()) {
            val dialog = AddonInstallationDialogFragment.newInstance(
                addon = addon,
                onDismissed = {
                    consumePromptRequest()
                },
                onConfirmButtonClicked = { _ ->
                    consumePromptRequest()
                },
            )
            dialog.show(fragmentManager, POST_INSTALLATION_DIALOG_FRAGMENT_TAG)
        }
    }

    /**
     * Stops observing the selected session for incoming window requests.
     */
    override fun stop() {
        scope?.cancel()
    }

    @VisibleForTesting
    internal fun showPermissionDialog(
        addon: Addon,
        promptRequest: WebExtensionPromptRequest.AfterInstallation.Permissions,
        permissions: List<String> = emptyList(),
        origins: List<String> = emptyList(),
        forOptionalPermissions: Boolean = false,
    ) {
        if (!isInstallationInProgress && !hasExistingPermissionDialogFragment()) {
            val dialog = PermissionsDialogFragment.newInstance(
                addon = addon,
                permissions = permissions,
                origins = origins,
//                dataCollectionPermissions = emptyList(),
                forOptionalPermissions = forOptionalPermissions,
//                onPositiveButtonClicked = { _, privateBrowsingAllowed, _ ->
                onPositiveButtonClicked = { _, privateBrowsingAllowed, ->
                    handlePermissions(
                        promptRequest,
                        granted = true,
                        privateBrowsingAllowed = privateBrowsingAllowed,
                    )
                },
                onNegativeButtonClicked = {
                    when (promptRequest) {
                        is WebExtensionPromptRequest.AfterInstallation.Permissions.Optional -> {
                            promptRequest.onConfirm(false)
                        }

                        is WebExtensionPromptRequest.AfterInstallation.Permissions.Required -> {
                            promptRequest.onConfirm(PermissionPromptResponse(isPermissionsGranted = false))
                        }
                    }
                    consumePromptRequest()
                },
            )
            dialog.show(
                fragmentManager,
                PERMISSIONS_DIALOG_FRAGMENT_TAG,
            )
        }
    }

    private fun tryToReAttachButtonHandlersToPreviousDialog() {
        findPreviousDialogFragment()?.let { dialog ->
//            dialog.onPositiveButtonClicked = { addon, privateBrowsingAllowed, _ ->
            dialog.onPositiveButtonClicked = { addon, privateBrowsingAllowed ->
                store.state.webExtensionPromptRequest?.let { promptRequest ->
                    if (promptRequest is WebExtensionPromptRequest.AfterInstallation.Permissions &&
                        addon.id == promptRequest.extension.id
                    ) {
                        handlePermissions(
                            promptRequest,
                            granted = true,
                            privateBrowsingAllowed = privateBrowsingAllowed,
                        )
                    }
                }
            }
            dialog.onNegativeButtonClicked = {
                store.state.webExtensionPromptRequest?.let { promptRequest ->
                    handlePermissions(
                        promptRequest,
                        granted = false,
                        privateBrowsingAllowed = false,
                    )
                }
            }
        }
    }

    private fun handlePermissions(
        promptRequest: WebExtensionPromptRequest,
        granted: Boolean,
        privateBrowsingAllowed: Boolean,
    ) {
        when (promptRequest) {
            is WebExtensionPromptRequest.AfterInstallation.Permissions.Optional -> {
                promptRequest.onConfirm(granted)
            }

            is WebExtensionPromptRequest.AfterInstallation.Permissions.Required -> {
                val response = PermissionPromptResponse(
                    isPermissionsGranted = granted,
                    isPrivateModeGranted = privateBrowsingAllowed,
                )
                promptRequest.onConfirm(response)
            }

            is WebExtensionPromptRequest.AfterInstallation.PostInstallation -> {
                // opt-out
            }

            is WebExtensionPromptRequest.BeforeInstallation.InstallationFailed -> {
                // opt-out
            }
        }
        consumePromptRequest()
    }

    private fun consumePromptRequest() {
        store.dispatch(WebExtensionAction.ConsumePromptRequestWebExtensionAction)
    }

    private fun hasExistingPermissionDialogFragment(): Boolean {
        return findPreviousDialogFragment() != null
    }

    private fun findPreviousDialogFragment(): PermissionsDialogFragment? {
        return fragmentManager.findFragmentByTag(PERMISSIONS_DIALOG_FRAGMENT_TAG) as? PermissionsDialogFragment
    }

    private fun hasExistingAddonPostInstallationDialogFragment(): Boolean {
        return fragmentManager.findFragmentByTag(POST_INSTALLATION_DIALOG_FRAGMENT_TAG)
            as? AddonInstallationDialogFragment != null
    }

    private fun handleBeforeInstallationRequest(promptRequest: WebExtensionPromptRequest.BeforeInstallation) {
        when (promptRequest) {
            is WebExtensionPromptRequest.BeforeInstallation.InstallationFailed -> {
                handleInstallationFailedRequest(
                    exception = promptRequest.exception,
                )
                consumePromptRequest()
            }
        }
    }

    @VisibleForTesting
    internal fun handleInstallationFailedRequest(
        exception: WebExtensionInstallException,
    ) {
        val addonName = exception.extensionName ?: ""
        var title = context.getString(MozComp.string.mozac_feature_addons_cant_install_extension, "")
        val message = when (exception) {
            is WebExtensionInstallException.Blocklisted -> {
                context.getString(MozComp.string.mozac_feature_addons_blocklisted_2, addonName)
            }

            is WebExtensionInstallException.SoftBlocked -> {
                context.getString(MozComp.string.mozac_feature_addons_soft_blocked_1, addonName)
            }

            is WebExtensionInstallException.UserCancelled -> {
                // We don't want to show an error message when users cancel installation.
                return
            }

            is WebExtensionInstallException.UnsupportedAddonType,
            is WebExtensionInstallException.Unknown,
            -> {
                // Making sure we don't have a
                // Title = Can't install extension
                // Message = Failed to install $addonName
                title = ""
                if (addonName.isNotEmpty()) {
                    context.getString(MozComp.string.mozac_feature_addons_failed_to_install, addonName)
                } else {
                    context.getString(MozComp.string.mozac_feature_addons_extension_failed_to_install)
                }
            }

            is WebExtensionInstallException.NetworkFailure -> {
                context.getString(MozComp.string.mozac_feature_addons_extension_failed_to_install_network_error)
            }

            is WebExtensionInstallException.CorruptFile -> {
                context.getString(MozComp.string.mozac_feature_addons_extension_failed_to_install_corrupt_error)
            }

            is WebExtensionInstallException.NotSigned -> {
                context.getString(
                    MozComp.string.mozac_feature_addons_extension_failed_to_install_not_signed_error,
                )
            }

            is WebExtensionInstallException.Incompatible -> {
                val appName = "WebLibre"
                val version = context.appVersionName
                context.getString(
                    MozComp.string.mozac_feature_addons_failed_to_install_incompatible_error,
                    addonName,
                    appName,
                    version,
                )
            }

            is WebExtensionInstallException.AdminInstallOnly -> {
                context.getString(MozComp.string.mozac_feature_addons_admin_install_only, addonName)
            }
        }

        showDialog(
            title = title,
            message = message,
        )
    }

    @VisibleForTesting
    internal fun showDialog(
        title: String,
        message: String,
    ) {
        context.let {
            AlertDialog.Builder(it).setTitle(title)
                .setPositiveButton(android.R.string.ok) { _, _ -> }.setCancelable(false).setMessage(
                    message,
                ).show().withCenterAlignedButtons()
        }
    }

    companion object {
        private const val PERMISSIONS_DIALOG_FRAGMENT_TAG = "ADDONS_PERMISSIONS_DIALOG_FRAGMENT"
        private const val POST_INSTALLATION_DIALOG_FRAGMENT_TAG =
            "ADDONS_INSTALLATION_DIALOG_FRAGMENT"
    }
}
