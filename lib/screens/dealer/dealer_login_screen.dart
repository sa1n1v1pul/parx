import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glassmorphic_container.dart';
import '../dealer/dealer_home_screen.dart';

class DealerLoginScreen extends StatefulWidget {
  const DealerLoginScreen({super.key});

  @override
  State<DealerLoginScreen> createState() => _DealerLoginScreenState();
}

class _DealerLoginScreenState extends State<DealerLoginScreen> {
  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.login(
        _loginController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        Get.offAll(() => const DealerHomeScreen());
      } else {
        Get.snackbar(
          'Login Failed',
          _authController.errorMessage.value,
          backgroundColor: AppColors.error,
          colorText: AppColors.textLight,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Title
                    GlassmorphicContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(60),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderColor: Colors.white.withOpacity(0.4),
                      borderWidth: 2,
                      child: const Icon(
                        Icons.store,
                        size: 60,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Dealer Login',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Login Field
                    GlassmorphicContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.85),
                        ],
                      ),
                      borderColor: Colors.white.withOpacity(0.5),
                      borderWidth: 2,
                      child: TextFormField(
                        controller: _loginController,
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        decoration: InputDecoration(
                          labelText: 'Mobile / Username',
                          labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          prefixIcon: Icon(Icons.person, color: AppColors.primaryBlue),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mobile or username';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Password Field
                    GlassmorphicContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.85),
                        ],
                      ),
                      borderColor: Colors.white.withOpacity(0.5),
                      borderWidth: 2,
                      child: TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          prefixIcon: const Icon(Icons.lock, color: AppColors.primaryBlue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Login Button
                    Obx(() => GlassmorphicContainer(
                      width: double.infinity,
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.85),
                        ],
                      ),
                      borderColor: Colors.white.withOpacity(0.6),
                      borderWidth: 2,
                      onTap: _authController.isLoading.value
                          ? null
                          : _handleLogin,
                      child: _authController.isLoading.value
                          ? const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

