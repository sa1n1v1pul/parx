import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../widgets/glassmorphic_container.dart';
import 'dealer/dealer_login_screen.dart';
import 'user/user_qr_scanner_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  Text(
                    'Parx Hardware',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your role',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight.withOpacity(0.9),
                        ),
                  ),
                  const SizedBox(height: 80),
                  
                  // I am User Button
                  _buildTypeButton(
                    context,
                    title: 'I am User',
                    icon: Icons.person,
                    gradient: AppColors.blueGradient,
                    onTap: () {
                      Get.to(() => const UserQrScannerScreen());
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // I am Dealer Button
                  _buildTypeButton(
                    context,
                    title: 'I am Dealer',
                    icon: Icons.store,
                    gradient: AppColors.successGradient,
                    onTap: () {
                      Get.to(() => const DealerLoginScreen());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassmorphicContainer(
      height: 120,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(20),
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPurple.withOpacity(0.4),
                AppColors.primaryBlue.withOpacity(0.35),
                AppColors.primaryPurple.withOpacity(0.3),
              ],
            )
          : gradient,
      borderColor: Colors.white.withOpacity(isDark ? 0.3 : 0.5),
      borderWidth: 2,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

