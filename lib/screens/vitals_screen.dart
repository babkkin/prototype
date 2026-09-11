import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import 'package:drift/drift.dart' show Value;

class VitalsScreen extends StatefulWidget {
  final Profile profile;
  const VitalsScreen({super.key, required this.profile});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _bpController = TextEditingController();
  final _tempController = TextEditingController();
  final _prController = TextEditingController();
  final _rrController = TextEditingController();
  final _o2Controller = TextEditingController();

  double _pain = 0; // 0–10 scale

  @override
  void dispose() {
    _bpController.dispose();
    _tempController.dispose();
    _prController.dispose();
    _rrController.dispose();
    _o2Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final vitalsDao = context.read<AppDatabase>().vitalsDao;

      await vitalsDao.insertVitals(
        VitalsTableCompanion.insert(
          profileId: widget.profile.id,
          bp: Value(_bpController.text),
          temperature: Value(_tempController.text),
          pulseRate: Value(_prController.text),
          respiratoryRate: Value(_rrController.text),
          oxygenSaturation: Value(_o2Controller.text),
          pain: Value(_pain.round().toString()),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context); // no data to return — DetailsPage's StreamBuilder updates automatically
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Vitals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _vitalField('Blood Pressure (BP)', 'e.g. 120/80', _bpController),
              _vitalField('Temperature (T)', 'e.g. 36.5°C', _tempController),
              _vitalField('Pulse Rate (PR)', 'e.g. 72 bpm', _prController),
              _vitalField('Respiratory Rate (RR)', 'e.g. 16 breaths/min', _rrController),
              _vitalField('O2 Saturation', 'e.g. 98%', _o2Controller),

              const SizedBox(height: 12),
              Text('Pain Level: ${_pain.round()} / 10', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _pain,
                min: 0,
                max: 10,
                divisions: 10,
                label: _pain.round().toString(),
                onChanged: (value) => setState(() => _pain = value),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Vitals'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vitalField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }
}