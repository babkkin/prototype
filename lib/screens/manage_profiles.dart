import 'package:flutter/material.dart';

class ManageProfilesScreen extends StatelessWidget {
  const ManageProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profiles'),
      ),
      body: const Center(
        child: Text('Manage Profiles Content'),
      ),
    );
  }
}
