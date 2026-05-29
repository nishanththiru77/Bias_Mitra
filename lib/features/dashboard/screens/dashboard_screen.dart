import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../auth/screens/profile_screen.dart';
import '../../auth/models/government_profile.dart';
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
    final profile = authService.currentProfile;
    final bool isCompleted = profile?.isCompleted ?? false;
    final bool isCorporate = profile?.userType == 'corporate';

    return Scaffold(
      backgroundColor: AppColors.neutralGrayLighter,
      // AppBar with Logo, Profile Settings, and Logout
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
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            tooltip: 'Official Profile',
          ),
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
              // ⚠️ Complete Profile Banner (If profile is incomplete)
              if (!isCompleted) _buildProfileSetupBanner(userName),

              // Bank Application Note (Only for government/default, or if loans are active)
              if (isCompleted && !isCorporate)
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
                          'NOTE: Currently, only the Bank Loans feature is activated for bias detection.',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Welcome Section
              _buildWelcomeSection(userName, profile),

              const SizedBox(height: AppConfig.defaultPadding * 1.5),

              // Audit Instructions
              _buildInstructionsCard(),

              const SizedBox(height: AppConfig.defaultPadding * 2),

              // Schemes Grid Title
              Text(
                isCorporate ? 'Corporate Auditing Modules' : AppStrings.auditSchemes,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                isCorporate 
                    ? 'Select an enterprise module to audit candidate and employee metrics' 
                    : AppStrings.selectScheme,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutralGray),
              ),

              const SizedBox(height: AppConfig.defaultPadding * 1.5),

              // Dynamic Schemes Grid
              _buildSchemesGrid(profile),

              const SizedBox(height: AppConfig.defaultPadding * 2),
            ],
          ),
        ),
      ),
    );
  }

  /// Complete Profile Prompt Banner (role-aware text)
  Widget _buildProfileSetupBanner(String userName) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profile = authService.currentProfile;
    final bool isCorporate = profile?.userType == 'corporate';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      margin: const EdgeInsets.only(bottom: AppConfig.defaultPadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCorporate
              ? [const Color(0xFF1F2937), const Color(0xFF065F46)]
              : [const Color(0xFF1E3A8A), const Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: (isCorporate ? AppColors.secondaryGreen : AppColors.accentSaffron)
                .withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorporate ? Icons.business_center : Icons.account_balance,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: AppConfig.defaultPadding),
              Expanded(
                child: Text(
                  isCorporate
                      ? 'Complete Corporate Auditor Credentials'
                      : 'Complete Government Officer Credentials',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isCorporate
                ? 'To unlock enterprise auditing modules, please fill in your Corporate Auditor profile details.'
                : 'To maintain compliance and auditing accountability, please fill out your Official Officer Credentials before accessing bias detection.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: Icon(isCorporate ? Icons.badge : Icons.security, size: 16),
            label: const Text('Complete Profile Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
                  isCorporate ? AppColors.secondaryGreen : AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  /// Welcome Section
  Widget _buildWelcomeSection(String userName, GovernmentProfile? profile) {
    final bool isCompleted = profile?.isCompleted ?? false;
    final bool isCorporate = profile?.userType == 'corporate';

    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCorporate 
              ? [const Color(0xFF27272A), AppColors.secondaryGreen] 
              : [AppColors.primaryBlue, AppColors.primaryBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: (isCorporate ? AppColors.secondaryGreen : AppColors.primaryBlue).withOpacity(0.2),
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
                child: Icon(
                  isCorporate ? Icons.business : Icons.person_outline,
                  color: isCorporate ? AppColors.secondaryGreen : AppColors.primaryBlue,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConfig.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${AppStrings.welcome}, $userName!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: Colors.lightGreenAccent, size: 20),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? (isCorporate 
                              ? 'Corporate Auditor | ${profile?.companyName}' 
                              : 'Govt Officer | ${profile?.ministry}')
                          : AppStrings.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  'Select a fairness auditing module below, upload decision data (CSV/Excel), and let our Gemini AI run bias analysis reports.',
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

  /// Dynamic Grid Filtering Gov vs Corp Modules
  Widget _buildSchemesGrid(GovernmentProfile? profile) {
    final bool isCorporate = profile?.userType == 'corporate';

    if (isCorporate) {
      // 💼 Corporate/Private Enterprise Grid View
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppConfig.defaultPadding,
        mainAxisSpacing: AppConfig.defaultPadding,
        childAspectRatio: 0.90,
        children: [
          // Hiring & Recruitment
          SchemeCard(
            title: AppStrings.schemeHiring,
            subtitle: AppStrings.schemeHiringDesc,
            icon: Icons.people_outline,
            index: 0,
            isCorporate: true,
            onTap: () => _navigateToAudit(
              name: AppStrings.schemeHiring,
              description: AppStrings.schemeHiringDesc,
              icon: Icons.people_outline,
              index: 0,
            ),
          ),

          // Promotion & Appraisals
          SchemeCard(
            title: AppStrings.schemePromotion,
            subtitle: AppStrings.schemePromotionDesc,
            icon: Icons.trending_up,
            index: 1,
            isCorporate: true,
            onTap: () => _navigateToAudit(
              name: AppStrings.schemePromotion,
              description: AppStrings.schemePromotionDesc,
              icon: Icons.trending_up,
              index: 1,
            ),
          ),

          // Private Credit Scoring
          SchemeCard(
            title: AppStrings.schemeCredit,
            subtitle: AppStrings.schemeCreditDesc,
            icon: Icons.credit_card_outlined,
            index: 2,
            isCorporate: true,
            onTap: () => _navigateToAudit(
              name: AppStrings.schemeCredit,
              description: AppStrings.schemeCreditDesc,
              icon: Icons.credit_card_outlined,
              index: 2,
            ),
          ),
        ],
      );
    }

    // 🏛️ Government schemes (Default)
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppConfig.defaultPadding,
      mainAxisSpacing: AppConfig.defaultPadding,
      childAspectRatio: 0.90,
      children: [
        // PM-KISAN Scheme
        SchemeCard(
          title: AppStrings.schemePMKisan,
          subtitle: AppStrings.schemePMKisanDesc,
          icon: Icons.agriculture,
          index: 0,
          isCorporate: false,
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
          isCorporate: false,
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
          isCorporate: false,
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
          isCorporate: false,
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

  /// Securely Intercept Uncompleted Profiles before launching audits
  void _navigateToAudit({
    required String name,
    required String description,
    required IconData icon,
    required int index,
  }) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profile = authService.currentProfile;
    final bool isCorporate = profile?.userType == 'corporate';

    if (profile?.isCompleted != true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.lock,
                color: isCorporate ? AppColors.secondaryGreen : AppColors.accentSaffron,
              ),
              const SizedBox(width: 8),
              const Text('Credentials Required'),
            ],
          ),
          content: Text(
            isCorporate
                ? 'Please complete your Corporate Auditor profile to access enterprise bias auditing modules.'
                : 'To maintain compliance, auditing trails, and accountability, you must fill out your Official Credentials before accessing bias detection systems.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Text(
                'Complete Profile',
                style: TextStyle(
                  color: isCorporate ? AppColors.secondaryGreen : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadScreen(
          schemeName: name,
          schemeDescription: description,
          schemeIcon: icon,
          schemeIndex: index,
          isCorporate: isCorporate,
        ),
      ),
    );
  }
}
