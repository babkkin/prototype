import 'package:flutter/material.dart';
import '../models/profile.dart';

class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({super.key});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

void _submit() {
  if (_formKey.currentState!.validate()) {
    final newProfile = Profile(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // simple unique id
      name: _nameController.text,
      age: int.parse(_ageController.text),
      primaryCondition: _conditionController.text,
    );
    Navigator.pop(context, newProfile);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter an age' : null,
              ),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(labelText: 'Primary Condition'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter a condition' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}