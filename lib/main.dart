import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnibook/features/cubit/booking_cubit.dart';
import 'package:omnibook/features/presentation/screens/splash_screen.dart';
import 'package:omnibook/features/presentation/theme/app_theme.dart';

void main() {
  runApp(BlocProvider(create: (_) => BookingCubit(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
