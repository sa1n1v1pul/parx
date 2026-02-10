import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/glassmorphic_container.dart';
import '../transactions/transactions_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.find<WalletController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          walletController.refreshWallet();
          return Future.value();
        },
        child: Obx(() {
          if (walletController.isLoading.value &&
              walletController.wallet.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final wallet = walletController.wallet.value;
          if (wallet == null) {
            return const EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No Wallet Data',
              message: 'Unable to load wallet information',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Wallet Balance Card
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.only(bottom: 24),
                  borderRadius: BorderRadius.circular(24),
                  width: double.infinity,
                  gradient: Theme.of(context).brightness == Brightness.dark
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryPurple.withOpacity(0.28),
                            AppColors.primaryBlue.withOpacity(0.24),
                            AppColors.primaryPurple.withOpacity(0.2),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gradientStart.withOpacity(0.9),
                            AppColors.gradientEnd.withOpacity(0.85),
                          ],
                        ),
                  borderColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.25)
                      : Colors.white.withOpacity(0.5),
                  borderWidth: 2,
                  boxShadow: Theme.of(context).brightness == Brightness.dark
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
                      : null,
                  child: Column(
                    children: [
                      Text(
                        'Current Points',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textLight.withOpacity(0.9),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${wallet.balance} Points',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Earned',
                        value: '${wallet.totalEarned} Points',
                        color: AppColors.accentGreen,
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Withdrawn',
                        value: '${wallet.totalWithdrawn.toStringAsFixed(0)} Points',
                        color: AppColors.accentOrange,
                        icon: Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // View History Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const TransactionsScreen()),
                    icon: const Icon(Icons.history),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text('View Transaction History'),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.25),
                color.withOpacity(0.2),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.85),
              ],
            ),
      borderColor: color.withOpacity(isDark ? 0.4 : 0.3),
      borderWidth: 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? color.withOpacity(0.35)
                  : color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDark ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                    shadows: isDark
                        ? [
                            Shadow(
                              color: color.withOpacity(0.8),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

