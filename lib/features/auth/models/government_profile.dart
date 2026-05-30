/// Government & Corporate Officer Profile Model
/// Handles parsing and structuring of users for BiasMitra
class GovernmentProfile {
  final String uid;
  final String email;
  final String name;
  final String userType; // 'government' | 'corporate'
  final bool isCompleted;

  // Government Specific Fields
  final String officerId;
  final String ministry;
  final String jurisdiction; // 'National' | 'State-Level' | 'District-Level'
  final String state;

  // Corporate Specific Fields
  final String employeeId;
  final String companyName;
  final String department;
  final String industrySector;

  // Audit configuration
  final List<String> auditedSchemes;

  // Dynamic module/scheme visibility based on user selection
  final List<String>
      selectedSchemes; // For Government Auditors (PM-KISAN, Scholarships, etc.)
  final List<String>
      selectedModules; // For Corporate Auditors (Hiring, Promotion, Credit)

  GovernmentProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    required this.isCompleted,
    this.officerId = '',
    this.ministry = '',
    this.jurisdiction = 'National',
    this.state = '',
    this.employeeId = '',
    this.companyName = '',
    this.department = '',
    this.industrySector = '',
    required this.auditedSchemes,
    this.selectedSchemes = const [],
    this.selectedModules = const [],
  });

  /// Factory constructor to create a profile from Firestore map
  factory GovernmentProfile.fromMap(
      Map<String, dynamic> map, String uid, String email, String fallbackName) {
    return GovernmentProfile(
      uid: uid,
      email: email,
      name: map['name'] ?? fallbackName,
      userType: map['userType'] ?? 'government',
      isCompleted: map['isCompleted'] ?? false,
      officerId: map['officerId'] ?? '',
      ministry: map['ministry'] ?? '',
      jurisdiction: map['jurisdiction'] ?? 'National',
      state: map['state'] ?? '',
      employeeId: map['employeeId'] ?? '',
      companyName: map['companyName'] ?? '',
      department: map['department'] ?? '',
      industrySector: map['industrySector'] ?? '',
      auditedSchemes: List<String>.from(map['auditedSchemes'] ?? []),
      selectedSchemes: List<String>.from(map['selectedSchemes'] ?? []),
      selectedModules: List<String>.from(map['selectedModules'] ?? []),
    );
  }

  /// Create an empty/initial profile for new users
  factory GovernmentProfile.initial(String uid, String email, String name) {
    return GovernmentProfile(
      uid: uid,
      email: email,
      name: name,
      userType: 'government',
      isCompleted: false,
      auditedSchemes: [],
    );
  }

  /// Convert Profile instance to Firestore Map representation
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userType': userType,
      'isCompleted': isCompleted,
      'officerId': officerId,
      'ministry': ministry,
      'jurisdiction': jurisdiction,
      'state': state,
      'employeeId': employeeId,
      'companyName': companyName,
      'department': department,
      'industrySector': industrySector,
      'auditedSchemes': auditedSchemes,
      'selectedSchemes': selectedSchemes,
      'selectedModules': selectedModules,
    };
  }

  /// Helper to get the clearance level dynamically based on designation/role
  String get dynamicClearanceLevel {
    if (userType == 'government') {
      if (ministry.isEmpty) return 'No Clearance';
      // In official systems, designations map directly to clearance levels
      if (jurisdiction == 'National') {
        return 'L3 - National Overseer';
      } else if (jurisdiction == 'State-Level') {
        return 'L2 - Regional Auditor';
      } else {
        return 'L1 - Local Scheme Auditor';
      }
    } else {
      if (companyName.isEmpty) return 'No Clearance';
      if (department.toLowerCase().contains('hr') ||
          department.toLowerCase().contains('hiring')) {
        return 'Enterprise HR Validator';
      }
      return 'Standard Corporate Auditor';
    }
  }

  /// Helper to get organization name dynamically
  String get displayOrganization {
    return userType == 'government' ? ministry : companyName;
  }

  /// Helper to get ID dynamically
  String get displayId {
    return userType == 'government' ? officerId : employeeId;
  }
}
