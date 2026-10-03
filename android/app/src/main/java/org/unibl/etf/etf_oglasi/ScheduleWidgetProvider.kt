package org.unibl.etf.etf_oglasi

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar
import java.util.TimeZone

/**
 * Home screen widget with the day's classes from the saved class schedule.
 *
 * The app stores the text of every weekday (`widget_title_1..5`,
 * `widget_body_1..5`); the widget picks today's, so it moves to the next day
 * on its own (it is updated every 30 minutes). On weekends it shows Monday.
 */
class ScheduleWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val calendar = Calendar.getInstance(TimeZone.getTimeZone("Europe/Sarajevo"))
        val day = when (val weekday = calendar.get(Calendar.DAY_OF_WEEK)) {
            Calendar.SATURDAY, Calendar.SUNDAY -> 1
            else -> weekday - Calendar.MONDAY + 1
        }

        val hasSchedule = widgetData.getBoolean("widget_has_schedule", false)
        val title = widgetData.getString("widget_title_$day", null)
            ?: context.getString(R.string.schedule_widget_label)
        val body = when {
            !hasSchedule -> widgetData.getString("widget_no_schedule", null)
            else -> widgetData.getString("widget_body_$day", null)
                ?.takeIf { it.isNotBlank() }
                ?: widgetData.getString("widget_no_classes", null)
        } ?: context.getString(R.string.schedule_widget_description)

        val launch = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("etfoglasi://class_schedule"),
        )

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.schedule_widget).apply {
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_body, body)
                setOnClickPendingIntent(R.id.widget_root, launch)
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
