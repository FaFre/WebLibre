package eu.weblibre.gecko

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.net.toUri
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.wrapContentHeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle

class SearchBarGlanceWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            // Glance's default color providers are backed by day/night (and, on
            // Android 12+, dynamic) color resources, so the launcher resolves
            // them against its own configuration. Everything the widget paints
            // has to come from a resource for that to hold — see
            // values/widget_colors.xml.
            GlanceTheme {
                SearchBarContent(context)
            }
        }
    }
}

@Composable
private fun SearchBarContent(context: Context) {
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .wrapContentHeight()
            .background(ImageProvider(R.drawable.search_text_field))
            .padding(12.dp)
            .clickable(onClick = actionStartSearch(context)),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Start icon
        Image(
            provider = ImageProvider(R.drawable.icon_with_size),
            contentDescription = "Search icon",
            modifier = GlanceModifier.padding(end = 8.dp)
        )

        // Search text
        Text(
            text = "Search with WebLibre...",
            style = TextStyle(
                // Matches @color/widget_search_field_hint, which tints the
                // microphone; keep the two in step. On Android 12+ this is
                // resolved by the launcher, so it tracks a theme switch with no
                // widget update at all; below that Glance bakes in the color the
                // app process saw when the widget was last composed.
                color = GlanceTheme.colors.onSurfaceVariant,
                fontSize = 16.sp
            ),
            maxLines = 1,
            modifier = GlanceModifier.defaultWeight()
        )

        // End icon (microphone)
        Image(
            provider = ImageProvider(R.drawable.mdi_icon_microphone_tint),
            contentDescription = "Microphone icon",
            modifier = GlanceModifier.padding(start = 8.dp)
        )
    }
}

private fun actionStartSearch(context: Context): Action {
    val intent = Intent(context, MainActivity::class.java)
    intent.data = "widget://search".toUri()
    intent.action = HOME_WIDGET_LAUNCH_ACTION

    return actionStartActivity(intent)
}

class SearchBarWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = SearchBarGlanceWidget()
}

private const val HOME_WIDGET_LAUNCH_ACTION = "es.antonborri.home_widget.action.LAUNCH"
