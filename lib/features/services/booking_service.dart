import '../models/booking.dart';
import '../models/slot_status.dart';

class BookingService {
	static const int _totalCounters = 3;
	static const int _openingHour = 9;
	static const int _closingHour = 18;

	BookingService() : existingBookings = _buildMockBookings();

	final List<Booking> existingBookings;

	static List<Booking> _buildMockBookings() {
		final now = DateTime.now();

		DateTime atTime(int hour, int minute) {
			return DateTime(now.year, now.month, now.day, hour, minute);
		}

		return <Booking>[
			Booking(
				counterId: 1,
				startTime: atTime(10, 0),
				endTime: atTime(11, 0),
			),
			Booking(
				counterId: 2,
				startTime: atTime(10, 30),
				endTime: atTime(11, 30),
			),
			Booking(
				counterId: 3,
				startTime: atTime(9, 0),
				endTime: atTime(10, 30),
			),
		];
	}

	bool _overlaps(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
		return s1.isBefore(e2) && e1.isAfter(s2);
	}

	SlotStatus checkSlot(DateTime start, int duration) {
		final freeCounter = findFreeCounter(start, duration);
		if (freeCounter != null) {
			return SlotStatus(isAvailable: true, freeCounters: <int>[freeCounter]);
		}

		return SlotStatus(isAvailable: false, freeCounters: <int>[]);
	}

	List<DateTime> generateSlots() {
		final now = DateTime.now();
		final openingTime = DateTime(now.year, now.month, now.day, _openingHour, 0);
		final closingTime = DateTime(now.year, now.month, now.day, _closingHour, 0);
		final slots = <DateTime>[];

		var current = openingTime;
		while (!current.add(const Duration(minutes: 30)).isAfter(closingTime)) {
			slots.add(current);
			current = current.add(const Duration(minutes: 30));
		}

		return slots;
	}

	int? findFreeCounter(DateTime start, int duration) {
		final proposedEnd = start.add(Duration(minutes: duration));

		for (var counterId = 1; counterId <= _totalCounters; counterId++) {
			var hasConflict = false;

			for (final booking in existingBookings) {
				if (booking.counterId != counterId) {
					continue;
				}

				if (_overlaps(start, proposedEnd, booking.startTime, booking.endTime)) {
					hasConflict = true;
					break;
				}
			}

			if (!hasConflict) {
				return counterId;
			}
		}

		return null;
	}
}
