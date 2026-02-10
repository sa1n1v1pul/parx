import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/withdrawal_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glassmorphic_container.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final WithdrawalController _withdrawalController = Get.put(WithdrawalController());
  final ProfileController _profileController = Get.find<ProfileController>();
  final WalletController _walletController = Get.find<WalletController>();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fetch withdrawal history immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _withdrawalController.fetchWithdrawalRequests(refresh: true);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdrawal() async {
    if (_formKey.currentState!.validate()) {
      final dealer = _profileController.dealer.value;
      
      // Check if bank details are filled
      if (dealer?.bankName == null || dealer?.accountNumber == null) {
        Get.snackbar(
          'Bank Details Required',
          'Please fill your bank details in profile settings first',
          backgroundColor: AppColors.warning,
          colorText: AppColors.textLight,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        Get.snackbar(
          'Invalid Points',
          'Please enter valid points',
          backgroundColor: AppColors.error,
          colorText: AppColors.textLight,
        );
        return;
      }

      final wallet = _walletController.wallet.value;
      if (wallet != null) {
        final balance = double.tryParse(wallet.balance) ?? 0;
        if (amount > balance) {
          Get.snackbar(
            'Insufficient Points',
            'You don\'t have enough points',
            backgroundColor: AppColors.error,
            colorText: AppColors.textLight,
          );
          return;
        }
      }

      final success = await _withdrawalController.submitWithdrawalRequest(amount);
      
      if (success) {
        _amountController.clear();
        Get.snackbar(
          'Success',
          'Withdrawal request submitted successfully',
          backgroundColor: AppColors.success,
          colorText: AppColors.textLight,
        );
        await _walletController.fetchWallet();
      } else {
        Get.snackbar(
          'Error',
          _withdrawalController.errorMessage.value,
          backgroundColor: AppColors.error,
          colorText: AppColors.textLight,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance
            Obx(() {
              final wallet = _walletController.wallet.value;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return GlassmorphicContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(16),
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryBlue.withOpacity(0.28),
                          AppColors.primaryPurple.withOpacity(0.24),
                          AppColors.primaryBlue.withOpacity(0.2),
                        ],
                      )
                    : AppColors.blueGradient,
                borderColor: isDark
                    ? Colors.white.withOpacity(0.25)
                    : Colors.white.withOpacity(0.5),
                borderWidth: 2,
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Points',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textLight.withOpacity(0.9),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${wallet?.balance ?? '0.00'} Points',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Withdrawal Form
            Text(
              'Request Withdrawal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Points',
                  prefixIcon: const Icon(Icons.stars),
                  hintText: 'Enter points to withdraw',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter points';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid points';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _withdrawalController.isLoading.value
                    ? null
                    : _handleWithdrawal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: _withdrawalController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            )),
            const SizedBox(height: 32),

            // Withdrawal History
            Text(
              'Withdrawal History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (_withdrawalController.isLoading.value &&
                  _withdrawalController.withdrawalRequests.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_withdrawalController.withdrawalRequests.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No withdrawal requests yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _withdrawalController.withdrawalRequests.length,
                itemBuilder: (context, index) {
                  final request = _withdrawalController.withdrawalRequests[index];
                  return _buildRequestCard(context, request);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, request) {
    Color statusColor;
    IconData statusIcon;
    
    switch (request.status.toLowerCase()) {
      case 'approved':
        statusColor = AppColors.accentGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(20),
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
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
              ],
            ),
      borderColor: isDark
          ? Colors.white.withOpacity(0.2)
          : statusColor.withOpacity(0.2),
      borderWidth: 1.5,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            statusIcon,
            color: isDark ? Colors.white : statusColor,
          ),
        ),
        title: Text(
          '${request.requestedAmount} Points',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : null,
          ),
        ),
        subtitle: Text(
          _formatDate(request.requestDate),
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.status.toUpperCase(),
            style: TextStyle(
              color: isDark ? Colors.white : statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              shadows: isDark
                  ? [
                      Shadow(
                        color: statusColor.withOpacity(0.8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

