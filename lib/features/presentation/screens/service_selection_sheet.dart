import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnibook/features/cubit/booking_cubit.dart';
import 'package:omnibook/features/cubit/booking_state.dart';
import 'package:omnibook/features/presentation/data/sample_services.dart';
import 'package:omnibook/features/presentation/screens/counter_availability_screen.dart';
import 'package:omnibook/features/presentation/theme/app_colors.dart';
import 'package:omnibook/features/presentation/utils/formatters.dart';
import 'package:omnibook/features/presentation/widgets/service_card.dart';

class ServiceSelectionSheet extends StatefulWidget {
  const ServiceSelectionSheet({super.key});

  @override
  State<ServiceSelectionSheet> createState() => _ServiceSelectionSheetState();
}

class _ServiceSelectionSheetState extends State<ServiceSelectionSheet> {
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
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F9FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: <Widget>
            [
              const SizedBox(height: 6),
              Expanded(
                child: BlocBuilder<BookingCubit, BookingState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10),
                          const Text(
                            'Service',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sampleServices.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.5,
                                ),
                            itemBuilder: (context, index) {
                              final service = sampleServices[index];
                              final isSelected = state.selectedServices.any(
                                (selected) => selected.name == service.name,
                              );
                              return ServiceCard(
                                service: service,
                                isSelected: isSelected,
                                onTap: () => context
                                    .read<BookingCubit>()
                                    .toggleService(service),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _DatePickerSection(
                            selectedDate: state.selectedDate,
                            onDateSelected: (date) {
                              context.read<BookingCubit>().setDate(date);
                            },
                          ),
                          const SizedBox(height: 18),
                          if (state.selectedServices.isNotEmpty)
                            Text(
                              'Selected: ${state.selectedServices.length} service(s)  |  ${formatDuration(state.totalDuration)}  |  ${formatMoney(state.totalPrice)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.selectedServices.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const CounterAvailabilityScreen(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        disabledBackgroundColor: AppColors.disabledBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Check Availability',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ]
          ),
        ),
      ),
    );
  }
}

class _DatePickerSection extends StatelessWidget {
  const _DatePickerSection({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final displayDate = selectedDate ?? DateTime.now();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Select Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: displayDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.teal,
                        surface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.lightTeal.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.teal),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.teal, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    formatDate(displayDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
