import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnibook/features/cubit/booking_cubit.dart';
import 'package:omnibook/features/cubit/booking_state.dart';
import 'package:omnibook/features/models/booking.dart';
import 'package:omnibook/features/presentation/screens/date_time_screen.dart';
import 'package:omnibook/features/presentation/theme/app_colors.dart';
import 'package:omnibook/features/presentation/utils/formatters.dart';
import 'package:omnibook/features/presentation/widgets/slot_tile.dart';

class CounterAvailabilityScreen extends StatefulWidget {
  const CounterAvailabilityScreen({super.key});

  @override
  State<CounterAvailabilityScreen> createState() => _CounterAvailabilityScreenState();
}

class _CounterAvailabilityScreenState extends State<CounterAvailabilityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<BookingCubit>();
      if (cubit.state.selectedDate == null) {
        cubit.setDate(DateTime.now());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('Available Slots'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F9FB),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state.selectedServices.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'No services selected.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          final date = state.selectedDate ?? DateTime.now();
          final cubit = context.read<BookingCubit>();
          final bookings = cubit.bookingsForDate(date);
          final slots = cubit.availableSlotsForDate(date);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SummaryCard(state: state),
                const SizedBox(height: 18),
                const Text(
                  'Counter Availability',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...List<Widget>.generate(3, (index) {
                  final counterId = index + 1;
                  final nextFree = cubit.nextFreeWindow(counterId, date);
                  final isAvailable = nextFree != null;
                  final counterBookings = bookings
                      .where((booking) => booking.counterId == counterId)
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CounterRow(
                      counterId: counterId,
                      bookings: counterBookings,
                      nextFree: nextFree,
                      isAvailable: isAvailable,
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Text(
                  'Available Time Slots',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: slots.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final status = cubit.slotStatus(slot);
                    final selected = state.selectedSlot != null &&
                        state.selectedSlot!.hour == slot.hour &&
                        state.selectedSlot!.minute == slot.minute;
                    return SlotTile(
                      time: slot,
                      spotsFree: status.freeCounters.length,
                      isAvailable: status.isAvailable,
                      isSelected: selected,
                      onTap: () {
                        cubit.setDate(date);
                        cubit.setSlot(slot);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DateTimeScreen(preselectedSlot: slot),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Booking Summary',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ...state.selectedServices.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${service.name} • ${formatDuration(service.durationInMinutes)} • ${formatMoney(service.price)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          const Divider(height: 18),
          Text(
            'Total Duration: ${formatDuration(state.totalDuration)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Price: ${formatMoney(state.totalPrice)}',
            style: const TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.counterId,
    required this.bookings,
    required this.nextFree,
    required this.isAvailable,
  });

  final int counterId;
  final List<Booking> bookings;
  final DateTime? nextFree;
  final bool isAvailable;

  double _positionFromStart(DateTime value) {
    const openMins = 9 * 60;
    final mins = value.hour * 60 + value.minute;
    return ((mins - openMins) / (9 * 60)).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Counter $counterId',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.disabledBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Occupied',
                  style: TextStyle(
                    color: isAvailable ? AppColors.success : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3F8),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                ...bookings.map((booking) {
                  final leftFactor = _positionFromStart(booking.startTime);
                  final rightFactor = _positionFromStart(booking.endTime);
                  return Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth * (rightFactor - leftFactor);
                        return Stack(
                          children: <Widget>[
                            Positioned(
                              left: constraints.maxWidth * leftFactor,
                              top: 0,
                              bottom: 0,
                              width: width,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.teal,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Text('9:00 AM', style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              const Text('6:00 PM', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nextFree != null
                ? 'Next free window: ${formatTime(nextFree!)}'
                : 'No free window for selected duration',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
