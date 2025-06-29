import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../services/exercise_repository.dart';

class TrainingHelpScreen extends StatefulWidget {
  final String phaseId;
  const TrainingHelpScreen({super.key, required this.phaseId});

  @override
  State<TrainingHelpScreen> createState() => _TrainingHelpScreenState();
}

class _TrainingHelpScreenState extends State<TrainingHelpScreen> {
  VideoPlayerController? _controller;

  Future<void> _playVideo() async {
    await _controller?.dispose();
    _controller = VideoPlayerController.asset('assets/videos/test video.mp4');
    await _controller!.initialize();
    setState(() {});
    await _controller!.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ExerciseRepository>();
    final exercises = repo.getExercisesForPhase(widget.phaseId);

    return Scaffold(
      appBar: AppBar(title: Text('Phase ${widget.phaseId} Hilfe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(exercises.length, (i) {
                final num = i + 1;
                return ElevatedButton(
                  key: Key('help_btn_$num'),
                  onPressed: _playVideo,
                  child: Text('$num'),
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
          ],
        ),
      ),
    );
  }
}
