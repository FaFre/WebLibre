package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoBrowserApi
import mozilla.components.browser.state.action.SystemAction
import mozilla.components.feature.addons.logger

/**
 * Implementation of GeckoBrowserApi that handles browser-related operations
 * @param showFragmentCallback Callback function to show native fragment
 */
class GeckoBrowserApiImpl(private val showFragmentCallback: () -> Boolean) : GeckoBrowserApi {
    companion object {
        private const val TAG = "GeckoBrowserApiImpl"
    }

    override fun showNativeFragment(): Boolean {
        try {
            return showFragmentCallback()
        } catch (e: Exception) {
            logger.error("Failed to show native fragment", e)
        }

        return false
    }

    override fun onTrimMemory(level: Long) {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }

        logger.debug("$TAG: onTrimMemory called with level: $level")

        with(GlobalComponents.components!!) {
            try {
                core.store.dispatch(SystemAction.LowMemoryAction(level.toInt()))
                core.icons.onTrimMemory(level.toInt())
            } catch (e: Exception) {
                logger.error("$TAG: Failed to handle memory trim", e)
            }
        }
    }
}
