/// BiasMitra Dashboard Screen
/// Main dashboard showing government schemes for bias auditing
/// Features: Welcome message, logout button, GridView with scheme cards

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../auth/services/auth_service.dart';
import '../../upload/screens/upload_screen.dart';
import '../widgets/scheme_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Handle Logout
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userName = authService.currentUserName ?? 'User';

    return Scaffold(
      // AppBar with Logo and Logout
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
          ),
          child: const Icon(
            Icons.balance,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: AppStrings.logout,
          ),
        ],
      ),

      // Main Content
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Application Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConfig.defaultPadding),
                margin: const EdgeInsets.only(bottom: AppConfig.defaultPadding * 1.5),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: AppConfig.defaultPadding),
                    Expanded(
                      child: Text(
                        'NOTE: Currently, only the Bank Loans feature is activated.',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Welcome Section
              _buildWelcomeSection(userName),

              const SizedBox(height: AppConfig.defaultPadding * 2),

              // Audit Instructions
              _buildInstructionsCard(),

              const SizedBox(height: AppConfig.defaultPadding * 2),

              // Schemes Grid Title
              Text(
                AppStrings.auditSchemes,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                AppStrings.selectScheme,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutralGray),
              ),

              const SizedBox(height: AppConfig.defaultPadding * 1.5),

              // Schemes Grid
              _buildSchemesGrid(),

              const SizedBox(height: AppConfig.defaultPadding * 2),
            ],
          ),
        ),
      ),
    );
  }

  /// Welcome Section
  Widget _buildWelcomeSection(String userName) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding * 1.5),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primaryBlue,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConfig.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.welcome}, $userName!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Instructions Card
  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding * 1.5),
      decoration: BoxDecoration(
        color: AppColors.accentSaffronLighter,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        border: Border.all(color: AppColors.accentSaffron.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.accentSaffron,
            size: 24,
          ),
          const SizedBox(width: AppConfig.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to Use',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.accentSaffron,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a government scheme, upload data, and let our AI detect potential biases in decision-making.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.accentSaffron,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Schemes Grid
  Widget _buildSchemesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppConfig.defaultPadding,
      mainAxisSpacing: AppConfig.defaultPadding,
      childAspectRatio: 0.95,
      children: [
        // PM-KISAN Scheme
        SchemeCard(
          title: AppStrings.schemePMKisan,
          subtitle: AppStrings.schemePMKisanDesc,
          icon: Icons.agriculture,
          index: 0,
          onTap: () => _navigateToAudit(
            name: AppStrings.schemePMKisan,
            description: AppStrings.schemePMKisanDesc,
            icon: Icons.agriculture,
            index: 0,
          ),
        ),

        // Scholarships Scheme
        SchemeCard(
          title: AppStrings.schemeScholarships,
          subtitle: AppStrings.schemeScholarshipsDesc,
          icon: Icons.school,
          index: 1,
          onTap: () => _navigateToAudit(
            name: AppStrings.schemeScholarships,
            description: AppStrings.schemeScholarshipsDesc,
            icon: Icons.school,
            index: 1,
          ),
        ),

        // Bank Loans Scheme
        SchemeCard(
          title: AppStrings.schemeBankLoans,
          subtitle: AppStrings.schemeBankLoansDesc,
          icon: Icons.account_balance,
          index: 2,
          onTap: () => _navigateToAudit(
            name: AppStrings.schemeBankLoans,
            description: AppStrings.schemeBankLoansDesc,
            icon: Icons.account_balance,
            index: 2,
          ),
        ),

        // Ujjwala Yojana Scheme
        SchemeCard(
          title: AppStrings.schemeUjjwala,
          subtitle: AppStrings.schemeUjjwalaDesc,
          icon: Icons.local_fire_department,
          index: 3,
          onTap: () => _navigateToAudit(
            name: AppStrings.schemeUjjwala,
            description: AppStrings.schemeUjjwalaDesc,
            icon: Icons.local_fire_department,
            index: 3,
          ),
        ),
      ],
    );
  }

  /// Navigate to the Upload CSV screen for the selected scheme
  void _navigateToAudit({
    required String name,
    required String description,
    required IconData icon,
    required int index,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadScreen(
          schemeName: name,
          schemeDescription: description,
          schemeIcon: icon,
          schemeIndex: index,
        ),
      ),
    );
  }
}
