/// BiasMitra Core Constants
/// Contains all app-wide color definitions, strings, and configuration values
/// Color Scheme: Saffron (Orange), Green, Blue - Indian Heritage Colors

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App Color Palette - Indian Colors Theme
class AppColors {
  // Primary Colors - Blue (Trust, Technology)
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep Blue
  static const Color primaryBlueLight = Color(0xFF3B82F6); // Light Blue
  static const Color primaryBlueLighter = Color(0xFFDBEAFE); // Very Light Blue

  // Secondary Colors - Green (Harmony, Growth)
  static const Color secondaryGreen = Color(0xFF10B981); // Emerald Green
  static const Color secondaryGreenLight = Color(0xFFA7F3D0); // Light Green
  static const Color secondaryGreenLighter = Color(
    0xFFD1FAE5,
  ); // Very Light Green

  // Accent Colors - Saffron (Orange) (Hope, Energy)
  static const Color accentSaffron = Color(0xFFFF6B35); // Bright Saffron
  static const Color accentSaffronLight = Color(0xFFFFB380); // Light Saffron
  static const Color accentSaffronLighter = Color(
    0xFFFFDCC4,
  ); // Very Light Saffron

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color neutralGray = Color(0xFF6B7280); // Gray for secondary text
  static const Color neutralGrayLight = Color(
    0xFFF3F4F6,
  ); // Light gray background
  static const Color neutralGrayLighter = Color(0xFFF9FAFB); // Very light gray

  // Status Colors
  static const Color success = Color(0xFF059669); // Success Green
  static const Color error = Color(0xFFEF4444); // Error Red
  static const Color warning = Color(0xFFF59E0B); // Warning Amber
  static const Color info = Color(0xFF3B82F6); // Info Blue

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentSaffron, accentSaffronLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// App Typography Strings
class AppStrings {
  // App Identity
  static const String appName = 'BiasMitra';
  static const String appTagline = 'Unbiased AI for Bharat';
  static const String appDescription =
      'Detect and mitigate bias in AI decisions for government schemes';

  // Authentication Screens
  static const String loginTitle = 'Welcome to BiasMitra';
  static const String loginSubtitle = 'Unbiased AI for Bharat';
  static const String email = 'Email';
  static const String emailHint = 'Enter your email';
  static const String password = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String loginWithGoogle = 'Login with Google';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = 'Don\'t have an account? ';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String createNewAccount = 'Create new account';
  static const String signInWithGoogle = 'Sign in with Google';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String welcome = 'Welcome';
  static const String auditSchemes = 'Audit Schemes for Bias';
  static const String selectScheme = 'Select a scheme to audit';
  static const String logout = 'Logout';
  static const String home = 'Home';
  static const String audits = 'Audits';
  static const String history = 'History';
  static const String settings = 'Settings';

  // Scheme Names
  static const String schemePMKisan = 'PM-KISAN';
  static const String schemePMKisanDesc = 'Pradhan Mantri Kisan Samman Nidhi';
  static const String schemeScholarships = 'Scholarships';
  static const String schemeScholarshipsDesc = 'Education & Merit Scholarships';
  static const String schemeBankLoans = 'Bank Loans';
  static const String schemeBankLoansDesc = 'Credit & Business Loans';
  static const String schemeUjjwala = 'Ujjwala Yojana';
  static const String schemeUjjwalaDesc = 'LPG Connection Distribution';

  // Generic Buttons & Actions
  static const String upload = 'Upload';
  static const String analyze = 'Analyze';
  static const String download = 'Download';
  static const String share = 'Share';
  static const String back = 'Back';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';

  // Messages
  static const String loading = 'Loading...';
  static const String error = 'An error occurred';
  static const String success = 'Success';
  static const String tryAgain = 'Try Again';
  static const String noData = 'No data available';
  static const String askingForPermission = 'Requesting permissions...';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';

  // Empty States
  static const String noAuditsYet = 'No audits yet';
  static const String startYourFirstAudit = 'Start your first bias audit';
  static const String noHistoryYet = 'No history yet';

  // Bias Detection Related
  static const String biasAnalysis = 'Bias Analysis';
  static const String fairnessScore = 'Fairness Score';
  static const String biasDetected = 'Bias Detected';
  static const String noBiasDetected = 'No Bias Detected';
  static const String riskLevel = 'Risk Level';
  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';
}

/// App Configuration Constants
class AppConfig {
  // API Configuration
  static const String firebaseProjectId = 'bias-mitra-solution-challenge';
  
  // Fetches key securely from .env file
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY_HERE';

  // CSV Processing
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedFileTypes = ['csv', 'xlsx', 'json'];

  // Bias Detection Thresholds
  static const double highBiasThreshold = 0.7;
  static const double mediumBiasThreshold = 0.4;

  // UI Constants
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;
}
