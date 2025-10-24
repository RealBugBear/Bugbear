import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:free_base/widgets/info_card.dart';

import '../services/exercise_repository.dart';

class TrainingHelpScreen extends StatefulWidget {
  final String phaseId;
  const TrainingHelpScreen({super.key, required this.phaseId});

  @override
  State<TrainingHelpScreen> createState() => _TrainingHelpScreenState();
}

class _TrainingHelpScreenState extends State<TrainingHelpScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = false;
  String? _error;

  /// Mapping 'phase-exercise' → asset path
  final Map<String, String> _videoPaths = {
    '2a-1': 'assets/videos/test_video.mp4',
  };

  Future<void> _playVideo(String key) async {
    final path = _videoPaths[key];
    if (path == null) return;
    await _controller?.dispose();
    setState(() {
      _isLoading = true;
      _error = null;
      _controller = VideoPlayerController.asset(path);
    });
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      await _controller!.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Video konnte nicht geladen werden: $e';
      });
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCard(
              title: 'Übungsübersicht für Phase ${widget.phaseId}',
              description:
                  'Tippe auf eine Übung, um das passende Demonstrationsvideo zu starten. Die Clips helfen dir bei Technik, Rhythmus und Tempo.',
              icon: Icons.ondemand_video_outlined,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(exercises.length, (i) {
                final num = i + 1;
                return ElevatedButton(
                  key: Key('help_btn_$num'),
                  onPressed: () =>
                      _playVideo('${widget.phaseId}-$num'),
                  child: Text('Übung $num'),
                );
              }),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_error != null) {
                    return Center(
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.error,
                            ),
                      ),
                    );
                  }
                  if (_controller != null &&
                      _controller!.value.isInitialized) {
                    return AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    );
                  }
                  return Center(
                    child: Text(
                      'Wähle eine Übung, um das Video zu starten.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
