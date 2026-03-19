import 'package:equatable/equatable.dart';
import 'package:omnibook/features/models/service.dart';

class BookingState extends Equatable {
  final List<Service> selectedServices;
  final DateTime? selectedDate;
  final DateTime? selectedSlot;
  final int? selectedCounter;

  const BookingState({
    required this.selectedServices,
    required this.selectedDate,
    required this.selectedSlot,
    required this.selectedCounter,
  });

  factory BookingState.initial() {
    return const BookingState(
      selectedServices: <Service>[],
      selectedDate: null,
      selectedSlot: null,
      selectedCounter: null,
    );
  }

  int get totalDuration {
    return selectedServices.fold<int>(
      0,
      (sum, service) => sum + service.durationInMinutes,
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
    int? selectedCounter,
    bool clearSelectedDate = false,
    bool clearSelectedSlot = false,
    bool clearSelectedCounter = false,
  }) {
    return BookingState(
      selectedServices: selectedServices ?? this.selectedServices,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      selectedSlot: clearSelectedSlot
          ? null
          : (selectedSlot ?? this.selectedSlot),
      selectedCounter: clearSelectedCounter
          ? null
          : (selectedCounter ?? this.selectedCounter),
    );
  }

  @override
  List<Object?> get props => [
    selectedServices,
    selectedDate,
    selectedSlot,
    selectedCounter,
  ];
}
