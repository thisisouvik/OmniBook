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
  static const List<String> _serviceFor = <String>[
    'All',
    'Woman',
    'Men',
    'Kids',
  ];

  String _selectedServiceFor = 'All';

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
            children: <Widget>[
              Container(
                width: 64,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.teal, fontSize: 18),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<BookingCubit>().resetServices(),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: AppColors.danger, fontSize: 18),
                    ),
                  ),
                ],
              ),
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
                          const Text(
                            'Service for',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _serviceFor.map((value) {
                              final selected = value == _selectedServiceFor;
                              return ChoiceChip(
                                selected: selected,
                                showCheckmark: false,
                                onSelected: (_) =>
                                    setState(() => _selectedServiceFor = value),
                                label: Text(value),
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.teal
                                      : AppColors.border,
                                ),
                                selectedColor: AppColors.lightTeal,
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? AppColors.teal
                                      : AppColors.textPrimary,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Select Counters',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List<Widget>.generate(3, (index) {
                              final counterId = index + 1;
                              final isFree = context
                                  .read<BookingCubit>()
                                  .counterIsFreeNow(counterId);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: isFree
                                      ? AppColors.success.withValues(
                                          alpha: 0.12,
                                        )
                                      : AppColors.disabledBg,
                                  border: Border.all(
                                    color: isFree
                                        ? AppColors.success
                                        : AppColors.textSecondary.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  'Counter $counterId ${isFree ? 'Free' : 'Busy'}',
                                  style: TextStyle(
                                    color: isFree
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
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
                        'Select Date & Time',
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
            ],
          ),
        ),
      ),
    );
  }
}
