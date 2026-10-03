package org.unibl.etf.etf_oglasi

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Typeface
import android.net.Uri
import android.os.Build
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.StyleSpan
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar
import java.util.TimeZone

/**
 * Small widget with the class going on now and the next one, from the saved
 * class schedule. The app stores each weekday's classes as JSON
 * (`widget_classes_1..5`) and the labels in the app's language; the widget
 * works out "now" and "next" itself and schedules its own redraw for the
 * next time a class starts or ends.
 */
class NextClassWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val now = Calendar.getInstance(FACULTY_TIME_ZONE)
        val weekday = (now.get(Calendar.DAY_OF_WEEK) + 5) % 7 + 1 // 1 = Monday … 7 = Sunday
        val minute = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)

        val classes = (1..5).associateWith {
            NextClass.parse(widgetData.getString("widget_classes_$it", null))
        }
        val (first, second) = if (widgetData.getBoolean("widget_has_schedule", false)) {
            val today = classes[weekday].orEmpty()
            lines(widgetData, NextClass.find(classes, weekday, minute), today.isEmpty())
        } else {
            Pair(widgetData.getString("widget_no_schedule", null) ?: "", null)
        }

        val launch = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("etfoglasi://class_schedule"),
        )
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.next_class_widget).apply {
                setTextViewText(R.id.next_class_now, first)
                if (second == null) {
                    setViewVisibility(R.id.next_class_next, View.GONE)
                } else {
                    setViewVisibility(R.id.next_class_next, View.VISIBLE)
                    setTextViewText(R.id.next_class_next, second)
                }
                setOnClickPendingIntent(R.id.next_class_root, launch)
            }
            appWidgetManager.updateAppWidget(id, views)
        }

        scheduleNextUpdate(context, now, NextClass.nextChange(classes[weekday].orEmpty(), minute))
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        alarmManager(context).cancel(updateIntent(context))
    }

    private fun lines(
        data: SharedPreferences,
        state: NowAndNext,
        freeDay: Boolean,
    ): Pair<CharSequence, CharSequence?> {
        fun label(key: String) = data.getString(key, null) ?: ""

        val current = state.current
        val first = if (current != null) {
            line("${label("widget_now")} · ${label("widget_until")} ${NextClass.formatTime(current.end)}", current)
        } else {
            val freeLater = state.next != null && state.nextInDays == 0
            label(
                when {
                    freeLater -> "widget_free"
                    freeDay -> "widget_no_classes_today"
                    else -> "widget_no_more_today"
                },
            )
        }

        val next = state.next ?: return Pair(first, null)
        val day = when (state.nextInDays) {
            0 -> label("widget_next")
            1 -> label("widget_tomorrow")
            else -> label("widget_title_${state.nextWeekday}")
        }
        return Pair(first, line("$day ${NextClass.formatTime(next.start)}", next))
    }

    /** `Label  Title · room`, with a lighter label and a bold title. */
    private fun line(label: String, item: WidgetClass): CharSequence {
        val text = SpannableStringBuilder()
        text.append(label, ForegroundColorSpan(LABEL_COLOR), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        text.append("  ")
        text.append(item.title, StyleSpan(Typeface.BOLD), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        item.room?.let { text.append(" · ").append(it) }
        return text
    }

    /**
     * Redraws at [changeMinute] today, or just after midnight. A non-waking
     * alarm: if the phone is asleep, the widget updates when it wakes up.
     */
    private fun scheduleNextUpdate(context: Context, now: Calendar, changeMinute: Int?) {
        val at = (now.clone() as Calendar).apply {
            set(Calendar.SECOND, 5)
            set(Calendar.MILLISECOND, 0)
            if (changeMinute != null) {
                set(Calendar.HOUR_OF_DAY, changeMinute / 60)
                set(Calendar.MINUTE, changeMinute % 60)
            } else {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 1)
            }
        }
        val manager = alarmManager(context)
        val intent = updateIntent(context)
        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || manager.canScheduleExactAlarms()
        if (exact) {
            manager.setExact(AlarmManager.RTC, at.timeInMillis, intent)
        } else {
            manager.set(AlarmManager.RTC, at.timeInMillis, intent)
        }
    }

    private fun alarmManager(context: Context) =
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    private fun updateIntent(context: Context): PendingIntent {
        val component = ComponentName(context, NextClassWidgetProvider::class.java)
        val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(component)
        val intent = Intent(context, NextClassWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private companion object {
        val FACULTY_TIME_ZONE: TimeZone = TimeZone.getTimeZone("Europe/Sarajevo")
        const val LABEL_COLOR = 0xCCFFFFFF.toInt()
    }
}
