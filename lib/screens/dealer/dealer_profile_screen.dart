import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../wallet/wallet_screen.dart';
import '../transactions/transactions_screen.dart';
import '../withdrawal/withdrawal_screen.dart';
import 'edit_profile_screen.dart';

class DealerProfileScreen extends StatelessWidget {
  const DealerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? null
            : const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: Obx(() {
        final dealer = authController.dealer.value;
        if (dealer == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final bottomNavBarHeight = 1.0;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom:
                bottomPadding +
                bottomNavBarHeight +
                20.0, // Extra padding for visibility
          ),
          child: Column(
            children: [
              // Profile header
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.cardBackgroundDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.borderDark
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      child: dealer.profilePic != null && dealer.profilePic!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: dealer.profilePic!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
                                errorWidget: (_, __, ___) => const Icon(Icons.person, size: 48, color: Color(0xFF2563EB)),
                              ),
                            )
                          : const Icon(Icons.person, size: 48, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dealer.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dealer.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Profile Details
              _buildInfoCard(
                context,
                title: 'Personal Information',
                children: [
                  _buildInfoRow(context, 'Name', dealer.name),
                  _buildInfoRow(context, 'Email', dealer.email),
                  _buildInfoRow(context, 'Mobile', dealer.mobile),
                  if (dealer.address != null)
                    _buildInfoRow(context, 'Address', dealer.address!),
                ],
              ),

              // Bank Details
              if (dealer.bankName != null || dealer.accountNumber != null)
                _buildInfoCard(
                  context,
                  title: 'Bank Details',
                  children: [
                    if (dealer.bankName != null)
                      _buildInfoRow(context, 'Bank Name', dealer.bankName!),
                    if (dealer.accountNumber != null)
                      _buildInfoRow(
                        context,
                        'Account Number',
                        dealer.accountNumber!,
                      ),
                    if (dealer.ifscCode != null)
                      _buildInfoRow(context, 'IFSC Code', dealer.ifscCode!),
                    if (dealer.upiId != null)
                      _buildInfoRow(context, 'UPI ID', dealer.upiId!),
                  ],
                ),

              const SizedBox(height: 8),

              // Menu Options - Premium Grid Layout
              _buildMenuSection(context, authController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                title == 'Personal Information'
                    ? Icons.person_outline_rounded
                    : Icons.account_balance_outlined,
                color: const Color(0xFF2563EB),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    AuthController authController,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          _buildPremiumMenuOption(
            context,
            icon: Icons.edit_rounded,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            color: AppColors.primaryBlue,
            onTap: () => Get.to(() => const EditProfileScreen()),
          ),
          const SizedBox(height: 12),
          _buildPremiumMenuOption(
            context,
            icon: Icons.account_balance_wallet_rounded,
            title: 'Wallet',
            subtitle: 'View your points and balance',
            color: AppColors.accentGreen,
            onTap: () => Get.to(() => const WalletScreen()),
          ),
          const SizedBox(height: 12),
          _buildPremiumMenuOption(
            context,
            icon: Icons.history_rounded,
            title: 'Transaction History',
            subtitle: 'View all your transactions',
            color: AppColors.primaryPurple,
            onTap: () => Get.to(() => const TransactionsScreen()),
          ),
          const SizedBox(height: 12),
          _buildPremiumMenuOption(
            context,
            icon: Icons.money_off_rounded,
            title: 'Withdrawal Requests',
            subtitle: 'Manage your withdrawal requests',
            color: AppColors.accentOrange,
            onTap: () => Get.to(() => const WithdrawalScreen()),
          ),
          const SizedBox(height: 12),
          _buildPremiumMenuOption(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            color: AppColors.error,
            onTap: () async {
              await authController.logout();
              Get.offAllNamed('/user-type-selection');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
