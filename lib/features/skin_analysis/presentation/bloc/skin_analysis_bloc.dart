// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/utils/active_user_resolver.dart';
import 'package:kora/features/skin_analysis/domain/entities/scan_record.dart';
import 'package:kora/features/skin_analysis/domain/usecases/analyze_skin_usecase.dart';
import 'package:kora/features/skin_analysis/domain/usecases/preprocess_skin_image_usecase.dart';
import 'package:kora/features/skin_analysis/domain/usecases/save_scan_record_usecase.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_event.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_state.dart';
import 'package:path_provider/path_provider.dart';

/// BLoC orchestrating the 3-phase YouCam HD analysis pipeline:
/// 1. Isolate image optimization (HD dimensions & size constraint)
/// 2. Remote API dispatch & analysis
/// 3. Mask retrieval & skin report compilation
class SkinAnalysisBloc extends Bloc<SkinAnalysisEvent, SkinAnalysisState> {
  /// Creates a [SkinAnalysisBloc].
  SkinAnalysisBloc({
    required PreprocessSkinImageUseCase preprocessUseCase,
    required AnalyzeSkinUseCase analyzeUseCase,
    SaveScanRecordUseCase? saveScanUseCase,
  }) : _preprocessUseCase = preprocessUseCase,
       _analyzeUseCase = analyzeUseCase,
       _saveScanUseCase = saveScanUseCase,
       super(const SkinAnalysisState()) {
    on<StartSkinAnalysisEvent>(_onStartSkinAnalysis);
    on<AnalysisProgressStepEvent>(_onProgressStep);
    on<LongProcessingTimeoutTriggeredEvent>(_onLongProcessingTimeout);
    on<ResetSkinAnalysisEvent>(_onReset);
  }

  final PreprocessSkinImageUseCase _preprocessUseCase;
  final AnalyzeSkinUseCase _analyzeUseCase;
  final SaveScanRecordUseCase? _saveScanUseCase;
  Timer? _longProcessingTimer;

  Future<void> _onStartSkinAnalysis(
    StartSkinAnalysisEvent event,
    Emitter<SkinAnalysisState> emit,
  ) async {
    _longProcessingTimer?.cancel();
    _longProcessingTimer = Timer(const Duration(seconds: 20), () {
      if (!isClosed) {
        add(const LongProcessingTimeoutTriggeredEvent());
      }
    });

    // Step 0: Preprocessing & Optimizing
    emit(
      state.copyWith(
        status: SkinAnalysisStatus.preprocessing,
        currentStepIndex: 0,
        isTakingLonger: false,
      ),
    );

    final preprocessResult = await _preprocessUseCase(
      PreprocessSkinImageParams(inputPath: event.imagePath),
    );

    String? processedImagePath;
    final preprocessFailed = preprocessResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SkinAnalysisStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return true;
      },
      (processedPath) {
        processedImagePath = processedPath;
        emit(
          state.copyWith(
            preprocessedPath: processedPath,
          ),
        );
        return false;
      },
    );

    if (preprocessFailed) {
      _longProcessingTimer?.cancel();
      return;
    }

    // Step 1: Analysing
    emit(
      state.copyWith(
        status: SkinAnalysisStatus.analyzing,
        currentStepIndex: 1,
      ),
    );

    // Simulated step transition to reflect real mask building
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1400)).then((_) {
        if (!isClosed && state.status == SkinAnalysisStatus.analyzing) {
          add(const AnalysisProgressStepEvent(stepIndex: 2));
        }
      }),
    );

    final analysisResult = await _analyzeUseCase(
      AnalyzeSkinParams(
        imagePath: processedImagePath ?? event.imagePath,
        useMockIfOffline: event.useMock,
      ),
    );

    _longProcessingTimer?.cancel();

    await analysisResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: SkinAnalysisStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (result) async {
        final scanId = 'scan_${DateTime.now().millisecondsSinceEpoch}';
        final rawPath = processedImagePath ?? event.imagePath;

        var permanentPhotoPath = rawPath;
        try {
          if (rawPath.isNotEmpty && File(rawPath).existsSync()) {
            final appDir = await getApplicationDocumentsDirectory();
            final scansDir = Directory('${appDir.path}/scans');
            if (!scansDir.existsSync()) {
              scansDir.createSync(recursive: true);
            }
            final destinationPath = '${scansDir.path}/scan_$scanId.jpg';
            File(rawPath).copySync(destinationPath);
            if (File(destinationPath).existsSync()) {
              permanentPhotoPath = destinationPath;
            }
          }
        } on Object catch (e) {
          developer.log('Failed to copy scan photo: $e', name: 'kora.scan');
        }

        final enrichedResult = result.copyWith(
          resizedImageUrl: permanentPhotoPath,
        );

        final saveUseCase = _saveScanUseCase;
        if (saveUseCase != null) {
          final userId = await ActiveUserResolver.resolveUserId();
          final concernRecords = enrichedResult.allConcerns.map((c) {
            return ScanConcernRecord(
              id: 'concern_${scanId}_${c.id}',
              scanId: scanId,
              userId: userId,
              concern: c.id,
              rawScore: c.rawScore,
              uiScore: c.uiScore.toDouble(),
              maskPath: c.maskUrls.isNotEmpty ? c.maskUrls.first : null,
            );
          }).toList();

          final record = ScanRecord(
            id: scanId,
            userId: userId,
            overallScore: enrichedResult.overallScore,
            skinAge: enrichedResult.skinAge,
            photoPath: permanentPhotoPath,
            concerns: concernRecords,
            createdAt: DateTime.now(),
            completedAt: DateTime.now(),
          );

          await saveUseCase(record);
        }

        emit(
          state.copyWith(
            status: SkinAnalysisStatus.success,
            currentStepIndex: 2,
            result: enrichedResult,
          ),
        );
      },
    );
  }

  void _onProgressStep(
    AnalysisProgressStepEvent event,
    Emitter<SkinAnalysisState> emit,
  ) {
    if (state.status == SkinAnalysisStatus.analyzing ||
        state.status == SkinAnalysisStatus.buildingReport) {
      emit(
        state.copyWith(
          status: SkinAnalysisStatus.buildingReport,
          currentStepIndex: event.stepIndex,
        ),
      );
    }
  }

  void _onLongProcessingTimeout(
    LongProcessingTimeoutTriggeredEvent event,
    Emitter<SkinAnalysisState> emit,
  ) {
    if (state.status != SkinAnalysisStatus.success &&
        state.status != SkinAnalysisStatus.failure) {
      emit(state.copyWith(isTakingLonger: true));
    }
  }

  void _onReset(
    ResetSkinAnalysisEvent event,
    Emitter<SkinAnalysisState> emit,
  ) {
    _longProcessingTimer?.cancel();
    emit(const SkinAnalysisState());
  }

  @override
  Future<void> close() {
    _longProcessingTimer?.cancel();
    return super.close();
  }
}
