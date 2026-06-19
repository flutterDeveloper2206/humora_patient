import 'package:intl/intl.dart';

import '../../data/models/healer_api_models.dart';
import '../../data/models/healer_model.dart';

class SlotDisplayItem {
  final String id;
  final String label;

  const SlotDisplayItem({required this.id, required this.label});
}

class SessionSlotUtils {
  static const int availabilityAllDays = 1;
  static const int availabilityWeekDays = 2;

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isPastDate(DateTime date) =>
      dateOnly(date).isBefore(dateOnly(DateTime.now()));

  static bool canNavigateToPreviousWeek(DateTime focused) {
    final previousFocus = dateOnly(focused).subtract(const Duration(days: 7));
    final week = weekDates(previousFocus);
    final today = dateOnly(DateTime.now());
    return week.any((d) => !dateOnly(d).isBefore(today));
  }

  static DateTime preferredDateInWeek(List<DateTime> weekDays) {
    final today = dateOnly(DateTime.now());
    for (final day in weekDays) {
      if (dateOnly(day) == today) {
        return day;
      }
    }
    for (final day in weekDays) {
      if (!dateOnly(day).isBefore(today)) {
        return day;
      }
    }
    return weekDays.last;
  }

  static String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static List<DateTime> weekDates(DateTime focused) {
    final monday = DateTime(focused.year, focused.month, focused.day)
        .subtract(Duration(days: focused.weekday - DateTime.monday));
    return List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
  }

  static List<SessionSlotItem> slotsForType(
    List<SessionSlotItem> rawSlots,
    SessionType type,
  ) {
    return rawSlots.where((s) => s.sessionType == type.value).toList();
  }

  /// Backend WeekDays: Monday=1 … Sunday=7 (same as [DateTime.weekday]).
  static bool _hasValidDayOfWeek(int dayOfWeek) =>
      dayOfWeek >= DateTime.monday && dayOfWeek <= DateTime.sunday;

  static bool slotAppliesOnDate(
    SessionSlotItem slot,
    SessionType type,
    DateTime date,
  ) {
    if (slot.sessionType != type.value) return false;

    // WeekDays — ignore [date]; recur every matching weekday.
    if (slot.availabilityType == availabilityWeekDays) {
      if (!_hasValidDayOfWeek(slot.dayOfWeek)) return false;
      return date.weekday == slot.dayOfWeek;
    }

    // AllDays — exact [date] only; null/empty date slots are hidden.
    if (slot.date.isEmpty) return false;
    return slot.date == dateKey(date);
  }

  static bool hasSlotsOnDate(
    List<SessionSlotItem> rawSlots,
    SessionType type,
    DateTime date,
  ) {
    return rawSlots.any((s) => slotAppliesOnDate(s, type, date));
  }

  static List<SessionSlotItem> slotsOnDate(
    List<SessionSlotItem> rawSlots,
    SessionType type,
    DateTime date,
  ) {
    return rawSlots
        .where((s) => slotAppliesOnDate(s, type, date))
        .toList();
  }

  static DateTime? firstDateWithSlots(
    List<SessionSlotItem> rawSlots,
    SessionType type, {
    DateTime? after,
  }) {
    final start = dateOnly(after ?? DateTime.now());
    for (var offset = 0; offset < 366; offset++) {
      final day = start.add(Duration(days: offset));
      if (hasSlotsOnDate(rawSlots, type, day)) return day;
    }
    return null;
  }

  static DateTime? firstDateInWeekWithSlots(
    List<SessionSlotItem> rawSlots,
    SessionType type,
    DateTime weekFocus,
  ) {
    for (final day in weekDates(weekFocus)) {
      if (hasSlotsOnDate(rawSlots, type, day)) return day;
    }
    return null;
  }

  static SessionType defaultSessionType(List<SessionSlotItem> rawSlots) {
    if (rawSlots.any((s) => s.sessionType == SessionType.personal.value)) {
      return SessionType.personal;
    }
    if (rawSlots.any((s) => s.sessionType == SessionType.group.value)) {
      return SessionType.group;
    }
    return SessionType.personal;
  }

  static int hourFromTime(String time) {
    try {
      return int.parse(time.split(':').first);
    } catch (_) {
      return 0;
    }
  }

  static String formatTimeRange(String start, String end) {
    String format(String timeStr) {
      try {
        final parts = timeStr.split(':');
        final h = int.parse(parts[0]);
        final m = parts.length > 1 ? parts[1] : '00';
        final ampm = h >= 12 ? 'PM' : 'AM';
        final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        return '${displayHour.toString().padLeft(2, '0')}:$m $ampm';
      } catch (_) {
        return timeStr;
      }
    }

    return '${format(start)} - ${format(end)}';
  }

  static String? categoryForHour(int hour) {
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  static List<String> availableCategoriesForDate(
    List<SessionSlotItem> rawSlots,
    SessionType type,
    DateTime date,
  ) {
    final slots = slotsOnDate(rawSlots, type, date);
    final categories = <String>{};
    for (final slot in slots) {
      final cat = categoryForHour(hourFromTime(slot.startTime));
      if (cat != null) categories.add(cat);
    }
    const order = ['Morning', 'Afternoon', 'Evening'];
    return order.where(categories.contains).toList();
  }

  static List<String> displaySlotsForCategory(
    List<SessionSlotItem> rawSlots,
    SessionType type,
    DateTime date,
    String category,
  ) {
    return displaySlotItemsForCategory(rawSlots, type, date, category)
        .map((item) => item.label)
        .toList();
  }

  static List<SlotDisplayItem> displaySlotItemsForCategory(
    List<SessionSlotItem> rawSlots,
    SessionType type,
    DateTime date,
    String category,
  ) {
    final seen = <String>{};
    return slotsOnDate(rawSlots, type, date)
        .where(
          (slot) =>
              categoryForHour(hourFromTime(slot.startTime)) == category,
        )
        .map(
          (slot) => SlotDisplayItem(
            id: slot.id,
            label: formatTimeRange(slot.startTime, slot.endTime),
          ),
        )
        .where((item) => seen.add(item.label))
        .toList();
  }
}
