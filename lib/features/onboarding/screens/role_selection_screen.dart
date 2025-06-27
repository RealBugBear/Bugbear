import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final uid = currentUser.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'role': selectedRole}, SetOptions(merge: true));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Speichern der Rolle. Bitte später erneut versuchen.'),
          backgroundColor: Colors.red,
        ),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Rolle auswählen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
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
      ),
    );
  }
}
