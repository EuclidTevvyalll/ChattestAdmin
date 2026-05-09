import 'package:flutter/material.dart';
import '../../../../theme/theme_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A), // Темный фон в стиле админки
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ThemeColors.blue,
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'ForgeLink Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
