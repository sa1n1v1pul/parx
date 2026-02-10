import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/wallet_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/glassmorphic_container.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.find<WalletController>();

    // Fetch history on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (walletController.walletHistory.isEmpty && !walletController.isLoading.value) {
        walletController.fetchWalletHistory(refresh: true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Obx(() {
        if (walletController.isLoading.value &&
            walletController.walletHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (walletController.walletHistory.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history_outlined,
            title: 'No Transactions Yet',
            message: 'Your transaction history will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () => walletController.fetchWalletHistory(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: walletController.walletHistory.length,
            itemBuilder: (context, index) {
              final transaction = walletController.walletHistory[index];
              return _buildTransactionCard(context, transaction);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTransactionCard(BuildContext context, WalletHistoryModel transaction) {
    final isCredit = transaction.type == 'credit';
    final color = isCredit ? AppColors.accentGreen : AppColors.accentRed;
    final icon = isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: BorderRadius.circular(20),
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardBackgroundDark.withOpacity(0.3),
                AppColors.cardBackgroundDark.withOpacity(0.25),
                AppColors.cardBackgroundDark.withOpacity(0.2),
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
      borderColor: isDark
          ? Colors.white.withOpacity(0.2)
          : color.withOpacity(0.2),
      borderWidth: 1.5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isCredit 
                ? AppColors.successGradient 
                : LinearGradient(
                    colors: [AppColors.accentRed, AppColors.accentRed.withOpacity(0.7)],
                  ),
            shape: BoxShape.circle,
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          transaction.description,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _formatDate(transaction.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}${transaction.amount} Points',
          style: TextStyle(
            color: isDark ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

