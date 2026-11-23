package eu.weblibre.flutter_mozilla_components.middleware

import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.feature.addons.logger
import eu.weblibre.flutter_mozilla_components.lifecycle.PageOutputTracker
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Logs PDF saves and prints, and tells [outputs] which tabs have one running, so
 * a tab is not put to sleep in the middle of one.
 */
class SaveToPDFMiddleware(
    private val outputs: PageOutputTracker = PageOutputTracker(),
) : Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        outputs.onAction(store.state, action)
        when (action) {
            is EngineAction.SaveToPdfAction -> {
                // Continue to generate the PDF, passing through here to add telemetry
                next(action)
            }
            is EngineAction.SaveToPdfCompleteAction -> {
                logger.info("Saved PDF successfully")
            }
            is EngineAction.SaveToPdfExceptionAction -> {
                logger.error("Unable to save PDF", action.throwable)
            }
            is EngineAction.PrintContentAction -> {
                next(action)
            }
            is EngineAction.PrintContentCompletedAction -> {
                logger.info("Print completed successfully")
            }
            is EngineAction.PrintContentExceptionAction -> {
                logger.error("Unable to print content", action.throwable)
            }
            else -> {
                next(action)
            }
        }
    }
}