import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../models/government_profile.dart';
import '../services/auth_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  /// When true the screen is shown as an onboarding step (new user).
  /// Saving the profile will push DashboardScreen instead of popping back.
  final bool isOnboarding;

  const ProfileScreen({Key? key, this.isOnboarding = false}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // State fields
  late String _userType;
  late List<String> _auditedSchemes;
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _idController; // Handles both Officer ID and Employee ID
  late TextEditingController _orgController; // Handles Corporate Company Name

  // Selected dropdown properties
  String? _selectedMinistry;
  String? _selectedJurisdiction;
  String? _selectedState;
  String? _selectedDepartment;
  String? _selectedSector;

  // Static options
  final List<String> _ministries = [
    'Ministry of Agriculture & Farmers Welfare',
    'Ministry of Education & Social Empowerment',
    'Ministry of Finance & Credit Distribution',
    'Ministry of Petroleum & Natural Gas'
  ];

  final List<String> _jurisdictions = ['National', 'State-Level', 'District-Level'];

  final List<String> _states = [
    'Delhi (NCT)',
    'Karnataka',
    'Maharashtra',
    'Tamil Nadu',
    'Uttar Pradesh',
    'West Bengal',
    'Gujarat',
    'Telangana'
  ];

  final List<String> _departments = [
    'Human Resources (HR)',
    'Risk & Credit Management',
    'Audit & Compliance Team',
    'Data Science & AI Division',
    'Executive Leadership'
  ];

  final List<String> _sectors = [
    'HR & Recruitment Fairness',
    'Private Banking & Fintech',
    'Technology & Algorithmic Safety',
    'Corporate Operations'
  ];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final profile = authService.currentProfile;

    _userType = profile?.userType ?? 'government';
    _nameController = TextEditingController(text: profile?.name ?? authService.currentUser?.displayName ?? '');
    _idController = TextEditingController(text: _userType == 'government' ? profile?.officerId : profile?.employeeId);
    _orgController = TextEditingController(text: profile?.companyName ?? '');

    _selectedMinistry = profile?.ministry.isNotEmpty == true ? profile?.ministry : null;
    _selectedJurisdiction = profile?.jurisdiction.isNotEmpty == true ? profile?.jurisdiction : 'National';
    _selectedState = profile?.state.isNotEmpty == true ? profile?.state : null;
    _selectedDepartment = profile?.department.isNotEmpty == true ? profile?.department : null;
    _selectedSector = profile?.industrySector.isNotEmpty == true ? profile?.industrySector : null;

    _auditedSchemes = List<String>.from(profile?.auditedSchemes ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  /// Toggle user sector
  void _setUserType(String type) {
    setState(() {
      _userType = type;
      _idController.clear();
      _auditedSchemes.clear();
    });
  }

  /// Toggle individual scheme selection
  void _toggleScheme(String scheme) {
    setState(() {
      if (_auditedSchemes.contains(scheme)) {
        _auditedSchemes.remove(scheme);
      } else {
        _auditedSchemes.add(scheme);
      }
    });
  }

  /// Handle Save Action
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user == null) return;

      final updatedProfile = GovernmentProfile(
        uid: user.uid,
        email: user.email ?? '',
        name: _nameController.text.trim(),
        userType: _userType,
        isCompleted: true,
        officerId: _userType == 'government' ? _idController.text.trim() : '',
        ministry: _userType == 'government' ? (_selectedMinistry ?? '') : '',
        jurisdiction: _userType == 'government' ? (_selectedJurisdiction ?? 'National') : '',
        state: (_userType == 'government' && _selectedJurisdiction != 'National') ? (_selectedState ?? '') : '',
        employeeId: _userType == 'corporate' ? _idController.text.trim() : '',
        companyName: _userType == 'corporate' ? _orgController.text.trim() : '',
        department: _userType == 'corporate' ? (_selectedDepartment ?? '') : '',
        industrySector: _userType == 'corporate' ? (_selectedSector ?? '') : '',
        auditedSchemes: _auditedSchemes,
      );

      await authService.saveUserProfile(updatedProfile);

      setState(() {
        _successMessage = 'Credentials successfully verified & stored!';
      });

      // If this is the onboarding flow, navigate to dashboard.
      // Otherwise just pop back to where the user came from.
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          if (widget.isOnboarding) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (_) => false,
            );
          } else {
            Navigator.pop(context);
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save credentials: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGrayLighter,
      appBar: AppBar(
        title: Text(
          widget.isOnboarding ? 'Set Up Your Profile' : 'Official Profile Settings',
        ),
        // Hide the back button during onboarding so user can't skip it
        automaticallyImplyLeading: !widget.isOnboarding,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 💳 Digital Identity Badge
                _buildDigitalIDCard(),

                const SizedBox(height: AppConfig.defaultPadding * 1.5),

                // Sector Selectors (Government vs Corporate)
                _buildSectorSelectors(),

                const SizedBox(height: AppConfig.defaultPadding * 1.5),

                // Messages
                if (_successMessage != null) _buildAlertCard(AppColors.success, Icons.check_circle_outline, _successMessage!),
                if (_errorMessage != null) _buildAlertCard(AppColors.error, Icons.error_outline, _errorMessage!),

                const SizedBox(height: AppConfig.defaultPadding),

                // General User Info
                Text('Auditor Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildProfileInputs(),

                const SizedBox(height: AppConfig.defaultPadding * 2),

                // Scheme Assignments
                Text(
                  _userType == 'government' ? 'Assigned Scheme Scopes' : 'Corporate Auditing Scopes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(
                  'Select the primary modules you are authorized to audit.',
                  style: TextStyle(color: AppColors.neutralGray, fontSize: 13)
                ),
                const SizedBox(height: 12),
                _buildSchemeCheckboxes(),

                const SizedBox(height: AppConfig.defaultPadding * 2.5),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userType == 'government' ? AppColors.primaryBlue : AppColors.secondaryGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.white))
                        : const Text('Verify & Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: AppConfig.defaultPadding * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Digital ID Visual Representation Card
  Widget _buildDigitalIDCard() {
    final bool isGov = _userType == 'government';
    final String orgLabel = isGov ? (_selectedMinistry ?? 'Select Ministry') : (_orgController.text.isNotEmpty ? _orgController.text : 'Select Company');
    final String idLabel = _idController.text.isNotEmpty ? _idController.text : (isGov ? 'OFFICER ID' : 'EMPLOYEE ID');
    
    // Dynamic styles
    final Color topGradient = isGov ? AppColors.primaryBlue : const Color(0xFF27272A);
    final Color bottomGradient = isGov ? AppColors.accentSaffron : AppColors.secondaryGreen;
    final IconData watermarkIcon = isGov ? Icons.balance : Icons.business;
    final String badgeLabel = isGov ? 'VERIFIED PUBLIC OFFICIAL' : 'VERIFIED PRIVATE AUDITOR';

    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topGradient, bottomGradient],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: topGradient.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark Icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.12,
              child: Icon(watermarkIcon, size: 240, color: AppColors.white),
            ),
          ),

          // National Emblem Tag (For government only)
          if (isGov)
            const Positioned(
              right: 16,
              top: 16,
              child: Row(
                children: [
                  Icon(Icons.gavel, color: AppColors.white, size: 16),
                  SizedBox(width: 4),
                  Text('GOVT OF INDIA', style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ),

          // Card contents
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: AppColors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            badgeLabel,
                            style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Name & Info Block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isNotEmpty ? _nameController.text.toUpperCase() : 'AUDITOR NAME',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orgLabel,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // ID Number & Clearance Tier
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID NUMBER',
                          style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          idLabel,
                          style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SECURITY CLEARANCE',
                          style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isGov ? (_selectedJurisdiction == 'National' ? 'L3 - National' : _selectedJurisdiction == 'State-Level' ? 'L2 - Regional' : 'L1 - Local') : 'Enterprise Admin',
                          style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
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

  /// Segmented Toggles to swap UserType
  Widget _buildSectorSelectors() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Government Officer Toggle
          Expanded(
            child: GestureDetector(
              onTap: () => _setUserType('government'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _userType == 'government' ? AppColors.primaryBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance, color: _userType == 'government' ? AppColors.white : AppColors.neutralGray, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Govt Officer',
                        style: TextStyle(
                          color: _userType == 'government' ? AppColors.white : AppColors.neutralGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Corporate Auditor Toggle
          Expanded(
            child: GestureDetector(
              onTap: () => _setUserType('corporate'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _userType == 'corporate' ? AppColors.secondaryGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_center, color: _userType == 'corporate' ? AppColors.white : AppColors.neutralGray, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Private Auditor',
                        style: TextStyle(
                          color: _userType == 'corporate' ? AppColors.white : AppColors.neutralGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom Form Alert Cards
  Widget _buildAlertCard(Color color, IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  /// Dynamic Form Fields
  Widget _buildProfileInputs() {
    final bool isGov = _userType == 'government';

    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auditor Full Name
          Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline),
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            validator: (val) => val?.isEmpty ?? true ? 'Name is required' : null,
          ),

          const SizedBox(height: AppConfig.defaultPadding),

          // ID Field (Officer ID vs Employee ID)
          Text(isGov ? 'Government Officer ID' : 'Employee ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _idController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: isGov ? 'e.g. GOV-NIC-2026-098' : 'e.g. EMP-TECH-4402',
              prefixIcon: Icon(isGov ? Icons.fingerprint : Icons.badge_outlined),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            validator: (val) => val?.isEmpty ?? true ? 'Identification ID is required' : null,
          ),

          const SizedBox(height: AppConfig.defaultPadding),

          // Government Specific Options
          if (isGov) ...[
            // Ministry Select
            Text('Responsible Ministry', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedMinistry,
              hint: const Text('Select your Ministry'),
              items: _ministries.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) => setState(() => _selectedMinistry = val),
              validator: (val) => val == null ? 'Please choose your ministry' : null,
            ),

            const SizedBox(height: AppConfig.defaultPadding),

            // Jurisdiction Level
            Text('Jurisdiction Area', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedJurisdiction,
              items: _jurisdictions.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
              onChanged: (val) => setState(() {
                _selectedJurisdiction = val;
                if (val == 'National') {
                  _selectedState = null;
                }
              }),
            ),

            // State Select (Only if local or regional)
            if (_selectedJurisdiction != 'National') ...[
              const SizedBox(height: AppConfig.defaultPadding),
              Text('State / UT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedState,
                hint: const Text('Select State'),
                items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedState = val),
                validator: (val) => val == null ? 'Please choose your state' : null,
              ),
            ],
          ] else ...[
            // Corporate Specific Options
            // Corporate Company Name
            Text('Company / Corporate Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _orgController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'e.g. Infosys, ICICI Bank, Tata Group',
                prefixIcon: Icon(Icons.business),
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              validator: (val) => val?.isEmpty ?? true ? 'Company name is required' : null,
            ),

            const SizedBox(height: AppConfig.defaultPadding),

            // Corporate Department
            Text('Corporate Department', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              hint: const Text('Select Department'),
              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _selectedDepartment = val),
              validator: (val) => val == null ? 'Please choose your department' : null,
            ),

            const SizedBox(height: AppConfig.defaultPadding),

            // Industry Sector
            Text('Enterprise Industry Sector', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedSector,
              hint: const Text('Select Sector'),
              items: _sectors.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSector = val),
              validator: (val) => val == null ? 'Please choose your industry sector' : null,
            ),
          ],
        ],
      ),
    );
  }

  /// Dynamically lists schemes depending on Gov/Corp userType
  Widget _buildSchemeCheckboxes() {
    final bool isGov = _userType == 'government';

    final List<Map<String, String>> schemes = isGov
        ? [
            {'id': AppStrings.schemePMKisan, 'title': AppStrings.schemePMKisan, 'desc': AppStrings.schemePMKisanDesc},
            {'id': AppStrings.schemeScholarships, 'title': AppStrings.schemeScholarships, 'desc': AppStrings.schemeScholarshipsDesc},
            {'id': AppStrings.schemeBankLoans, 'title': AppStrings.schemeBankLoans, 'desc': AppStrings.schemeBankLoansDesc},
            {'id': AppStrings.schemeUjjwala, 'title': AppStrings.schemeUjjwala, 'desc': AppStrings.schemeUjjwalaDesc},
          ]
        : [
            {'id': AppStrings.schemeHiring, 'title': AppStrings.schemeHiring, 'desc': AppStrings.schemeHiringDesc},
            {'id': AppStrings.schemePromotion, 'title': AppStrings.schemePromotion, 'desc': AppStrings.schemePromotionDesc},
            {'id': AppStrings.schemeCredit, 'title': AppStrings.schemeCredit, 'desc': AppStrings.schemeCreditDesc},
          ];

    return Column(
      children: schemes.map((s) {
        final String id = s['id']!;
        final String title = s['title']!;
        final String desc = s['desc']!;
        final bool isChecked = _auditedSchemes.contains(id);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: CheckboxListTile(
            value: isChecked,
            onChanged: (_) => _toggleScheme(id),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.neutralGray)),
            activeColor: isGov ? AppColors.primaryBlue : AppColors.secondaryGreen,
            checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        );
      }).toList(),
    );
  }
}
