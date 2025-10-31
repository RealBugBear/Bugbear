import 'package:flutter/services.dart';

import 'moro_models.dart';

class MoroMediaLoadResult {
  final String? videoAsset;
  final String? imageAsset;
  final String? transcript;
  final bool hasError;
  final String? errorMessage;

  const MoroMediaLoadResult({
    this.videoAsset,
    this.imageAsset,
    this.transcript,
    this.hasError = false,
    this.errorMessage,
  });

  bool get hasVideo => videoAsset != null;
  bool get hasImage => imageAsset != null;
  bool get hasTranscript => transcript != null && transcript!.isNotEmpty;
}

class MoroMediaPlayerService {
  Future<MoroMediaLoadResult> loadForExercise(MoroExercise exercise) async {
    String? videoAsset;
    String? imageAsset = exercise.media.image ?? exercise.mediaFallbackImage;
    String? transcript;
    String? errorMessage;

    final videoPath = exercise.media.video;
    if (videoPath != null) {
      try {
        await rootBundle.load(videoPath);
        videoAsset = videoPath;
      } catch (err) {
        errorMessage = err.toString();
      }
    }

    final fallbackImage = exercise.mediaFallbackImage;
    if (imageAsset != null) {
      try {
        await rootBundle.load(imageAsset);
      } catch (err) {
        errorMessage ??= err.toString();
        imageAsset = null;
      }
    }
    if (imageAsset == null && fallbackImage != null) {
      try {
        await rootBundle.load(fallbackImage);
        imageAsset = fallbackImage;
      } catch (err) {
        errorMessage ??= err.toString();
      }
    }

    final transcriptAsset = 'assets/moro/transcripts/moro_${exercise.index}.txt';
    try {
      transcript = await rootBundle.loadString(transcriptAsset);
    } catch (_) {
      transcript = null;
    }

    return MoroMediaLoadResult(
      videoAsset: videoAsset,
      imageAsset: imageAsset,
      transcript: transcript,
      hasError: errorMessage != null && videoAsset == null,
      errorMessage: errorMessage,
    );
  }
}
