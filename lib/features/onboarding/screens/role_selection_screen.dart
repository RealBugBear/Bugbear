// File: lib/screens/onboarding/role_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  RoleSelectionScreenState createState() => RoleSelectionScreenState();
}

class RoleSelectionScreenState extends State<RoleSelectionScreen> {
  Future<void> _setRoleAndContinue(String selectedRole) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'role': selectedRole}, SetOptions(merge: true));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rolle auswählen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _setRoleAndContinue('personal'),
              child: const Text('Personal'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _setRoleAndContinue('eltern-kind'),
              child: const Text('Eltern-Kind'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _setRoleAndContinue('trainer'),
              child: const Text('Trainer'),
            ),
          ],
        ),
      ),
    );
  }
}
