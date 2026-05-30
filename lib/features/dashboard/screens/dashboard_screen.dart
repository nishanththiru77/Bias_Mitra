import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                  margin: const EdgeInsets.only(
                      bottom: AppConfig.defaultPadding * 1.5),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius:
                        BorderRadius.circular(AppConfig.defaultBorderRadius),
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
                isCorporate
                    ? 'Corporate Auditing Modules'
                    : AppStrings.auditSchemes,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
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
            color: (isCorporate
                    ? AppColors.secondaryGreen
                    : AppColors.accentSaffron)
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
              foregroundColor: isCorporate
                  ? AppColors.secondaryGreen
                  : AppColors.primaryBlue,
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
            color:
                (isCorporate ? AppColors.secondaryGreen : AppColors.primaryBlue)
                    .withOpacity(0.2),
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
                  color: isCorporate
                      ? AppColors.secondaryGreen
                      : AppColors.primaryBlue,
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified,
                              color: Colors.lightGreenAccent, size: 20),
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

  /// Data models for scheme/module definitions
  static const List<Map<String, dynamic>> _governmentSchemes = [
    {
      'id': 'pm-kisan',
      'title': AppStrings.schemePMKisan,
      'description': AppStrings.schemePMKisanDesc,
      'icon': Icons.agriculture,
      'index': 0,
    },
    {
      'id': 'scholarships',
      'title': AppStrings.schemeScholarships,
      'description': AppStrings.schemeScholarshipsDesc,
      'icon': Icons.school,
      'index': 1,
    },
    {
      'id': 'bank-loans',
      'title': AppStrings.schemeBankLoans,
      'description': AppStrings.schemeBankLoansDesc,
      'icon': Icons.account_balance,
      'index': 2,
    },
    {
      'id': 'ujjwala',
      'title': AppStrings.schemeUjjwala,
      'description': AppStrings.schemeUjjwalaDesc,
      'icon': Icons.local_fire_department,
      'index': 3,
    },
  ];

  static const List<Map<String, dynamic>> _corporateModules = [
    {
      'id': 'hiring',
      'title': AppStrings.schemeHiring,
      'description': AppStrings.schemeHiringDesc,
      'icon': Icons.people_outline,
      'index': 0,
    },
    {
      'id': 'promotion',
      'title': AppStrings.schemePromotion,
      'description': AppStrings.schemePromotionDesc,
      'icon': Icons.trending_up,
      'index': 1,
    },
    {
      'id': 'credit',
      'title': AppStrings.schemeCredit,
      'description': AppStrings.schemeCreditDesc,
      'icon': Icons.credit_card_outlined,
      'index': 2,
    },
  ];

  /// Dynamic Grid Filtering Gov vs Corp Modules with Firestore Integration
  Widget _buildSchemesGrid(GovernmentProfile? profile) {
    final bool isCorporate = profile?.userType == 'corporate';
    final authService = Provider.of<AuthService>(context);
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      return _buildEmptyStateWidget('Unable to load profile');
    }

    // Use StreamBuilder to listen for real-time profile updates from Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyStateWidget('Error loading modules');
        }

        // If data is available, use it; otherwise fall back to current profile
        final List<String> selectedItems = [];
        if (snapshot.hasData && snapshot.data?.exists == true) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (isCorporate) {
            selectedItems.addAll(List<String>.from(data?['selectedModules'] ?? []));
          } else {
            selectedItems.addAll(List<String>.from(data?['selectedSchemes'] ?? []));
          }
        } else if (profile != null) {
          // Fallback to profile data
          if (isCorporate) {
            selectedItems.addAll(profile.selectedModules);
          } else {
            selectedItems.addAll(profile.selectedSchemes);
          }
        }

        // DEBUG: Log what we fetched vs what the schemes define
        // Firestore stores display names (e.g. "Bank Loans"), NOT slug IDs ("bank-loans").
        // So we MUST compare against s['title'], not s['id'].
        assert(() {
          debugPrint('[BiasMitra] isCorporate=$isCorporate');
          debugPrint('[BiasMitra] selectedItems from Firestore: $selectedItems');
          final allTitles = isCorporate
              ? _corporateModules.map((m) => m['title']).toList()
              : _governmentSchemes.map((s) => s['title']).toList();
          debugPrint('[BiasMitra] Available scheme titles: $allTitles');
          return true;
        }());

        // ✅ FIX: Compare against 'title' (display name stored in Firestore),
        //         NOT 'id' (internal slug). Firestore stores "Bank Loans" not "bank-loans".
        final List<Map<String, dynamic>> modulesToShow = isCorporate
            ? _corporateModules
                .where((m) => selectedItems.isEmpty || selectedItems.contains(m['title']))
                .toList()
            : _governmentSchemes
                .where((s) => selectedItems.isEmpty || selectedItems.contains(s['title']))
                .toList();

        assert(() {
          debugPrint('[BiasMitra] modulesToShow count: ${modulesToShow.length}');
          debugPrint('[BiasMitra] modulesToShow titles: ${modulesToShow.map((m) => m["title"]).toList()}');
          return true;
        }());

        // Show empty state ONLY if the user has explicitly selected schemes/modules
        // but none of them matched any known scheme title.
        if (modulesToShow.isEmpty && selectedItems.isNotEmpty) {
          return _buildNoAccessWidget(isCorporate);
        }

        // Build responsive grid
        return LayoutBuilder(
          builder: (context, constraints) {
            // Determine optimal childAspectRatio based on screen width
            final double childAspectRatio = constraints.maxWidth > 400 ? 0.92 : 0.85;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppConfig.defaultPadding,
                crossAxisSpacing: AppConfig.defaultPadding,
                childAspectRatio: childAspectRatio,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modulesToShow.length,
              itemBuilder: (context, index) {
                final module = modulesToShow[index];
                return SchemeCard(
                  title: module['title'] as String,
                  subtitle: module['description'] as String,
                  icon: module['icon'] as IconData,
                  index: module['index'] as int,
                  isCorporate: isCorporate,
                  onTap: () => _navigateToAudit(
                    name: module['title'] as String,
                    description: module['description'] as String,
                    icon: module['icon'] as IconData,
                    index: module['index'] as int,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Widget showing "No access" message when user has no authorized modules
  Widget _buildNoAccessWidget(bool isCorporate) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding * 2),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            'No Module Access',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.orange.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCorporate
                ? 'No corporate auditing modules assigned. Please update your profile.'
                : 'No government schemes assigned. Please update your profile.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Update Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Generic empty state widget
  Widget _buildEmptyStateWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.neutralGray,
            ),
          ),
        ],
      ),
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
                color: isCorporate
                    ? AppColors.secondaryGreen
                    : AppColors.accentSaffron,
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
                  color: isCorporate
                      ? AppColors.secondaryGreen
                      : AppColors.primaryBlue,
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
