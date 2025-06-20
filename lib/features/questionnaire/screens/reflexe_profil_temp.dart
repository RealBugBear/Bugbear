import 'package:flutter/material.dart';

class ReflexeProfilTemp extends StatelessWidget {
  const ReflexeProfilTemp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflexe Profil')),
      body: const Center(
        child: Text('Profil (temporär)'),
      ),
    );
  }
}
