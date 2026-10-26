import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';
import 'package:kora/features/skin_analysis/domain/usecases/analyze_skin_usecase.dart';
import 'package:kora/features/skin_analysis/domain/usecases/preprocess_skin_image_usecase.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_event.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_state.dart';

class _FakeSkinAnalysisRepository implements SkinAnalysisRepository {
  Either<Failure, String> preprocessResult = const Right('/temp/hd_scan.jpg');
  Either<Failure, SkinAnalysisResult> analyzeResult = const Right(
    SkinAnalysisResult(
      overallScore: 78,
      allConcerns: [],
    ),
  );

  @override
  Future<Either<Failure, String>> preprocessImage({
    required String inputPath,
  }) async {
    return preprocessResult;
  }

  @override
  Future<Either<Failure, SkinAnalysisResult>> analyzeSkin({
    required String imagePath,
    bool useMockIfOffline = true,
  }) async {
    return analyzeResult;
  }
}

void main() {
  late _FakeSkinAnalysisRepository repository;
  late PreprocessSkinImageUseCase preprocessUseCase;
  late AnalyzeSkinUseCase analyzeUseCase;
  late SkinAnalysisBloc bloc;

  setUp(() {
    repository = _FakeSkinAnalysisRepository();
    preprocessUseCase = PreprocessSkinImageUseCase(repository);
    analyzeUseCase = AnalyzeSkinUseCase(repository);
    bloc = SkinAnalysisBloc(
      preprocessUseCase: preprocessUseCase,
      analyzeUseCase: analyzeUseCase,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state has default values', () {
    expect(bloc.state, const SkinAnalysisState());
    expect(bloc.state.status, SkinAnalysisStatus.initial);
    expect(bloc.state.currentStepIndex, 0);
  });

  test('emits preprocessing, analyzing, and success on happy path', () async {
    final expectedStates = <SkinAnalysisStatus>[];
    final subscription = bloc.stream.listen((state) {
      expectedStates.add(state.status);
    });

    bloc.add(const StartSkinAnalysisEvent(imagePath: '/orig/image.jpg'));

    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(expectedStates.contains(SkinAnalysisStatus.preprocessing), isTrue);
    expect(expectedStates.contains(SkinAnalysisStatus.analyzing), isTrue);
    expect(expectedStates.contains(SkinAnalysisStatus.success), isTrue);
    expect(bloc.state.result?.overallScore, 78);

    await subscription.cancel();
  });

  test('emits failure when preprocessing fails', () async {
    repository.preprocessResult = const Left(
      ScanFailure(message: 'Invalid dimensions'),
    );

    bloc.add(const StartSkinAnalysisEvent(imagePath: '/orig/bad.jpg'));

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.status, SkinAnalysisStatus.failure);
    expect(bloc.state.errorMessage, 'Invalid dimensions');
  });

  test('handles long timeout trigger', () async {
    bloc.add(const LongProcessingTimeoutTriggeredEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.isTakingLonger, isTrue);
  });
}
