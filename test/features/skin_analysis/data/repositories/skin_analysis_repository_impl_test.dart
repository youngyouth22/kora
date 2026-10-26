import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/skin_analysis/data/datasources/image_preprocessor_datasource.dart';
import 'package:kora/features/skin_analysis/data/datasources/skin_analysis_remote_datasource.dart';
import 'package:kora/features/skin_analysis/data/models/skin_analysis_result_model.dart';
import 'package:kora/features/skin_analysis/data/repositories/skin_analysis_repository_impl.dart';

class _FakePreprocessor implements ImagePreprocessorDataSource {
  String returnPath = '/out/hd.jpg';
  bool shouldThrowNotFound = false;

  @override
  Future<String> preprocessHdImage(String inputPath) async {
    if (shouldThrowNotFound) {
      throw const FileNotFoundException('Not found');
    }
    return returnPath;
  }
}

class _FakeRemoteDataSource implements SkinAnalysisRemoteDataSource {
  bool shouldThrowServerException = false;

  @override
  Future<SkinAnalysisResultModel> analyzeSkin({
    required String imagePath,
    bool useMock = true,
  }) async {
    if (shouldThrowServerException) {
      throw const ServerException(message: 'Server error', statusCode: 500);
    }
    return const SkinAnalysisResultModel(
      overallScore: 80,
      concerns: [],
    );
  }
}

void main() {
  late _FakePreprocessor preprocessor;
  late _FakeRemoteDataSource remoteDataSource;
  late SkinAnalysisRepositoryImpl repository;

  setUp(() {
    preprocessor = _FakePreprocessor();
    remoteDataSource = _FakeRemoteDataSource();
    repository = SkinAnalysisRepositoryImpl(
      preprocessorDataSource: preprocessor,
      remoteDataSource: remoteDataSource,
    );
  });

  group('preprocessImage', () {
    test('returns Right(path) on success', () async {
      final result = await repository.preprocessImage(inputPath: '/in/img.jpg');
      expect(result, const Right<Failure, String>('/out/hd.jpg'));
    });

    test('returns Left(NotFoundFailure) when file is missing', () async {
      preprocessor.shouldThrowNotFound = true;
      final result = await repository.preprocessImage(inputPath: '/in/img.jpg');
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });

  group('analyzeSkin', () {
    test('returns Right(SkinAnalysisResult) on success', () async {
      final result = await repository.analyzeSkin(imagePath: '/out/hd.jpg');
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (res) => expect(res.overallScore, 80),
      );
    });

    test('returns Left(ServerFailure) on exception', () async {
      remoteDataSource.shouldThrowServerException = true;
      final result = await repository.analyzeSkin(imagePath: '/out/hd.jpg');
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}
