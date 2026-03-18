import 'package:flutter_test/flutter_test.dart';
import 'package:omnibook/features/cubit/booking_cubit.dart';
import 'package:omnibook/features/models/service.dart';

void main() {
  test('toggleService updates totalDuration', () {
    final cubit = BookingCubit();
    final haircut = Service(name: 'Haircut', durationinMinutes: 45, price: 20.0);

    cubit.toggleService(haircut);
    print(cubit.state.totalDuration);

    expect(cubit.state.totalDuration, 45);
    cubit.close();
  });
}
