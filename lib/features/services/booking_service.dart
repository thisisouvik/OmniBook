import '../models/booking.dart';
import '../models/slot_status.dart';

class BookingService {
  static const int _totalCounters = 3;
  static const int _openingHour = 9;
  static const int _closingHour = 18;

  BookingService() : existingBookings = _buildMockBookings();

  final List<Booking> existingBookings;

  int get totalCounters => _totalCounters;
  int get openingHour => _openingHour;
  int get closingHour => _closingHour;

  static List<Booking> _buildMockBookings() {
    final now = DateTime.now();

    DateTime atTime(int hour, int minute) {
      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    return <Booking>[
      Booking(counterId: 1, startTime: atTime(10, 0), endTime: atTime(11, 0)),
      Booking(counterId: 2, startTime: atTime(10, 30), endTime: atTime(11, 30)),
      Booking(counterId: 3, startTime: atTime(9, 0), endTime: atTime(10, 30)),
    ];
  }

  bool _overlaps(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    return s1.isBefore(e2) && e1.isAfter(s2);
  }

  DateTime openingTimeFor(DateTime date) {
    return DateTime(date.year, date.month, date.day, _openingHour, 0);
  }

  DateTime closingTimeFor(DateTime date) {
    return DateTime(date.year, date.month, date.day, _closingHour, 0);
  }

  bool isWithinBusinessHours(DateTime start, int duration) {
    final openingTime = openingTimeFor(start);
    final closingTime = closingTimeFor(start);
    final proposedEnd = start.add(Duration(minutes: duration));
    return !start.isBefore(openingTime) && !proposedEnd.isAfter(closingTime);
  }

  SlotStatus checkSlot(DateTime start, int duration) {
    final freeCounters = findFreeCounters(start, duration);
    return SlotStatus(
      isAvailable: freeCounters.isNotEmpty,
      freeCounters: freeCounters,
    );
  }

  List<DateTime> generateSlotsForDate(DateTime date) {
    final openingTime = openingTimeFor(date);
    final closingTime = closingTimeFor(date);
    final slots = <DateTime>[];

    var current = openingTime;
    while (!current.add(const Duration(minutes: 30)).isAfter(closingTime)) {
      slots.add(current);
      current = current.add(const Duration(minutes: 30));
    }

    return slots;
  }

  List<Booking> bookingsForDate(DateTime date) {
    return existingBookings.where((booking) {
      return booking.startTime.year == date.year &&
          booking.startTime.month == date.month &&
          booking.startTime.day == date.day;
    }).toList();
  }

  bool isCounterFree(int counterId, DateTime start, int duration) {
    if (!isWithinBusinessHours(start, duration)) {
      return false;
    }

    final proposedEnd = start.add(Duration(minutes: duration));
    for (final booking in existingBookings) {
      if (booking.counterId != counterId) {
        continue;
      }
      if (_overlaps(start, proposedEnd, booking.startTime, booking.endTime)) {
        return false;
      }
    }

    return true;
  }

  List<int> findFreeCounters(DateTime start, int duration) {
    if (!isWithinBusinessHours(start, duration)) {
      return <int>[];
    }

    final freeCounters = <int>[];
    for (var counterId = 1; counterId <= _totalCounters; counterId++) {
      if (isCounterFree(counterId, start, duration)) {
        freeCounters.add(counterId);
      }
    }
    return freeCounters;
  }

  DateTime? nextFreeStartForCounter(
    int counterId,
    DateTime date,
    int duration,
  ) {
    final slots = generateSlotsForDate(date);
    for (final slot in slots) {
      if (isCounterFree(counterId, slot, duration)) {
        return slot;
      }
    }
    return null;
  }

  int? findFreeCounter(DateTime start, int duration) {
    final freeCounters = findFreeCounters(start, duration);
    if (freeCounters.isEmpty) {
      return null;
    }
    return freeCounters.first;
  }
}
