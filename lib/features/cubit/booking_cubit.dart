import 'package:bloc/bloc.dart';
import 'package:omnibook/features/models/booking.dart';
import 'package:omnibook/features/models/service.dart';
import 'package:omnibook/features/models/slot_status.dart';
import 'package:omnibook/features/services/booking_service.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({BookingService? bookingService})
    : _bookingService = bookingService ?? BookingService(),
      super(BookingState.initial());

  final BookingService _bookingService;

  int get openingHour => _bookingService.openingHour;
  int get closingHour => _bookingService.closingHour;
  int get totalCounters => _bookingService.totalCounters;

  void toggleService(Service service) {
    final updatedServices = List<Service>.from(state.selectedServices);
    final existingIndex = updatedServices.indexWhere(
      (selected) => selected.name == service.name,
    );

    if (existingIndex >= 0) {
      updatedServices.removeAt(existingIndex);
    } else {
      updatedServices.add(service);
    }

    emit(
      state.copyWith(
        selectedServices: updatedServices,
        clearSelectedSlot: true,
        clearSelectedCounter: true,
      ),
    );
  }

  void resetServices() {
    emit(
      state.copyWith(
        selectedServices: <Service>[],
        clearSelectedSlot: true,
        clearSelectedCounter: true,
      ),
    );
  }

  void setDate(DateTime date) {
    emit(
      state.copyWith(
        selectedDate: DateTime(date.year, date.month, date.day),
        clearSelectedSlot: true,
        clearSelectedCounter: true,
      ),
    );
  }

  void setSlot(DateTime time) {
    emit(state.copyWith(selectedSlot: time, clearSelectedCounter: true));
  }

  void setCounter(int counterId) {
    emit(state.copyWith(selectedCounter: counterId));
  }

  List<DateTime> availableSlotsForDate(DateTime date) {
    return _bookingService.generateSlotsForDate(date);
  }

  SlotStatus slotStatus(DateTime start) {
    final duration = state.totalDuration;
    if (duration <= 0) {
      return const SlotStatus(isAvailable: false, freeCounters: <int>[]);
    }
    return _bookingService.checkSlot(start, duration);
  }

  bool counterIsFreeNow(int counterId, {int fallbackDuration = 30}) {
    final now = DateTime.now();
    final duration = state.totalDuration > 0
        ? state.totalDuration
        : fallbackDuration;
    return _bookingService.isCounterFree(counterId, now, duration);
  }

  DateTime? nextFreeWindow(int counterId, DateTime date) {
    final duration = state.totalDuration > 0 ? state.totalDuration : 30;
    return _bookingService.nextFreeStartForCounter(counterId, date, duration);
  }

  List<Booking> bookingsForDate(DateTime date) {
    return _bookingService.bookingsForDate(date);
  }

  Booking confirmBooking({int? counterId}) {
    final selectedDate = state.selectedDate;
    final selectedSlot = state.selectedSlot;
    final duration = state.totalDuration;
    final selectedCounter = counterId ?? state.selectedCounter;

    if (selectedDate == null) {
      throw StateError('Select a date before confirming a booking.');
    }
    if (selectedSlot == null) {
      throw StateError('Select a slot before confirming a booking.');
    }
    if (duration <= 0) {
      throw StateError(
        'Select at least one service before confirming a booking.',
      );
    }
    if (selectedCounter == null) {
      throw StateError('Select a counter before confirming a booking.');
    }

    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedSlot.hour,
      selectedSlot.minute,
    );

    final freeCounters = _bookingService.findFreeCounters(start, duration);
    if (freeCounters.isEmpty) {
      throw StateError('No counters available for the selected slot.');
    }
    if (!freeCounters.contains(selectedCounter)) {
      throw StateError(
        'Counter $selectedCounter is not available for this slot.',
      );
    }

    return Booking(
      counterId: selectedCounter,
      startTime: start,
      endTime: start.add(Duration(minutes: duration)),
    );
  }
}
