package eu.weblibre.flutter_mozilla_components.middleware

import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.feature.addons.logger
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.MiddlewareContext

class SaveToPDFMiddleware : Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        context: MiddlewareContext<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
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
            else -> {
                next(action)
            }
        }
    }
}