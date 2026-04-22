/// BiasMitra Login Screen
/// Beautiful authentication screen with Indian color scheme
/// Features: Email/Password login, Google Sign In, Sign Up option

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle Email/Password Sign In
  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final userCredential = await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        return;
      }

      setState(() {
        _errorMessage = 'Login failed. Please try again.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.signInWithGoogle();
      
      // Wait a moment for Firebase to update auth state on web
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if user is actually signed in
      if (authService.currentUser != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        return;
      }

      if (mounted) {
        setState(() {
          _errorMessage = 'Google sign-in failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Navigate to Sign Up Screen
  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConfig.defaultPadding,
            vertical: AppConfig.defaultPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== Logo Section =====
              SizedBox(height: screenSize.height * 0.05),
              _buildLogoSection(),

              SizedBox(height: screenSize.height * 0.08),

              // ===== Title & Subtitle =====
              _buildTitleSection(),

              SizedBox(height: screenSize.height * 0.06),

              // ===== Error Message =====
              if (_errorMessage != null) _buildErrorBanner(),

              SizedBox(height: AppConfig.defaultPadding),

              // ===== Login Form =====
              _buildLoginForm(),

              SizedBox(height: AppConfig.defaultPadding * 1.5),

              // ===== Sign In Button =====
              _buildSignInButton(),

              SizedBox(height: AppConfig.defaultPadding),

              // ===== Divider =====
              _buildDivider(),

              SizedBox(height: AppConfig.defaultPadding),

              // ===== Google Sign In Button =====
              _buildGoogleSignInButton(),

              SizedBox(height: AppConfig.defaultPadding * 1.5),

              // ===== Sign Up Link =====
              _buildSignUpLink(),

              SizedBox(height: screenSize.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo Section with Balance Icon
  Widget _buildLogoSection() {
    return Column(
      children: [
        // Balance Icon in rounded container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.balance, size: 60, color: AppColors.white),
        ),
      ],
    );
  }

  /// Title and Subtitle Section
  Widget _buildTitleSection() {
    return Column(
      children: [
        // App Name
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // Tagline
        Text(
          AppStrings.appTagline,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.accentSaffron,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          'Detect and prevent bias in AI decisions',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.neutralGray,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Error Banner
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        border: Border.all(color: AppColors.error.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Login Form (Email & Password)
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field Label
          Text(AppStrings.email, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),

          // Email Text Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: AppStrings.emailHint,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return AppStrings.emailRequired;
              }
              if (!value!.contains('@')) {
                return AppStrings.emailInvalid;
              }
              return null;
            },
          ),

          const SizedBox(height: AppConfig.defaultPadding),

          // Password Field Label
          Text(
            AppStrings.password,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),

          // Password Text Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: AppStrings.passwordHint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return AppStrings.passwordRequired;
              }
              if (value!.length < 6) {
                return AppStrings.passwordTooShort;
              }
              return null;
            },
          ),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              child: Text(
                AppStrings.forgotPassword,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sign In Button
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailSignIn,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                AppStrings.login,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
              ),
      ),
    );
  }

  /// Divider with "OR"
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.neutralGray),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  /// Google Sign In Button
  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.g_mobiledata,
              color: AppColors.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.signInWithGoogle,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sign Up Link
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.neutralGray),
        ),
        GestureDetector(
          onTap: _goToSignUp,
          child: Text(
            AppStrings.signUp,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.accentSaffron,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }
}
