import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glassmorphic_container.dart';
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
      appBar: AppBar(title: const Text('Profile')),
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
              // Profile Picture and Name - Premium Design
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return GlassmorphicContainer(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    borderRadius: BorderRadius.circular(24),
                    width: double.infinity,
                    gradient: isDark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryPurple.withOpacity(0.3),
                              AppColors.primaryBlue.withOpacity(0.28),
                              AppColors.primaryPurple.withOpacity(0.25),
                              AppColors.primaryBlue.withOpacity(0.22),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.gradientStart.withOpacity(0.95),
                              AppColors.gradientEnd.withOpacity(0.9),
                              AppColors.gradientStart.withOpacity(0.85),
                            ],
                          ),
                    borderColor: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.6),
                    borderWidth: 2.5,
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPurple.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                              spreadRadius: 0.5,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: AppColors.primaryPurple.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            ),
                          ],
                    child: Column(
                      children: [
                        // Profile Picture with Border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.2),
                                    ]
                                  : [
                                      Colors.white,
                                      Colors.white.withOpacity(0.95),
                                    ],
                            ),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? AppColors.primaryPurple.withOpacity(0.2)
                                    : AppColors.primaryPurple.withOpacity(0.4),
                                blurRadius: isDark ? 12 : 20,
                                offset: const Offset(0, 8),
                                spreadRadius: isDark ? 0.5 : 2,
                              ),
                              BoxShadow(
                                color: isDark
                                    ? AppColors.primaryBlue.withOpacity(0.15)
                                    : AppColors.primaryBlue.withOpacity(0.3),
                                blurRadius: isDark ? 10 : 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.transparent,
                            child:
                                dealer.profilePic != null &&
                                    dealer.profilePic!.isNotEmpty
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: dealer.profilePic!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: AppColors.primaryBlue,
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primaryPurple
                                                      .withOpacity(0.3),
                                                  AppColors.primaryBlue
                                                      .withOpacity(0.3),
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                          ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryPurple.withOpacity(
                                            0.3,
                                          ),
                                          AppColors.primaryBlue.withOpacity(
                                            0.3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          dealer.name,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  dealer.email,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textLight.withOpacity(
                                          0.95,
                                        ),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20.0),
      borderRadius: BorderRadius.circular(24),
      width: double.infinity,
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardBackgroundDark.withOpacity(0.28),
                AppColors.cardBackgroundDark.withOpacity(0.24),
                AppColors.cardBackgroundDark.withOpacity(0.2),
                AppColors.cardBackgroundDark.withOpacity(0.18),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.98),
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.92),
                Colors.white.withOpacity(0.9),
              ],
            ),
      borderColor: isDark
          ? Colors.white.withOpacity(0.25)
          : AppColors.primaryBlue.withOpacity(0.3),
      borderWidth: 2,
      boxShadow: isDark
          ? [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 5),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
                spreadRadius: 0.5,
              ),
            ]
          : [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primaryBlue.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryPurple.withOpacity(0.3),
                              AppColors.primaryBlue.withOpacity(0.3),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              AppColors.primaryPurple.withOpacity(0.15),
                              AppColors.primaryBlue.withOpacity(0.15),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    title == 'Personal Information'
                        ? Icons.person_outline
                        : Icons.account_balance_outlined,
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.03),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withOpacity(0.08),
                  AppColors.primaryPurple.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.primaryBlue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark.withOpacity(0.9)
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
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

    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: BorderRadius.circular(24),
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardBackgroundDark.withOpacity(0.25),
                AppColors.cardBackgroundDark.withOpacity(0.2),
                AppColors.cardBackgroundDark.withOpacity(0.15),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.92),
                Colors.white.withOpacity(0.9),
              ],
            ),
      borderColor: isDark
          ? Colors.white.withOpacity(0.18)
          : AppColors.primaryBlue.withOpacity(0.25),
      borderWidth: 1.5,
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

    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.15),
                color.withOpacity(0.1),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.98),
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.92),
              ],
            ),
      borderColor: isDark ? color.withOpacity(0.3) : color.withOpacity(0.25),
      borderWidth: 1.5,
      boxShadow: isDark
          ? [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0.5,
              ),
            ]
          : [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
                spreadRadius: 1,
              ),
            ],
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(isDark ? 0.4 : 0.2),
                  color.withOpacity(isDark ? 0.3 : 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: isDark ? Colors.white : color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}
