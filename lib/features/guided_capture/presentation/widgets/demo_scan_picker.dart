// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/image_resources.dart';
import 'package:path_provider/path_provider.dart';

/// HACKATHON DEMO FLAG
///
/// Toggle to `false` or delete this widget and its invocation in
/// `GuidedCapturePage` to completely remove the demo picker.
const bool kEnableDemoScanPicker = true;

/// Represents an available demo face scan option.
class DemoScanItem {
  /// Creates a [DemoScanItem].
  const DemoScanItem({
    required this.id,
    required this.label,
    required this.weekNumber,
    required this.assetPath,
    required this.description,
  });

  /// Identifier.
  final String id;

  /// Display label (e.g. 'Semaine 1').
  final String label;

  /// Week number.
  final int weekNumber;

  /// Asset image path.
  final String assetPath;

  /// Short description.
  final String description;
}

/// Floating bottom-left demo selector allowing instant selection and capture
/// of preset face scans (Week 1, Week 3, Week 6) for demo video recordings
/// without having to scan one's own face.
class DemoScanPicker extends StatefulWidget {
  /// Creates a [DemoScanPicker].
  const DemoScanPicker({
    required this.onCaptureDemoPhoto,
    super.key,
  });

  /// Callback delivering the converted [XFile] for high-resolution analysis.
  final Future<void> Function(XFile photo) onCaptureDemoPhoto;

  /// Available preset scans.
  static const List<DemoScanItem> presets = [
    DemoScanItem(
      id: 'week1',
      label: 'Semaine 1',
      weekNumber: 1,
      assetPath: ImageResources.onboardingScanWeek1,
      description: 'Point de départ',
    ),
    DemoScanItem(
      id: 'week3',
      label: 'Semaine 3',
      weekNumber: 3,
      assetPath: ImageResources.onboardingScanWeek3,
      description: 'Mi-parcours',
    ),
    DemoScanItem(
      id: 'week6',
      label: 'Semaine 6',
      weekNumber: 6,
      assetPath: ImageResources.onboardingScanWeek6,
      description: 'Bilan final',
    ),
  ];

  @override
  State<DemoScanPicker> createState() => _DemoScanPickerState();
}

class _DemoScanPickerState extends State<DemoScanPicker> {
  int _selectedIndex = 0;
  bool _isProcessing = false;
  bool _isExpanded = false;

  DemoScanItem get _selectedItem => DemoScanPicker.presets[_selectedIndex];

  Future<void> _executeDemoCapture(DemoScanItem item) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await HapticFeedback.mediumImpact();

      // Load asset bytes and cache to temporary file for XFile compatibility
      final byteData = await rootBundle.load(item.assetPath);
      final tempDir = await getTemporaryDirectory();
      final fileName = 'demo_${item.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
        flush: true,
      );

      final xFile = XFile(file.path);
      await widget.onCaptureDemoPhoto(xFile);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isExpanded = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kEnableDemoScanPicker) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isExpanded) ...[
          _buildExpandedSheet(context),
          const SizedBox(height: 10),
        ],
        _buildTriggerButton(context),
      ],
    );
  }

  /// Compact floating button positioned bottom-left.
  Widget _buildTriggerButton(BuildContext context) {
    return Semantics(
      label: 'Mode Démo Vidéo: ${_selectedItem.label}. Appuyer pour ouvrir le sélecteur.',
      button: true,
      child: GestureDetector(
        onTap: () {
          if (_isProcessing) return;
          setState(() => _isExpanded = !_isExpanded);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppGreyColors.shade1050.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppPrimaryColors.shade500.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppGreyColors.shade1050.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small thumbnail of currently selected scan
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(
                    _selectedItem.assetPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppPrimaryColors.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DÉMO',
                          style: AppTypography.bodyXsBold.copyWith(
                            color: AppGreyColors.white,
                            fontSize: 9,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'S${_selectedItem.weekNumber}',
                        style: AppTypography.bodyMBold.copyWith(
                          color: AppGreyColors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Toucher pour changer',
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppGreyColors.shade500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: AppGreyColors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Expanded selection sheet showing Week 1, Week 3, and Week 6 preset options.
  Widget _buildExpandedSheet(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppGreyColors.shade1050.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppGreyColors.shade800,
        ),
        boxShadow: [
          BoxShadow(
            color: AppGreyColors.shade1050.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Visage Démo (Vidéo)',
                style: AppTypography.bodyMBold.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = false),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    color: AppGreyColors.shade500,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Sélectionnez une photo pour lancer le scan sans votre caméra :',
            style: AppTypography.bodyXsRegular.copyWith(
              color: AppGreyColors.shade400,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(DemoScanPicker.presets.length, (index) {
            final item = DemoScanPicker.presets[index];
            final isCurrent = index == _selectedIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(
                button: true,
                label: 'Sélectionner et scanner ${item.label} (${item.description})',
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    unawaited(_executeDemoCapture(item));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppPrimaryColors.shade900.withValues(alpha: 0.4)
                          : AppGreyColors.shade1000,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? AppPrimaryColors.shade500
                            : AppGreyColors.shade800,
                        width: isCurrent ? 1.4 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: Image.asset(
                              item.assetPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: AppTypography.bodySBold.copyWith(
                                  color: AppGreyColors.white,
                                ),
                              ),
                              Text(
                                item.description,
                                style: AppTypography.bodyXsRegular.copyWith(
                                  color: isCurrent
                                      ? AppPrimaryColors.shade300
                                      : AppGreyColors.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isProcessing && isCurrent)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppPrimaryColors.shade500,
                            ),
                          )
                        else
                          Icon(
                            isCurrent
                                ? Icons.arrow_forward_rounded
                                : Icons.play_arrow_outlined,
                            color: isCurrent
                                ? AppPrimaryColors.shade500
                                : AppGreyColors.shade500,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
