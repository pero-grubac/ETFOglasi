package org.unibl.etf.etf_oglasi

import org.json.JSONArray

/** One class of a day; times are minutes after midnight. */
data class WidgetClass(val start: Int, val end: Int, val title: String, val room: String?)

/**
 * What the "next class" widget shows.
 *
 * @property current the class going on now, if any.
 * @property next the next class to start, possibly on a later day.
 * @property nextInDays 0 = today, 1 = tomorrow, …
 * @property nextWeekday weekday of [next], 1 = Monday … 5 = Friday.
 */
data class NowAndNext(
    val current: WidgetClass?,
    val next: WidgetClass?,
    val nextInDays: Int,
    val nextWeekday: Int,
)

object NextClass {

    /**
     * @param classesByWeekday classes of each weekday (1 = Monday … 5 = Friday), sorted.
     * @param weekday today, 1 = Monday … 7 = Sunday.
     * @param minute minutes after midnight now.
     */
    fun find(classesByWeekday: Map<Int, List<WidgetClass>>, weekday: Int, minute: Int): NowAndNext {
        val today = classesByWeekday[weekday].orEmpty()
        val current = today.firstOrNull { minute >= it.start && minute < it.end }
        today.firstOrNull { it.start > minute }?.let {
            return NowAndNext(current, it, 0, weekday)
        }
        for (days in 1..7) {
            val day = (weekday - 1 + days) % 7 + 1
            classesByWeekday[day].orEmpty().firstOrNull()?.let {
                return NowAndNext(current, it, days, day)
            }
        }
        return NowAndNext(current, null, 0, weekday)
    }

    /**
     * Minute of today when the widget has to change next (a class starts or
     * ends), or `null` when nothing changes before midnight.
     */
    fun nextChange(today: List<WidgetClass>, minute: Int): Int? =
        today.flatMap { listOf(it.start, it.end) }.filter { it > minute }.minOrNull()

    /** Parses the JSON the app stores: `[{"s":555,"e":660,"t":"…","r":"1103"}]`. */
    fun parse(json: String?): List<WidgetClass> {
        if (json.isNullOrBlank()) return emptyList()
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { i ->
                val item = array.getJSONObject(i)
                WidgetClass(
                    start = item.getInt("s"),
                    end = item.getInt("e"),
                    title = item.getString("t"),
                    room = if (item.isNull("r")) null else item.optString("r"),
                )
            }.sortedBy { it.start }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /** `9:15`, `11:00`. */
    fun formatTime(minute: Int): String = "%d:%02d".format(minute / 60, minute % 60)
}
