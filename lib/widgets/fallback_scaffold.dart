import 'package:flutter/material.dart';

import 'package:free_base/widgets/connectivity_banner.dart';

/// Reusable scaffold that combines a connectivity banner and a fallback
/// message area with optional retry/action buttons.
class FallbackScaffold extends StatelessWidget {
  final String title;
  final String headline;
  final String message;
  final Widget? child;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final IconData icon;

  const FallbackScaffold({
    super.key,
    required this.title,
    required this.headline,
    required this.message,
    this.child,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = <Widget>[
      Icon(icon, size: 48, color: theme.colorScheme.primary),
      const SizedBox(height: 16),
      Text(
        headline,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        message,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    ];

    if (child != null) {
      content
        ..add(const SizedBox(height: 16))
        ..add(child!);
    }

    final actions = <Widget>[];
    if (primaryActionLabel != null && onPrimaryAction != null) {
      actions.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPrimaryAction,
            child: Text(primaryActionLabel!),
          ),
        ),
      );
    }
    if (secondaryActionLabel != null && onSecondaryAction != null) {
      actions
        ..add(const SizedBox(height: 8))
        ..add(
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSecondaryAction,
              child: Text(secondaryActionLabel!),
            ),
          ),
        );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...content,
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      ...actions,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
