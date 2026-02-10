import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/glassmorphic_container.dart';
import 'dealer_profile_screen.dart';
import '../wallet/wallet_screen.dart';
import '../transactions/transactions_screen.dart';
import '../withdrawal/withdrawal_screen.dart';

class DealerHomeScreen extends StatefulWidget {
  const DealerHomeScreen({super.key});

  @override
  State<DealerHomeScreen> createState() => _DealerHomeScreenState();
}

class _DealerHomeScreenState extends State<DealerHomeScreen> {
  int _currentIndex = 0;
  final WalletController _walletController = Get.put(WalletController());
  final ProductController _productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    _walletController.fetchWallet();
    _productController.fetchProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<Widget> _screens = [const HomeTab(), const DealerProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final WalletController walletController = Get.find<WalletController>();
    final ProductController productController = Get.find<ProductController>();

    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parx Hardware'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(themeController.themeIcon),
              onPressed: () => themeController.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            walletController.refreshWallet();
            productController.refreshProducts();
          },
          child: Builder(
            builder: (context) {
              final bottomPadding = MediaQuery.of(context).padding.bottom;
              final bottomNavBarHeight = 1.0;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: bottomPadding + bottomNavBarHeight + 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Obx(() {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return GlassmorphicContainer(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 16),
                        borderRadius: BorderRadius.circular(20),
                        gradient: isDark
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
                        borderColor: isDark
                            ? Colors.white.withOpacity(0.25)
                            : Colors.white.withOpacity(0.5),
                        borderWidth: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${authController.dealer.value?.name ?? 'Dealer'}!',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            // Wallet Balance Card
                            Obx(
                              () => _buildWalletCard(
                                context,
                                balance:
                                    walletController.wallet.value?.balance ??
                                    '0.00',
                                totalEarned:
                                    walletController
                                        .wallet
                                        .value
                                        ?.totalEarned ??
                                    '0.00',
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.account_balance_wallet,
                              title: 'Wallet',
                              color: AppColors.accentGreen,
                              onTap: () => Get.to(() => const WalletScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.history,
                              title: 'Transactions',
                              color: AppColors.primaryBlue,
                              onTap: () =>
                                  Get.to(() => const TransactionsScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.money_off,
                              title: 'Withdraw',
                              color: AppColors.accentOrange,
                              onTap: () =>
                                  Get.to(() => const WithdrawalScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Products Catalog
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Product Catalog',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Products List
                    Obx(() {
                      if (productController.isLoading.value &&
                          productController.products.isEmpty) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (productController.products.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Icons.inventory_2_outlined,
                          title: 'No Products Available',
                          message: 'Products will appear here once available',
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productController.products.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemBuilder: (context, index) {
                          final product = productController.products[index];
                          return _buildProductCard(context, product);
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _removeDecimals(String value) {
    try {
      final doubleValue = double.tryParse(value) ?? 0.0;
      return doubleValue.toInt().toString();
    } catch (e) {
      // If not a valid number, return without decimals
      return value.split('.').first;
    }
  }

  Widget _buildWalletCard(
    BuildContext context, {
    required String balance,
    required String totalEarned,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassmorphicContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(20),
      gradient: isDark
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
                AppColors.gradientStart.withOpacity(0.85),
                AppColors.gradientEnd.withOpacity(0.8),
              ],
            ),
      borderColor: isDark
          ? Colors.white.withOpacity(0.25)
          : Colors.white.withOpacity(0.5),
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
                color: AppColors.primaryPurple.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Wallet Points',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_removeDecimals(balance)} Points',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Earned',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_removeDecimals(totalEarned)} Points',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);

    return GlassmorphicContainer(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.04,
        horizontal: screenWidth * 0.03,
      ),
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.28),
                color.withOpacity(0.24),
                color.withOpacity(0.2),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.85),
                Colors.white.withOpacity(0.9),
              ],
            ),
      borderColor: color.withOpacity(
        isDark ? 0.5 : 0.4,
      ), // Brighter border in dark mode
      borderWidth: 2,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
      child: Container(
        constraints: BoxConstraints(minHeight: 100, maxHeight: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: isDark
                        ? color.withOpacity(0.35) // Brighter in dark mode
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
                    color: isDark
                        ? Colors
                              .white // Bright white icons in dark mode
                        : color,
                    size: (screenWidth * 0.07).clamp(24.0, 32.0),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.025),
              Flexible(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors
                                .white // Bright white text in dark mode
                          : color,
                      fontWeight: FontWeight.bold,
                      fontSize: (12 / textScale).clamp(10.0, 14.0),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(20),
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
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.85),
              ],
            ),
      borderColor: isDark
          ? Colors.white.withOpacity(0.2)
          : AppColors.primaryBlue.withOpacity(0.2),
      borderWidth: 1.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
            ),
            child: product.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product.images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '₹${product.price}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.successGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${product.rewardPoints} pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
