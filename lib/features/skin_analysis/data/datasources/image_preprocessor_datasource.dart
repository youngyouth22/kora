// ignore_for_file: document_ignores, one_member_abstracts, lines_longer_than_80_chars

import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;

/// Contract for image preprocessing operations.
abstract class ImagePreprocessorDataSource {
  /// Preprocesses an image from [inputPath] to adhere to YouCam HD requirements:
  /// - Short edge >= 1080px
  /// - Long edge <= 2560px
  /// - File size < 10MB
  /// - Output format: JPEG
  ///
  /// Returns the path of the processed image file.
  Future<String> preprocessHdImage(String inputPath);
}

/// Parameters passed to the background isolate.
class _IsolateParams {
  const _IsolateParams({
    required this.inputPath,
    required this.outputPath,
  });

  final String inputPath;
  final String outputPath;
}

/// Implementation using [package:image] running within an isolate.
class ImagePreprocessorDataSourceImpl implements ImagePreprocessorDataSource {
  /// Creates an [ImagePreprocessorDataSourceImpl].
  const ImagePreprocessorDataSourceImpl();

  @override
  Future<String> preprocessHdImage(String inputPath) async {
    final inputFile = File(inputPath);
    if (!inputFile.existsSync()) {
      throw FileNotFoundException('Input image does not exist: $inputPath');
    }

    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/kora_hd_scan_$timestamp.jpg';

    return Isolate.run(
      () => _resizeAndEncode(
        _IsolateParams(inputPath: inputPath, outputPath: outputPath),
      ),
    );
  }

  static String _resizeAndEncode(_IsolateParams params) {
    final file = File(params.inputPath);
    final bytes = file.readAsBytesSync();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw const FormatException('Unable to decode captured face image.');
    }

    // Determine dimensions
    final width = decoded.width;
    final height = decoded.height;

    final isPortrait = height >= width;
    final shortSide = isPortrait ? width : height;
    final longSide = isPortrait ? height : width;

    // YouCam HD requirements:
    // short edge >= 1080px, long edge <= 2560px
    const minShortEdge = 1080;
    const maxLongEdge = 2560;

    var scale = 1.0;

    if (shortSide < minShortEdge) {
      // Upscale so short edge meets 1080px requirement
      scale = minShortEdge / shortSide;
    }

    // If scaled long edge exceeds 2560px, cap it
    if ((longSide * scale) > maxLongEdge) {
      scale = maxLongEdge / longSide;
    }

    var processed = decoded;
    if ((scale - 1).abs() > 0.01) {
      final targetWidth = (width * scale).round();
      final targetHeight = (height * scale).round();
      processed = img.copyResize(
        decoded,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    // Encode to JPEG with quality 90 (well below 10MB limit)
    final encodedJpg = img.encodeJpg(processed, quality: 90);

    File(params.outputPath).writeAsBytesSync(encodedJpg);

    return params.outputPath;
  }
}

/// Thrown when input file is not found.
class FileNotFoundException implements Exception {
  /// Creates [FileNotFoundException].
  const FileNotFoundException(this.message);

  /// Message describing the missing file.
  final String message;

  @override
  String toString() => 'FileNotFoundException: $message';
}
