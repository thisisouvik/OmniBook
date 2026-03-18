import 'package:equatable/equatable.dart';
import 'package:omnibook/features/models/service.dart';

class BookingState extends Equatable {
  final List<Service> selectedServices;
  final DateTime? selectedDate;
  final DateTime? selectedSlot;

  const BookingState({
    required this.selectedServices,
    required this.selectedDate,
    required this.selectedSlot,
  });

  factory BookingState.initial() {
    return const BookingState(
      selectedServices: <Service>[],
      selectedDate: null,
      selectedSlot: null,
    );
  }

  int get totalDuration {
    return selectedServices.fold<int>(
      0,
      (sum, service) => sum + service.durationinMinutes,
    );
  }

  double get totalPrice {
    return selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );
  }

  BookingState copyWith({
    List<Service>? selectedServices,
    DateTime? selectedDate,
    DateTime? selectedSlot,
    bool clearSelectedDate = false,
    bool clearSelectedSlot = false,
  }) {
    return BookingState(
      selectedServices: selectedServices ?? this.selectedServices,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      selectedSlot: clearSelectedSlot
          ? null
          : (selectedSlot ?? this.selectedSlot),
    );
  }

  @override
  List<Object?> get props => [selectedServices, selectedDate, selectedSlot];
}
