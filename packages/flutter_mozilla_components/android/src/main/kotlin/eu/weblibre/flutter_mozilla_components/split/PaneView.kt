/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.widget.TooltipCompat
import com.google.android.material.button.MaterialButton
import com.mikepenz.iconics.IconicsDrawable
import com.mikepenz.iconics.typeface.library.community.material.CommunityMaterial
import com.mikepenz.iconics.utils.sizeDp
import eu.weblibre.flutter_mozilla_components.ext.forEachSurfaceView
import eu.weblibre.flutter_mozilla_components.widget.ZoomAwareSwipeRefreshLayout
import java.lang.ref.WeakReference
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.support.base.feature.LifecycleAwareFeature

/**
 * One page slot of the split layout: a pull-to-refresh layout around an
 * [EngineView], the focus outline, and the crashed-page placeholder.
 *
 * A pane keeps two separate facts. [boundTabId] is the tab the pane is for,
 * and [attachedSession] is the engine session its view actually renders. They
 * differ while a session is still being created for a newly bound tab, and
 * when a tab's session is replaced under the same id (suspend and restore, a
 * crash restore). The coordinator re-renders whenever they disagree, which is
 * what AC's `EngineViewPresenter` does for the single view.
 */
@SuppressLint("ViewConstructor")
class PaneView(
    context: Context,
    val engineView: EngineView,
) : FrameLayout(context) {
    val swipeRefresh = ZoomAwareSwipeRefreshLayout(context)

    private val _boundTabId = MutableStateFlow<String?>(null)

    /** The tab this pane shows, as a flow for the per-pane features. */
    val boundTabIdFlow: StateFlow<String?> = _boundTabId.asStateFlow()

    var boundTabId: String?
        get() = _boundTabId.value
        set(value) {
            _boundTabId.value = value
        }

    var attachedSession: EngineSession? = null
        private set

    /** Features bound to this pane (its pull-to-refresh), started with the panes. */
    var features: List<LifecycleAwareFeature> = emptyList()

    /** Called when input focus enters this pane by any path. */
    var onFocusEntered: ((PaneView) -> Unit)? = null

    private val outline = GradientDrawable().apply {
        setColor(Color.TRANSPARENT)
    }
    private var outlineColor: Int? = null

    private var placeholder: LinearLayout? = null
    private var placeholderTitle: TextView? = null
    private var placeholderButton: MaterialButton? = null
    private var placeholderReloadLabel = ""

    /** Whether the placeholder is laid out as a lone reload icon; null before it exists. */
    private var placeholderCompact: Boolean? = null

    /** The surface views this pane hid, so showing it again lifts those only. */
    private val hiddenSurfaces = mutableListOf<WeakReference<View>>()

    /** Whether the layout currently shows this pane. */
    var isPaneShown: Boolean = true
        private set

    init {
        swipeRefresh.addView(
            engineView.asView(),
            LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT),
        )
        addView(
            swipeRefresh,
            LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT),
        )
        foreground = outline
        outline.alpha = 0
    }

    /** Renders [session] in this pane's view. The caller released it elsewhere first. */
    fun attach(session: EngineSession) {
        engineView.render(session)
        attachedSession = session
    }

    /** Releases whatever session this pane's view renders. */
    fun detach() {
        if (attachedSession != null) {
            engineView.release()
        }
        attachedSession = null
    }

    /** Draws the focus outline in [color], or hides it for null. */
    fun setFocusOutline(color: Int?) {
        if (color == outlineColor) return
        outlineColor = color
        if (color == null) {
            outline.alpha = 0
        } else {
            outline.setStroke(dp(OUTLINE_DP), color)
            outline.alpha = 255
        }
        invalidate()
    }

    /**
     * Shows or hides the pane. Hiding sets the pane's surface views GONE
     * themselves: ancestor visibility does not reliably retire a surface
     * layer, and a stale page would otherwise stay on screen. The session
     * stays bound, so showing the pane again needs no reload.
     *
     * Hiding takes every surface that is not GONE, including one
     * `EngineViewVisibility` already made INVISIBLE behind a covering route:
     * that one only lifts views still INVISIBLE, so a GONE surface stays
     * hidden when the route goes away, as long as this pane is hidden.
     * Showing lifts only what this hid. If the host is still hidden then,
     * `EngineViewVisibility` re-hides the surface on the layout pass this
     * causes, before it draws.
     */
    fun setPaneShown(shown: Boolean) {
        if (shown == isPaneShown) return
        isPaneShown = shown

        if (shown) {
            hiddenSurfaces.forEach { reference ->
                val view = reference.get() ?: return@forEach
                if (view.visibility == View.GONE) {
                    view.visibility = View.VISIBLE
                }
            }
            hiddenSurfaces.clear()
            visibility = View.VISIBLE
        } else {
            visibility = View.GONE
            hideSurfaces()
        }
    }

    private fun hideSurfaces() {
        forEachSurfaceView(this) { surface ->
            if (surface.visibility != View.GONE) {
                surface.visibility = View.GONE
                hiddenSurfaces += WeakReference(surface)
            }
        }
    }

    /** Re-hides a surface attached while the pane is hidden (a new session's view). */
    fun refreshHiddenSurfaces() {
        if (isPaneShown) return
        hideSurfaces()
    }

    fun showCrashPlaceholder(
        title: String,
        reload: String,
        backgroundColor: Int,
        foregroundColor: Int,
        onReload: () -> Unit,
    ) {
        val view = placeholder ?: createPlaceholder().also { placeholder = it }
        view.setBackgroundColor(backgroundColor)
        placeholderTitle?.apply {
            text = title
            setTextColor(foregroundColor)
        }
        placeholderReloadLabel = reload
        placeholderButton?.apply {
            contentDescription = reload
            setOnClickListener { onReload() }
        }
        // Re-applies the label in whichever form the current size uses.
        placeholderCompact = null
        updatePlaceholderMode(width, height)
        view.visibility = View.VISIBLE
        swipeRefresh.visibility = View.INVISIBLE
    }

    fun hideCrashPlaceholder() {
        val view = placeholder ?: return
        if (view.visibility == View.GONE) return
        view.visibility = View.GONE
        swipeRefresh.visibility = View.VISIBLE
    }

    val isShowingCrashPlaceholder: Boolean
        get() = placeholder?.visibility == View.VISIBLE

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        // Before the children are measured, so they are measured in the
        // mode this size calls for.
        updatePlaceholderMode(
            MeasureSpec.getSize(widthMeasureSpec),
            MeasureSpec.getSize(heightMeasureSpec),
        )
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
    }

    /**
     * A pane the user dragged down to a sliver has no room for the title and
     * a labeled button: it gets a lone reload icon instead, which still fits
     * the 48dp drag minimum.
     */
    private fun updatePlaceholderMode(width: Int, height: Int) {
        val column = placeholder ?: return
        val title = placeholderTitle ?: return
        val button = placeholderButton ?: return
        // Not measured yet: lay out in full until the size is known.
        val compact = width > 0 && height > 0 &&
            (width < dp(PLACEHOLDER_FULL_WIDTH_DP) || height < dp(PLACEHOLDER_FULL_HEIGHT_DP))
        if (compact == placeholderCompact) return
        placeholderCompact = compact

        if (compact) {
            column.setPadding(0, 0, 0, 0)
            title.visibility = View.GONE
            (button.layoutParams as LinearLayout.LayoutParams).topMargin = 0
            button.text = null
            // Tinted by the button's iconTint, like a labeled button's text.
            button.icon = IconicsDrawable(context, CommunityMaterial.Icon3.cmd_refresh).apply {
                sizeDp = RELOAD_ICON_DP
            }
            button.iconPadding = 0
            button.iconGravity = MaterialButton.ICON_GRAVITY_TEXT_START
            button.minWidth = dp(MIN_TOUCH_DP)
            button.minimumWidth = dp(MIN_TOUCH_DP)
            button.minHeight = dp(MIN_TOUCH_DP)
            button.minimumHeight = dp(MIN_TOUCH_DP)
            button.insetTop = 0
            button.insetBottom = 0
            button.setPadding(0, 0, 0, 0)
            TooltipCompat.setTooltipText(button, placeholderReloadLabel)
        } else {
            val padding = dp(PLACEHOLDER_PADDING_DP)
            column.setPadding(padding, padding, padding, padding)
            title.visibility = View.VISIBLE
            (button.layoutParams as LinearLayout.LayoutParams).topMargin = dp(PLACEHOLDER_GAP_DP)
            button.icon = null
            button.text = placeholderReloadLabel
            button.setPaddingRelative(
                buttonDefaults.paddingStart,
                buttonDefaults.paddingTop,
                buttonDefaults.paddingEnd,
                buttonDefaults.paddingBottom,
            )
            button.minWidth = buttonDefaults.minWidth
            button.minimumWidth = buttonDefaults.minWidth
            button.minHeight = buttonDefaults.minHeight
            button.minimumHeight = buttonDefaults.minHeight
            button.insetTop = buttonDefaults.insetTop
            button.insetBottom = buttonDefaults.insetBottom
            TooltipCompat.setTooltipText(button, null)
        }
    }

    /** The labeled button's style values, restored when the pane grows again. */
    private class ButtonDefaults(button: MaterialButton) {
        val paddingStart = button.paddingStart
        val paddingTop = button.paddingTop
        val paddingEnd = button.paddingEnd
        val paddingBottom = button.paddingBottom
        val minWidth = button.minWidth
        val minHeight = button.minHeight
        val insetTop = button.insetTop
        val insetBottom = button.insetBottom
    }

    private lateinit var buttonDefaults: ButtonDefaults

    private fun createPlaceholder(): LinearLayout {
        val title = TextView(context).apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
            gravity = Gravity.CENTER
        }
        val button = MaterialButton(context)
        buttonDefaults = ButtonDefaults(button)
        val column = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val padding = dp(PLACEHOLDER_PADDING_DP)
            setPadding(padding, padding, padding, padding)
            addView(
                title,
                LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                ),
            )
            addView(
                button,
                LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                ).apply { topMargin = dp(PLACEHOLDER_GAP_DP) },
            )
            // Consumes touches, so the page behind it never gets one.
            isClickable = true
        }
        placeholderTitle = title
        placeholderButton = button
        addView(
            column,
            LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT),
        )
        return column
    }

    override fun requestChildFocus(child: View?, focused: View?) {
        super.requestChildFocus(child, focused)
        onFocusEntered?.invoke(this)
    }

    private fun dp(value: Float): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, resources.displayMetrics).toInt()

    companion object {
        const val OUTLINE_DP = 2f

        private const val PLACEHOLDER_PADDING_DP = 24f
        private const val PLACEHOLDER_GAP_DP = 16f
        private const val MIN_TOUCH_DP = 48f
        private const val RELOAD_ICON_DP = 24

        /**
         * Below this the title and the labeled button do not fit: two 24dp
         * paddings around a button at least 88dp wide, and around an 18sp
         * title, a 16dp gap and a 48dp button.
         */
        private const val PLACEHOLDER_FULL_WIDTH_DP = 160f
        private const val PLACEHOLDER_FULL_HEIGHT_DP = 160f
    }
}
