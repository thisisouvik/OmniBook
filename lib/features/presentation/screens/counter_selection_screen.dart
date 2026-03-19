import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnibook/features/cubit/booking_cubit.dart';
import 'package:omnibook/features/cubit/booking_state.dart';
import 'package:omnibook/features/presentation/screens/booking_confirmed_screen.dart';
import 'package:omnibook/features/presentation/theme/app_colors.dart';
import 'package:omnibook/features/presentation/utils/formatters.dart';

class CounterSelectionScreen extends StatefulWidget {
  const CounterSelectionScreen({super.key, required this.slot});

  final DateTime slot;

  @override
  State<CounterSelectionScreen> createState() => _CounterSelectionScreenState();
}

class _CounterSelectionScreenState extends State<CounterSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<BookingCubit>();
      final freeCounters = cubit.slotStatus(widget.slot).freeCounters;
      if (freeCounters.isEmpty) {
        return;
      }
      final selectedCounter = cubit.state.selectedCounter;
      if (selectedCounter == null || !freeCounters.contains(selectedCounter)) {
        cubit.setCounter(freeCounters.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('Choose Counter'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F9FB),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final cubit = context.read<BookingCubit>();
          final status = cubit.slotStatus(widget.slot);
          final freeCounters = status.freeCounters;

          return Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Selected Slot: ${formatTime(widget.slot)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Service Duration: ${formatDuration(state.totalDuration)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (freeCounters.isNotEmpty)
                              Text(
                                'You are assigned Counter ${state.selectedCounter ?? freeCounters.first}. You can change it below.',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else
                              const Text(
                                'No counters are free for this slot right now.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Select Your Counter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List<Widget>.generate(cubit.totalCounters, (index) {
                        final counterId = index + 1;
                        final isFree = freeCounters.contains(counterId);
                        final selected = state.selectedCounter == counterId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.teal
                                  : AppColors.border.withValues(alpha: 0.6),
                            ),
                          ),
                          child: RadioListTile<int>(
                            dense: true,
                            value: counterId,
                            groupValue: state.selectedCounter,
                            onChanged: isFree
                                ? (value) {
                                    if (value != null) {
                                      cubit.setCounter(value);
                                    }
                                  }
                                : null,
                            activeColor: AppColors.teal,
                            title: Text(
                              'Counter $counterId',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isFree
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            subtitle: Text(
                              isFree
                                  ? 'Available for this slot'
                                  : 'Unavailable',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                canConfirm:
                    state.selectedCounter != null && freeCounters.isNotEmpty,
                onConfirm: () {
                  try {
                    final booking = cubit.confirmBooking(
                      counterId: state.selectedCounter,
                    );
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.canConfirm, required this.onConfirm});

  final bool canConfirm;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canConfirm ? onConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            disabledBackgroundColor: AppColors.disabledBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Confirm Booking',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
