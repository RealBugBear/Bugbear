import 'package:flutter/material.dart';

/// Generic placeholder screen that communicates disabled or upcoming
/// functionality. It can be reused for feature-flagged sections so that we
/// don't have to scatter ad-hoc scaffold implementations throughout the app.
class FeaturePlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;

  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
