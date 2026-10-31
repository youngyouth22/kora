// ignore_for_file: document_ignores

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/user_profile_repository.dart';
import 'package:kora/features/skin_analysis/data/datasources/skin_analysis_remote_datasource.dart';
import 'package:kora/features/skin_analysis/data/models/skin_analysis_result_model.dart';
import 'package:kora/features/skin_analysis/data/models/skin_report_request_model.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_concern.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_type_info.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/skin_scan_result_bottom_sheet.dart';

/// Full screen view presenting the first-scan or weekly-scan skin analysis
/// result and AI report (`POST /api/skin-report`).
class ScanResultPage extends StatefulWidget {
  /// Creates a [ScanResultPage].
  const ScanResultPage({this.result, super.key});

  /// The skin analysis result entity.
  final SkinAnalysisResult? result;

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  late SkinAnalysisResult _currentResult;

  @override
  void initState() {
    super.initState();
    _currentResult = widget.result ?? _fallbackResult;
    if (_currentResult.report == null &&
        _currentResult.allConcerns.isNotEmpty) {
      unawaited(_enrichWithAiSkinReport());
    }
  }

  Future<void> _enrichWithAiSkinReport() async {
    final modelFromEntity = _toResultModel(_currentResult);
    final getIt = GetIt.instance;
    SkinAnalysisRemoteDataSourceImpl? remoteDataSource;

    if (getIt.isRegistered<SkinAnalysisRemoteDataSource>()) {
      final ds = getIt<SkinAnalysisRemoteDataSource>();
      if (ds is SkinAnalysisRemoteDataSourceImpl) {
        remoteDataSource = ds;
      }
    }

    if (remoteDataSource == null && getIt.isRegistered<KoraAiApiClient>()) {
      remoteDataSource = SkinAnalysisRemoteDataSourceImpl(
        aiApiClient: getIt<KoraAiApiClient>(),
      );
    }

    if (remoteDataSource != null) {
      try {
        UserSkinProfile? profile;
        if (getIt.isRegistered<UserProfileRepository>()) {
          final res = await getIt<UserProfileRepository>().getProfile(
            id: 'local-user',
          );
          profile = res.fold((_) => null, (p) => p);
        }

        final request = SkinReportRequestModel.fromAnalysis(
          analysis: modelFromEntity,
          userProfile: profile,
        );
        final reportModel = await remoteDataSource.generateSkinReport(
          request: request,
        );
        if (mounted) {
          setState(() {
            _currentResult = modelFromEntity
                .copyWithReport(reportModel)
                .toEntity();
          });
          return;
        }
      } on Object {
        // Fall through to deterministic fallback synthesis below.
      }
    }

    if (mounted) {
      setState(() {
        _currentResult = modelFromEntity.toEntity();
      });
    }
  }

  SkinAnalysisResultModel _toResultModel(SkinAnalysisResult entity) {
    return SkinAnalysisResultModel.fromJson({
      'results': {
        'output': [
          {'type': 'all', 'score': entity.overallScore},
          if (entity.skinAge != null)
            {'type': 'skin_age', 'score': entity.skinAge},
          if (entity.skinType != null) ...[
            {
              'type': 'skin_type',
              'region': 'whole',
              'skin_type': entity.skinType!.overallType,
            },
            if (entity.skinType!.tZoneType != null)
              {
                'type': 'skin_type',
                'region': 't_zone',
                'skin_type': entity.skinType!.tZoneType,
              },
            if (entity.skinType!.uZoneType != null)
              {
                'type': 'skin_type',
                'region': 'u_zone',
                'skin_type': entity.skinType!.uZoneType,
              },
          ],
          for (final concern in entity.allConcerns)
            {
              'type': concern.id,
              'ui_score': concern.uiScore,
              'raw_score': concern.rawScore,
              'mask_urls': concern.maskUrls,
            },
        ],
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppGreyColors.white,
      appBar: AppBar(
        backgroundColor: AppGreyColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppGreyColors.shade1050,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SkinScanResultBottomSheet(
        result: _currentResult,
        isStandalonePage: true,
        onSaveToRoutine: () {
          context.go(AppRoutes.home);
        },
      ),
    );
  }

  static const SkinAnalysisResult _fallbackResult = SkinAnalysisResult(
    overallScore: 74.2,
    skinAge: 26,
    skinType: SkinTypeInfo(
      overallType: 'Combination',
      tZoneType: 'Oily',
      uZoneType: 'Normal',
    ),
    allConcerns: [
      SkinConcern(
        id: 'pore',
        displayName: 'Pores',
        uiScore: 78,
        rawScore: 78.4,
      ),
      SkinConcern(
        id: 'redness',
        displayName: 'Redness & Sensitivity',
        uiScore: 81,
        rawScore: 81.5,
      ),
      SkinConcern(
        id: 'texture',
        displayName: 'Skin Texture & Smoothness',
        uiScore: 74,
        rawScore: 74,
      ),
      SkinConcern(
        id: 'wrinkle',
        displayName: 'Fine Lines & Wrinkles',
        uiScore: 72,
        rawScore: 72.1,
      ),
      SkinConcern(
        id: 'acne',
        displayName: 'Blemishes & Breakouts',
        uiScore: 86,
        rawScore: 86,
      ),
      SkinConcern(
        id: 'age_spot',
        displayName: 'Dark Spots & Hyperpigmentation',
        uiScore: 72,
        rawScore: 74.2,
      ),
      SkinConcern(
        id: 'moisture',
        displayName: 'Hydration & Moisture',
        uiScore: 68,
        rawScore: 68.2,
      ),
      SkinConcern(
        id: 'firmness',
        displayName: 'Elasticity & Firmness',
        uiScore: 84,
        rawScore: 86.6,
      ),
      SkinConcern(
        id: 'radiance',
        displayName: 'Radiance & Luminosity',
        uiScore: 77,
        rawScore: 72,
      ),
      SkinConcern(
        id: 'oiliness',
        displayName: 'Sebum & Oiliness',
        uiScore: 65,
        rawScore: 44.7,
      ),
      SkinConcern(
        id: 'dark_circle',
        displayName: 'Dark Circles',
        uiScore: 79,
        rawScore: 75.8,
      ),
      SkinConcern(
        id: 'eye_bag',
        displayName: 'Eye Bags',
        uiScore: 58,
        rawScore: 27.3,
      ),
      SkinConcern(
        id: 'tear_trough',
        displayName: 'Tear Trough Grooves',
        uiScore: 70,
        rawScore: 56.1,
      ),
      SkinConcern(
        id: 'droopy_upper_eyelid',
        displayName: 'Upper Eyelid Firmness',
        uiScore: 81,
        rawScore: 80.8,
      ),
      SkinConcern(
        id: 'droopy_lower_eyelid',
        displayName: 'Lower Eyelid Elasticity',
        uiScore: 63,
        rawScore: 39.8,
      ),
      SkinConcern(
        id: 'skin_type',
        displayName: 'Skin Type Multi-Zone',
        uiScore: 82,
        rawScore: 82,
      ),
    ],
  );
}
