import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';

/// Form for adding a new appointment, or editing [existing] when given.
/// Pops with an [AppointmentsCompanion]; the caller inserts or updates it.
class AddAppointmentScreen extends StatefulWidget {
  final int profileId;
  final Appointment? existing;

  const AddAppointmentScreen({
    super.key,
    required this.profileId,
    this.existing,
  });

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  static const _quickTitles = [
    'Check-up',
    'Follow-up',
    'Laboratory test',
    'Vaccination',
    'Therapy',
  ];

  static final _dateFormat = DateFormat('MMM d, y');
  static final _timeFormat = DateFormat('h:mm a');

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _doctorController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _doctorController.text = e.doctorName ?? '';
      _locationController.text = e.location ?? '';
      _notesController.text = e.notes ?? '';

      _date = DateTime(
        e.appointmentAt.year,
        e.appointmentAt.month,
        e.appointmentAt.day,
      );
      _time = TimeOfDay.fromDateTime(e.appointmentAt);
      _dateController.text = _dateFormat.format(e.appointmentAt);
      _timeController.text = _timeFormat.format(e.appointmentAt);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      _date = picked;
      _dateController.text = _dateFormat.format(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;

    setState(() {
      _time = picked;
      _timeController.text =
          _timeFormat.format(DateTime(2000, 1, 1, picked.hour, picked.minute));
    });
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // The validators guarantee both are set.
    final date = _date!;
    final time = _time!;

    Navigator.pop(
      context,
      AppointmentsCompanion(
        profileId: Value(widget.profileId),
        title: Value(_titleController.text.trim()),
        doctorName: Value(_emptyToNull(_doctorController.text)),
        location: Value(_emptyToNull(_locationController.text)),
        appointmentAt: Value(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        ),
        notes: Value(_emptyToNull(_notesController.text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Appointment' : 'Add Appointment'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Purpose *',
                  hintText: 'e.g. Cardiology follow-up',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Enter the purpose of the visit';
                  if (text.length > 150) return 'Too long (max 150)';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _quickTitles
                    .map(
                      (t) => ActionChip(
                        label: Text(t),
                        onPressed: () =>
                            setState(() => _titleController.text = t),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        labelText: 'Date *',
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Pick a date'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: const InputDecoration(
                        labelText: 'Time *',
                        suffixIcon: Icon(Icons.access_time, size: 18),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Pick a time'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Doctor',
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Clinic / hospital',
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Things to bring or ask (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Save Changes' : 'Save Appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
