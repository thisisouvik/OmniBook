import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnibook/features/cubit/booking_cubit.dart';
import 'package:omnibook/features/cubit/booking_state.dart';
import 'package:omnibook/features/presentation/screens/counter_selection_screen.dart';
import 'package:omnibook/features/presentation/theme/app_colors.dart';
import 'package:omnibook/features/presentation/utils/formatters.dart';
import 'package:omnibook/features/presentation/widgets/slot_tile.dart';

class CounterAvailabilityScreen extends StatefulWidget {
  const CounterAvailabilityScreen({super.key});

  @override
  State<CounterAvailabilityScreen> createState() =>
      _CounterAvailabilityScreenState();
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
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
          final selectedSlot = state.selectedSlot;
          final selectedSlotStatus = selectedSlot != null
              ? cubit.slotStatus(selectedSlot)
              : null;

          return Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SummaryCard(state: state),
                      const SizedBox(height: 16),
                      const Text(
                        'Counter Availability',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List<Widget>.generate(3, (index) {
                        final counterId = index + 1;
                        final nextFree = cubit.nextFreeWindow(counterId, date);
                        final isAvailable = nextFree != null;
                        final bookingsCount = bookings
                            .where((booking) => booking.counterId == counterId)
                            .length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _CounterRow(
                            counterId: counterId,
                            bookingsCount: bookingsCount,
                            nextFree: nextFree,
                            isAvailable: isAvailable,
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      const Text(
                        'Available Time Slots',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Greyed slots do not have a continuous ${formatDuration(state.totalDuration)} gap on any counter.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: slots.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 128,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 64,
                            ),
                        itemBuilder: (context, index) {
                          final slot = slots[index];
                          final status = cubit.slotStatus(slot);
                          final selected =
                              state.selectedSlot != null &&
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
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.45),
                          ),
                        ),
                        child: selectedSlot == null
                            ? const Text(
                                'Tap an available slot to see which counters are free.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Free counters at ${formatTime(selectedSlot)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (selectedSlotStatus == null ||
                                      selectedSlotStatus.freeCounters.isEmpty)
                                    const Text(
                                      'No counters available for this slot.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: selectedSlotStatus.freeCounters
                                          .map(
                                            (counterId) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.lightTeal,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: AppColors.teal,
                                                ),
                                              ),
                                              child: Text(
                                                'Counter $counterId',
                                                style: const TextStyle(
                                                  color: AppColors.teal,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                state: state,
                freeCountersForSelectedSlot:
                    selectedSlotStatus?.freeCounters ?? const <int>[],
                onContinue: () {
                  final selectedSlot = state.selectedSlot;
                  if (selectedSlot == null) {
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CounterSelectionScreen(slot: selectedSlot),
                    ),
                  );
                },
              ),
            ],
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
    required this.bookingsCount,
    required this.nextFree,
    required this.isAvailable,
  });

  final int counterId;
  final int bookingsCount;
  final DateTime? nextFree;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Counter $counterId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nextFree != null
                      ? 'Next free: ${formatTime(nextFree!)}'
                      : 'No free window today',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$bookingsCount booking${bookingsCount == 1 ? '' : 's'} on this counter',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.disabledBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isAvailable ? 'Free' : 'Busy',
              style: TextStyle(
                color: isAvailable
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.state,
    required this.freeCountersForSelectedSlot,
    required this.onContinue,
  });

  final BookingState state;
  final List<int> freeCountersForSelectedSlot;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedSlot != null;
    final hasAvailableCounter = freeCountersForSelectedSlot.isNotEmpty;
    final ready = selected && hasAvailableCounter;
    final selectedCountersText = freeCountersForSelectedSlot
        .map((counterId) => counterId.toString())
        .join(', ');

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
                child: Text(
                  !selected
                      ? 'Select one time slot to continue'
                      : hasAvailableCounter
                      ? 'Selected: ${formatTime(state.selectedSlot!)} | Free counter(s): $selectedCountersText'
                      : 'No free counters for ${formatTime(state.selectedSlot!)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
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
                'Choose Counter',
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
