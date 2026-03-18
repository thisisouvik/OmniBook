import 'package:bloc/bloc.dart';
import 'package:omnibook/features/models/booking.dart';
import 'package:omnibook/features/models/service.dart';
import 'package:omnibook/features/services/booking_service.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({BookingService? bookingService})
    : _bookingService = bookingService ?? BookingService(),
      super(BookingState.initial());

  final BookingService _bookingService;

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

    emit(state.copyWith(selectedServices: updatedServices));
  }

  void setDate(DateTime date) {
    emit(
      state.copyWith(
        selectedDate: DateTime(date.year, date.month, date.day),
        clearSelectedSlot: true,
      ),
    );
  }

  void setSlot(DateTime time) {
    emit(state.copyWith(selectedSlot: time));
  }

  Booking confirmBooking() {
    final selectedDate = state.selectedDate;
    final selectedSlot = state.selectedSlot;
    final duration = state.totalDuration;

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

    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedSlot.hour,
      selectedSlot.minute,
    );

    final freeCounter = _bookingService.findFreeCounter(start, duration);
    if (freeCounter == null) {
      throw StateError('No counters available for the selected slot.');
    }

    return Booking(
      counterId: freeCounter,
      startTime: start,
      endTime: start.add(Duration(minutes: duration)),
    );
  }
}
