// ignore_for_file: document_ignores, prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/skin_analysis/data/datasources/image_preprocessor_datasource.dart';
import 'package:kora/features/skin_analysis/data/datasources/skin_analysis_remote_datasource.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

/// Implementation of [SkinAnalysisRepository].
class SkinAnalysisRepositoryImpl implements SkinAnalysisRepository {
  /// Creates a [SkinAnalysisRepositoryImpl].
  SkinAnalysisRepositoryImpl({
    required ImagePreprocessorDataSource preprocessorDataSource,
    required SkinAnalysisRemoteDataSource remoteDataSource,
  }) : _preprocessorDataSource = preprocessorDataSource,
       _remoteDataSource = remoteDataSource;

  final ImagePreprocessorDataSource _preprocessorDataSource;
  final SkinAnalysisRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, String>> preprocessImage({
    required String inputPath,
  }) async {
    try {
      final processedPath = await _preprocessorDataSource.preprocessHdImage(
        inputPath,
      );
      return Right(processedPath);
    } on FileNotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on FormatException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on Object catch (e) {
      return Left(ScanFailure(message: 'Failed to preprocess HD image: $e'));
    }
  }

  @override
  Future<Either<Failure, SkinAnalysisResult>> analyzeSkin({
    required String imagePath,
    bool useMockIfOffline = true,
  }) async {
    try {
      final model = await _remoteDataSource.analyzeSkin(
        imagePath: imagePath,
        useMock: useMockIfOffline,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on Object catch (e) {
      return Left(ScanFailure(message: 'Skin analysis failed: $e'));
    }
  }
}
