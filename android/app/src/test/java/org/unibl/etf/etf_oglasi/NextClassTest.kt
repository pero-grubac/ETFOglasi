package org.unibl.etf.etf_oglasi

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class NextClassTest {

    private fun at(hours: Int, minutes: Int) = hours * 60 + minutes

    private val mjerenja = WidgetClass(at(9, 15), at(11, 0), "Mjerenja (svi)", "1103")
    private val kola = WidgetClass(at(11, 15), at(12, 0), "Kola (svi)", "1104")
    private val fizika = WidgetClass(at(8, 15), at(10, 0), "Fizika", null)

    /** Monday: two classes; Wednesday: one; the rest free. */
    private val week = mapOf(1 to listOf(mjerenja, kola), 3 to listOf(fizika))

    @Test
    fun beforeTheFirstClass() {
        val state = NextClass.find(week, weekday = 1, minute = at(8, 0))

        assertNull(state.current)
        assertEquals(mjerenja, state.next)
        assertEquals(0, state.nextInDays)
    }

    @Test
    fun duringAClass() {
        val state = NextClass.find(week, weekday = 1, minute = at(10, 0))

        assertEquals(mjerenja, state.current)
        assertEquals(kola, state.next)
        assertEquals(0, state.nextInDays)
    }

    @Test
    fun aClassEndsExactlyAtItsEndTime() {
        val state = NextClass.find(week, weekday = 1, minute = at(11, 0))

        assertNull(state.current)
        assertEquals(kola, state.next)
    }

    @Test
    fun lastClassOfTheDayPointsToALaterDay() {
        val state = NextClass.find(week, weekday = 1, minute = at(11, 30))

        assertEquals(kola, state.current)
        assertEquals(fizika, state.next)
        assertEquals(2, state.nextInDays)
        assertEquals(3, state.nextWeekday)
    }

    @Test
    fun theWeekendPointsToMonday() {
        // Saturday.
        val state = NextClass.find(week, weekday = 6, minute = at(12, 0))

        assertNull(state.current)
        assertEquals(mjerenja, state.next)
        assertEquals(2, state.nextInDays)
        assertEquals(1, state.nextWeekday)
    }

    @Test
    fun sundayEveningIsTheDayBeforeMonday() {
        val state = NextClass.find(week, weekday = 7, minute = at(20, 0))

        assertEquals(mjerenja, state.next)
        assertEquals(1, state.nextInDays)
    }

    @Test
    fun anEmptyScheduleHasNothing() {
        val state = NextClass.find(emptyMap(), weekday = 2, minute = at(9, 0))

        assertNull(state.current)
        assertNull(state.next)
    }

    @Test
    fun nextChangeIsTheNextStartOrEnd() {
        val today = listOf(mjerenja, kola)

        assertEquals(at(9, 15), NextClass.nextChange(today, at(8, 0)))
        assertEquals(at(11, 0), NextClass.nextChange(today, at(9, 15)))
        assertEquals(at(11, 15), NextClass.nextChange(today, at(11, 0)))
        assertNull(NextClass.nextChange(today, at(12, 0)))
    }

    @Test
    fun formatsTimes() {
        assertEquals("9:15", NextClass.formatTime(at(9, 15)))
        assertEquals("11:00", NextClass.formatTime(at(11, 0)))
    }
}
