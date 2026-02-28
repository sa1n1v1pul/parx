import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/wallet_model.dart';
import '../../widgets/empty_state_widget.dart';

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
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? null
            : const Color(0xFFF8FAFC),
        elevation: 0,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          transaction.description,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _formatDate(transaction.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
          ),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}${transaction.amount} Points',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
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

