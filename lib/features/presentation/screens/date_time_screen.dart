import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnibook/features/cubit/booking_cubit.dart';
import 'package:omnibook/features/cubit/booking_state.dart';
import 'package:omnibook/features/presentation/screens/booking_confirmed_screen.dart';
import 'package:omnibook/features/presentation/theme/app_colors.dart';
import 'package:omnibook/features/presentation/utils/formatters.dart';

class DateTimeScreen extends StatefulWidget {
  const DateTimeScreen({super.key, this.preselectedSlot});

  final DateTime? preselectedSlot;

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<BookingCubit>();
      if (cubit.state.selectedDate == null) {
        cubit.setDate(DateTime.now());
      }
      if (widget.preselectedSlot != null) {
        cubit.setDate(widget.preselectedSlot!);
        cubit.setSlot(widget.preselectedSlot!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('Select Date & Time'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F9FB),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final cubit = context.read<BookingCubit>();
          final selectedDate = state.selectedDate ?? DateTime.now();
          final slots = cubit.availableSlotsForDate(selectedDate);

          List<DateTime> slotsInRange(int startHour, int endHour) {
            return slots
                .where((slot) => slot.hour >= startHour && slot.hour < endHour)
                .toList();
          }

          final morning = slotsInRange(9, 12);
          final afternoon = slotsInRange(12, 16);
          final evening = slotsInRange(16, 19);

          return Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Search for a service...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _MiniMonthCalendar(
                        focusedDate: selectedDate,
                        selectedDate: selectedDate,
                        onDateSelected: (date) => cubit.setDate(date),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: _TimeSection(
                              title: 'Morning',
                              slots: morning,
                              selectedSlot: state.selectedSlot,
                              onTap: cubit.setSlot,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TimeSection(
                              title: 'Afternoon',
                              slots: afternoon,
                              selectedSlot: state.selectedSlot,
                              onTap: cubit.setSlot,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TimeSection(
                              title: 'Evening',
                              slots: evening,
                              selectedSlot: state.selectedSlot,
                              onTap: cubit.setSlot,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                state: state,
                onContinue: () {
                  try {
                    final booking = cubit.confirmBooking();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            BookingConfirmedScreen(booking: booking),
                      ),
                    );
                  } on StateError catch (error) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(error.message)));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection({
    required this.title,
    required this.slots,
    required this.selectedSlot,
    required this.onTap,
  });

  final String title;
  final List<DateTime> slots;
  final DateTime? selectedSlot;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final cubit = context.read<BookingCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...slots.map((slot) {
              final status = cubit.slotStatus(slot);
              final isSelected =
                  selectedSlot != null &&
                  selectedSlot!.hour == slot.hour &&
                  selectedSlot!.minute == slot.minute;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: status.isAvailable ? () => onTap(slot) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.teal
                          : (status.isAvailable
                                ? Colors.white
                                : AppColors.disabledBg),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.teal : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          formatTime(slot),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (status.isAvailable
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        if (isSelected) const SizedBox(width: 4),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.onContinue});

  final BookingState state;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final selectedDate = state.selectedDate;
    final selectedTime = state.selectedSlot;
    final ready = selectedDate != null && selectedTime != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x1A00102A),
            blurRadius: 16,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Date: ${selectedDate != null ? formatDate(selectedDate) : '--'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Time: ${selectedTime != null ? formatTime(selectedTime) : '--'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text(
                formatMoney(state.totalPrice),
                style: const TextStyle(
                  color: AppColors.teal,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ready ? onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                disabledBackgroundColor: AppColors.disabledBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Continue Booking ->',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMonthCalendar extends StatelessWidget {
  const _MiniMonthCalendar({
    required this.focusedDate,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime focusedDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final firstWeekday = firstOfMonth.weekday;
    final startOffset = firstWeekday - 1;
    final daysInMonth = DateTime(
      focusedDate.year,
      focusedDate.month + 1,
      0,
    ).day;

    final cells = <DateTime?>[];
    for (var i = 0; i < startOffset; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(focusedDate.year, focusedDate.month, day));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '${_monthName(focusedDate.month)} ${focusedDate.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: List<Widget>.generate(7, (index) {
              final dayLabel = weekdayShort(index + 1);
              return Expanded(
                child: Center(
                  child: Text(
                    dayLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final date = cells[index];
              if (date == null) {
                return const SizedBox.shrink();
              }
              final selected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onDateSelected(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.teal : AppColors.lightTeal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
