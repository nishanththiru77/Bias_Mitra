/// BiasMitra Upload CSV Screen
/// User lands here after tapping a scheme card on the Dashboard
/// Features: Scheme header, dashed upload zone, file picker, Scan button

import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../scan/screens/scan_results_screen.dart';

class UploadScreen extends StatefulWidget {
  /// Name of the selected scheme (e.g. "PM-KISAN")
  final String schemeName;

  /// Short description of the scheme
  final String schemeDescription;

  /// Icon representing the scheme
  final IconData schemeIcon;

  /// Color index (0-3) used on the dashboard card - keeps brand consistency
  final int schemeIndex;

  const UploadScreen({
    Key? key,
    required this.schemeName,
    required this.schemeDescription,
    required this.schemeIcon,
    required this.schemeIndex,
  }) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  // Holds the file the user picked
  PlatformFile? _pickedFile;

  // Whether we are currently waiting for the file picker
  bool _isPicking = false;

  // Subtle animation for the upload zone
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Gentle breathing animation on the upload area
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Returns the accent color matching the scheme card on dashboard ─────────
  Color _schemeAccentColor() {
    switch (widget.schemeIndex % 4) {
      case 0:
        return AppColors.primaryBlue;
      case 1:
        return AppColors.secondaryGreen;
      case 2:
        return AppColors.accentSaffron;
      case 3:
      default:
        return const Color(0xFF7C3AED); // Purple
    }
  }

  // ─── Opens the system file picker restricted to CSV only ─────────────────────
  Future<void> _pickCSVFile() async {
    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Load bytes into memory (needed for web)
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _pickedFile = result.files.first);
      }
    } catch (e) {
      // Show a friendly error if something goes wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  // ─── Clears the selected file so user can pick again ─────────────────────────
  void _clearFile() => setState(() => _pickedFile = null);

  // ─── Navigate to Scan & Results screen ──────────────────────────────────────
  void _startScan() {
    if (_pickedFile == null || _pickedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid CSV file first.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultsScreen(
          schemeName: widget.schemeName,
          schemeIcon: widget.schemeIcon,
          schemeIndex: widget.schemeIndex,
          fileName: _pickedFile!.name,
          fileBytes: _pickedFile!.bytes,
        ),
      ),
    );
  }

  // ─── Format bytes into human-readable size ────────────────────────────────────
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _schemeAccentColor();

    return Scaffold(
      backgroundColor: AppColors.neutralGrayLighter,
      appBar: _buildAppBar(accentColor),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Scheme header with icon and name ─────────────────────────────
              _buildSchemeHeader(accentColor),

              const SizedBox(height: AppConfig.defaultPadding * 1.5),

              // ── Upload instructions label ─────────────────────────────────────
              Text(
                'Upload Dataset',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload a CSV file with beneficiary data to scan for bias.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutralGray,
                ),
              ),

              const SizedBox(height: AppConfig.defaultPadding * 1.5),

              // ── Big dashed upload zone OR file info card after picking ────────
              _pickedFile == null
                  ? _buildUploadZone(accentColor)
                  : _buildFileInfoCard(accentColor),

              const SizedBox(height: AppConfig.defaultPadding * 2),

              // ── Privacy note ─────────────────────────────────────────────────
              _buildPrivacyNote(),

              const SizedBox(height: AppConfig.defaultPadding * 2),

              // ── Scan for Bias button (only visible after file is picked) ──────
              if (_pickedFile != null) _buildScanButton(accentColor),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────
  AppBar _buildAppBar(Color accentColor) {
    return AppBar(
      backgroundColor: accentColor,
      foregroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
      title: Text(
        widget.schemeName,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    );
  }

  // ─── Scheme summary card at the top ──────────────────────────────────────────
  Widget _buildSchemeHeader(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding * 1.25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Scheme icon in a white circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
            child: Icon(widget.schemeIcon, color: AppColors.white, size: 30),
          ),

          const SizedBox(width: AppConfig.defaultPadding),

          // Scheme name & description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.schemeName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.schemeDescription,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Audit tag badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Bias Audit',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dashed border upload area ────────────────────────────────────────────────
  Widget _buildUploadZone(Color accentColor) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: _isPicking ? null : _pickCSVFile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
            border: Border.all(
              color: accentColor.withOpacity(0.5),
              width: 2,
              // Flutter doesn't support dashed borders natively;
              // CustomPainter would add complexity — border + icon communicates clearly
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cloud upload icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 42,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Tap to upload CSV file',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Only .csv files supported · Max 10 MB',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.neutralGray,
                ),
              ),

              const SizedBox(height: 24),

              // Choose file button
              ElevatedButton.icon(
                onPressed: _isPicking ? null : _pickCSVFile,
                icon: _isPicking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.folder_open_outlined),
                label: Text(_isPicking ? 'Opening...' : 'Choose CSV File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConfig.defaultBorderRadius,
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Card shown once a file is selected ───────────────────────────────────────
  Widget _buildFileInfoCard(Color accentColor) {
    final file = _pickedFile!;
    final sizeText = _formatFileSize(file.size);

    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        border: Border.all(color: AppColors.secondaryGreen.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreen.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Success check + file name row
          Row(
            children: [
              // Green check icon
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryGreenLighter,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.secondaryGreen,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              // File metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primaryBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CSV · $sizeText',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralGray,
                      ),
                    ),
                  ],
                ),
              ),

              // Remove / change file button
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.error),
                tooltip: 'Remove file',
                onPressed: _clearFile,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Change file link
          TextButton.icon(
            onPressed: _pickCSVFile,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: const Text('Choose a different file'),
            style: TextButton.styleFrom(foregroundColor: accentColor),
          ),
        ],
      ),
    );
  }

  // ─── Privacy / data note ──────────────────────────────────────────────────────
  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLighter,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your data is processed temporarily only. '
              'No raw data is stored permanently.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryBlue.withOpacity(0.85),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Scan for Bias CTA button ─────────────────────────────────────────────────
  Widget _buildScanButton(Color accentColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startScan,
        icon: const Icon(Icons.search),
        label: const Text('Scan for Bias'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          elevation: 4,
          shadowColor: AppColors.primaryBlue.withOpacity(0.4),
        ),
      ),
    );
  }
}
