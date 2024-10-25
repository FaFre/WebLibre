package eu.lensai.flutter_mozilla_components.feature

import android.util.Patterns
import eu.lensai.flutter_mozilla_components.pigeons.CustomSelectionAction
import eu.lensai.flutter_mozilla_components.pigeons.GeckoSelectionActionEvents
import eu.lensai.flutter_mozilla_components.pigeons.SelectionPattern
import mozilla.components.concept.engine.selection.SelectionActionDelegate

class DefaultSelectionActionDelegate(
    private val selectionActionEvents: GeckoSelectionActionEvents,
    private val actionSorter: ((Array<String>) -> Array<String>)? = null,
) : SelectionActionDelegate {
    var actions: Map<String, CustomSelectionAction> = emptyMap();

    override fun getActionTitle(id: String): CharSequence? {
        return actions[id]?.title;
    }

    override fun getAllActions(): Array<String> {
        return actions.values.map { x -> x.id }.toTypedArray();
    }

    override fun isActionAvailable(id: String, selectedText: String): Boolean {
        val action = actions[id];
        if (action != null) {
            return when(action.pattern) {
                SelectionPattern.PHONE -> Patterns.PHONE.matcher(selectedText.trim()).matches()
                SelectionPattern.EMAIL -> Patterns.EMAIL_ADDRESS.matcher(selectedText.trim()).matches()
                null -> true
            }
        }

        return false
    }

    override fun performAction(id: String, selectedText: String): Boolean {
        val action = actions[id];
        if (action != null) {
            selectionActionEvents.performSelectionAction(id, selectedText) { _ -> }
            return true
        }

        return false
    }

    override fun sortedActions(actions: Array<String>): Array<String> {
        return actionSorter?.invoke(actions) ?: actions
    }
}
