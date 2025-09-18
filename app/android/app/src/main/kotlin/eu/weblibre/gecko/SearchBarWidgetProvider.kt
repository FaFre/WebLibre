package eu.weblibre.gecko

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.wrapContentHeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import android.net.Uri
import es.antonborri.home_widget.actionStartActivity
import androidx.core.net.toUri

class SearchBarGlanceWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            SearchBarContent(context)
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
            .clickable(onClick = actionStartActivity<MainActivity>(context,
                "widget://search".toUri())),
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
                color = ColorProvider(Color(0xFF848388)),
                fontSize = 16.sp
            ),
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

class SearchBarWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = SearchBarGlanceWidget()
}
