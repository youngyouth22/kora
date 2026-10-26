import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';
import 'package:kora/features/skin_analysis/domain/usecases/analyze_skin_usecase.dart';

class _FakeSkinAnalysisRepository implements SkinAnalysisRepository {
  Either<Failure, SkinAnalysisResult> analyzeResult = const Right(
    SkinAnalysisResult(overallScore: 82, allConcerns: []),
  );

  @override
  Future<Either<Failure, String>> preprocessImage({
    required String inputPath,
  }) async {
    throw UnimplementedError();
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
  late AnalyzeSkinUseCase useCase;

  setUp(() {
    repository = _FakeSkinAnalysisRepository();
    useCase = AnalyzeSkinUseCase(repository);
  });

  test('delegates to repository and returns SkinAnalysisResult', () async {
    final result = await useCase(
      const AnalyzeSkinParams(imagePath: '/tmp/scan.jpg'),
    );

    expect(
      result,
      const Right<Failure, SkinAnalysisResult>(
        SkinAnalysisResult(overallScore: 82, allConcerns: []),
      ),
    );
  });

  test('returns failure when analysis repository fails', () async {
    repository.analyzeResult = const Left(
      ServerFailure(message: 'Service unavailable'),
    );

    final result = await useCase(
      const AnalyzeSkinParams(imagePath: '/tmp/scan.jpg'),
    );

    expect(
      result,
      const Left<Failure, SkinAnalysisResult>(
        ServerFailure(message: 'Service unavailable'),
      ),
    );
  });
}
