import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/error_handler.dart';
import 'package:free_base/services/feature_flags.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  RoleSelectionScreenState createState() => RoleSelectionScreenState();
}

class RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;

  Future<void> _setRoleAndContinue(String selectedRole) async {
    if (_isLoading) return; // Doppelklick verhindern

    setState(() {
      _isLoading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      context.goNamed(AppRouteNames.login);
      return;
    }

    final uid = currentUser.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'role': selectedRole}, SetOptions(merge: true));
      if (!mounted) return;
      context.goNamed(AppRouteNames.dashboard);
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(
        context,
        e,
        fallback:
            'Fehler beim Speichern der Rolle. Bitte später erneut versuchen.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final featureFlags = context.watch<FeatureFlags>();
    final buttons = <Widget>[
      _RoleButton(
        label: 'Personal',
        onPressed:
            _isLoading ? null : () => _setRoleAndContinue('personal'),
      ),
      if (featureFlags.parentsTrackEnabled) ...[
        const SizedBox(height: 12),
        _RoleButton(
          label: 'Eltern-Kind',
          onPressed: _isLoading
              ? null
              : () => _setRoleAndContinue('eltern-kind'),
        ),
      ],
      if (featureFlags.trainerTrackEnabled) ...[
        const SizedBox(height: 12),
        _RoleButton(
          label: 'Trainer',
          onPressed:
              _isLoading ? null : () => _setRoleAndContinue('trainer'),
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Rolle auswählen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buttons,
                ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _RoleButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
