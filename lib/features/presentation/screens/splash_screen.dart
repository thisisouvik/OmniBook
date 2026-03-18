import 'dart:async';

import 'package:flutter/material.dart';
import 'package:omnibook/features/presentation/screens/home_screen.dart';
import 'package:omnibook/features/presentation/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<HomeScreen>(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal,
      body: Center(
        child: Image.asset(
          'assets/images/omnibook_logo.png',
          width: 220,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'OmniBook',
              style: TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            );
          },
        ),
      ),
    );
  }
}
