/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.lock

import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.ContextWrapper
import android.view.View
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import java.util.Collections
import java.util.WeakHashMap

/**
 * An activity whose content the profile lock can cover.
 *
 * The lock panel is a view in the activity's content. A dialog or a popup is
 * a window of its own above that content, which no view can cover: a page's
 * `alert()`, a `<select>` list or a context menu would stay readable, and
 * answerable, over the lock. Whatever puts one up over such an activity keeps
 * it hidden while [isProfileLocked].
 */
interface ProfileLockedWindow {
    /** Whether the profile lock covers this window's content right now. */
    val isProfileLocked: Boolean

    /**
     * Keeps [dialog] hidden for as long as the lock is up, and shows it again
     * after. For a plain dialog, called after each `show()`; a
     * `DialogFragment` is covered without asking.
     */
    fun coverWhileLocked(dialog: Dialog)
}

/** See [ProfileLockedWindow.coverWhileLocked]; nothing over any other window. */
fun Dialog.coverWhileWindowLocked() {
    (context.findActivity() as? ProfileLockedWindow)?.coverWhileLocked(this)
}

private fun Context.findActivity(): Activity? {
    var context: Context? = this
    while (context != null) {
        if (context is Activity) return context
        context = (context as? ContextWrapper)?.baseContext
    }
    return null
}

/**
 * Hides the dialogs of a [ProfileLockedWindow] while it is locked.
 *
 * Hidden, not dismissed: dismissing answers a prompt (a `confirm()` returns
 * false, a permission is denied), while the person only left the window. A
 * hidden dialog is back where it was once the window is unlocked.
 *
 * Every `DialogFragment` in the activity, nested ones included, is covered on
 * its own: `DialogFragment.onStart` shows the dialog again, which covers a
 * dialog restored with the activity, one a page raises while the window is
 * locked, and each one again when the window comes back to the front. Plain
 * dialogs are handed in with [cover].
 *
 * [exempt] names the dialogs that belong to the lock itself: on API levels
 * before 28, the device prompt is a `DialogFragment` of the same activity.
 */
internal class LockedWindowCurtain(
    private val fragmentManager: FragmentManager,
    private val exempt: (DialogFragment) -> Boolean = ::isLockOwnDialog,
) {
    var isLocked = false
        private set

    /** Weak throughout: a dialog that went away is nothing to bring back. */
    private val hiddenFragments = weakSet<DialogFragment>()
    private val plainDialogs = weakSet<Dialog>()
    private val hiddenPlainDialogs = weakSet<Dialog>()

    init {
        fragmentManager.registerFragmentLifecycleCallbacks(
            object : FragmentManager.FragmentLifecycleCallbacks() {
                // Called after `onStart`, so after the dialog was shown, and
                // before anything is drawn: a dialog hidden here never shows.
                override fun onFragmentStarted(fm: FragmentManager, f: Fragment) {
                    if (isLocked && f is DialogFragment) hide(f)
                }

                override fun onFragmentDetached(fm: FragmentManager, f: Fragment) {
                    hiddenFragments.remove(f)
                }
            },
            true,
        )
    }

    fun lock() {
        if (isLocked) return
        isLocked = true

        dialogFragments(fragmentManager).forEach(::hide)
        plainDialogs.toList().forEach(::hide)
    }

    fun unlock() {
        if (!isLocked) return
        isLocked = false

        val fragments = hiddenFragments.toList()
        hiddenFragments.clear()
        for (fragment in fragments) {
            // One that is not started is shown by its own `onStart`.
            if (!fragment.isAdded) continue
            if (!fragment.lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)) continue
            fragment.dialog?.reveal()
        }

        val dialogs = hiddenPlainDialogs.toList()
        hiddenPlainDialogs.clear()
        dialogs.forEach { it.reveal() }
    }

    /**
     * Undoes `Dialog.hide()`, which only hides the dialog's view.
     *
     * Not `Dialog.show()`: for a dialog its owner dismissed while it was
     * hidden, that adds the window back, and brings back a prompt that was
     * already settled. A dismissed dialog's view is out of its window, so
     * this shows nothing. Whether it is still in one cannot be asked
     * instead: a dialog shown and hidden within a frame is not attached yet.
     */
    private fun Dialog.reveal() {
        window?.peekDecorView()?.visibility = View.VISIBLE
    }

    /** See [ProfileLockedWindow.coverWhileLocked]. */
    fun cover(dialog: Dialog) {
        plainDialogs.add(dialog)
        if (isLocked) hide(dialog)
    }

    private fun hide(fragment: DialogFragment) {
        if (exempt(fragment)) return
        val dialog = fragment.dialog ?: return
        if (!dialog.isShowing) return

        dialog.hide()
        hiddenFragments.add(fragment)
    }

    private fun hide(dialog: Dialog) {
        if (!dialog.isShowing) return

        dialog.hide()
        hiddenPlainDialogs.add(dialog)
    }

    private fun dialogFragments(manager: FragmentManager): List<DialogFragment> =
        manager.fragments.flatMap { fragment ->
            val nested = if (fragment.isAdded) dialogFragments(fragment.childFragmentManager) else emptyList()
            listOfNotNull(fragment as? DialogFragment) + nested
        }

    private companion object {
        fun <T> weakSet(): MutableSet<T> = Collections.newSetFromMap(WeakHashMap())

        fun isLockOwnDialog(fragment: DialogFragment): Boolean =
            fragment.javaClass.name.startsWith("androidx.biometric.")
    }
}
