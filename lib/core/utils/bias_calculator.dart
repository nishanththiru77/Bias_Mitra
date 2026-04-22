// lib/core/utils/bias_calculator.dart
// Pure real calculation - Fixed Max Gap display

class BiasCalculator {
  static Map<String, dynamic> calculate(List<List<dynamic>> rows) {
    if (rows.isEmpty || rows.length < 2) {
      return _emptyResult("No sufficient data");
    }

    final headers = rows.first.map((e) => e.toString().toLowerCase().trim()).toList();

    int approvedIdx = headers.indexWhere((h) =>
        h == 'approved' || h.contains('loan_approved') || h == 'decision' || 
        h == 'outcome' || h == 'status' || h.contains('approval'));

    if (approvedIdx == -1) {
      return _emptyResult("Missing Approved column");
    }

    int genderIdx = headers.indexWhere((h) => h == 'gender');
    int locationIdx = headers.indexWhere((h) => h == 'location');
    int casteIdx = headers.indexWhere((h) => h == 'caste');

    bool isIntersectional = genderIdx != -1 && locationIdx != -1 && casteIdx != -1;

    int groupIdx = headers.indexWhere((h) =>
        h == 'category' || h == 'group' || h == 'caste' || 
        h.contains('demographic') || h.contains('sensitive'));

    if (!isIntersectional && groupIdx == -1) {
      return _emptyResult("Missing Group column");
    }

    Map<String, int> groupTotal = {};
    Map<String, int> groupApproved = {};
    int totalApplicants = 0;
    int totalApproved = 0;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= approvedIdx) continue;

      String group = "Unknown";
      
      if (isIntersectional) {
        String caste = row[casteIdx].toString().trim().toUpperCase();
        if (caste == 'SC' || caste == 'ST') {
          group = 'SC/ST';
        } else {
          String loc = row[locationIdx].toString().trim();
          String gen = row[genderIdx].toString().trim();
          group = '$loc $gen';
        }
      } else {
        group = row[groupIdx].toString().trim();
        if (group.isEmpty) group = "Unknown";
      }

      String approvedStr = row[approvedIdx].toString().trim().toLowerCase();
      bool isApproved = approvedStr == '1' || approvedStr == 'yes' || 
                        approvedStr == 'true' || approvedStr == 'approved';

      totalApplicants++;
      if (isApproved) totalApproved++;

      groupTotal[group] = (groupTotal[group] ?? 0) + 1;
      groupApproved[group] = (groupApproved[group] ?? 0) + (isApproved ? 1 : 0);
    }

    if (totalApplicants == 0 || groupTotal.length < 2) {
      return _emptyResult("Not enough groups found");
    }

    Map<String, double> groupApprovals = {};
    double maxRate = 0.0;
    double minRate = 1.0;

    groupTotal.forEach((group, total) {
      if (total > 0) {
        double rate = groupApproved[group]! / total;
        groupApprovals[group] = (rate * 100).roundToDouble(); // store as %
        if (rate > maxRate) maxRate = rate;
        if (rate < minRate) minRate = rate;
      }
    });

    double maxGapPercent = ((maxRate - minRate) * 100).roundToDouble();

    int fairnessScore = (100 - maxGapPercent).round().clamp(0, 100);

    String biasLevel = fairnessScore >= 75
        ? "Low Bias"
        : fairnessScore >= 55
            ? "Medium Bias"
            : "High Bias";

    return {
      'fairnessScore': fairnessScore,
      'maxGap': maxGapPercent.round(),        
      'groupApprovals': groupApprovals,
      'biasLevel': biasLevel,
      'number_of_groups': groupTotal.length,
      'overall_approval_rate': (totalApproved / totalApplicants * 100).roundToDouble(),
    };
  }

  static Map<String, dynamic> _emptyResult(String reason) {
    print("BiasCalculator Error: $reason");
    return {
      'fairnessScore': 0,
      'maxGap': 0,
      'groupApprovals': <String, double>{},
      'biasLevel': reason,
      'number_of_groups': 0,
    };
  }
}