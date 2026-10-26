import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/app_database.dart';

/// Everything the summary needs, loaded in one shot.
class MedicalSummaryData {
  MedicalSummaryData({
    required this.profile,
    required this.latestVitals,
    required this.vitalsHistory,
    required this.medications,
    required this.symptoms,
    required this.appointments,
    this.range,
  });

  final Profile profile;
  final VitalsTableData? latestVitals;
  final List<VitalsTableData> vitalsHistory;
  final List<Medication> medications;
  final List<Symptom> symptoms;

  /// Most-recent mode: upcoming, not-done appointments (max 10).
  /// Period mode: every appointment inside the period, any status.
  final List<Appointment> appointments;

  /// null = "most recent entries" (last few vitals/symptoms, active meds).
  final DateTimeRange? range;
}

class MedicalSummaryService {
  MedicalSummaryService(this.db);

  final AppDatabase db;

  static final _dateTime = DateFormat('MMM d, y h:mm a');
  static final _date = DateFormat('MMM d, y');

  // -------------------------------------------------------------------
  // DATA
  // -------------------------------------------------------------------

  /// [range] null  -> most recent entries (last [vitalsLimit] vitals,
  ///                  last [symptomsLimit] symptoms, medications active today).
  /// [range] given -> everything inside that period (both end days included),
  ///                  and medications whose dates overlap the period.
  Future<MedicalSummaryData> load(
    int profileId, {
    DateTimeRange? range,
    int vitalsLimit = 10,
    int symptomsLimit = 20,
  }) async {
    final DateTime? from = range == null ? null : _startOfDay(range.start);
    final DateTime? to = range == null ? null : _nextDay(range.end);

    final profile = await (db.select(db.profiles)
          ..where((t) => t.id.equals(profileId)))
        .getSingle();

    final vitalsQuery = db.select(db.vitalsTable)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]);
    if (range != null) {
      vitalsQuery.where((t) =>
          t.recordedAt.isBiggerOrEqualValue(from!) &
          t.recordedAt.isSmallerThanValue(to!));
    }
    vitalsQuery.limit(range == null ? vitalsLimit : 500);
    final vitals = await vitalsQuery.get();

    final meds = await (db.select(db.medications)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm(expression: t.medicationName)]))
        .get();

    final symptomsQuery = db.select(db.symptoms)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]);
    if (range != null) {
      symptomsQuery.where((t) =>
          t.loggedAt.isBiggerOrEqualValue(from!) &
          t.loggedAt.isSmallerThanValue(to!));
    }
    symptomsQuery.limit(range == null ? symptomsLimit : 500);
    final symptoms = await symptomsQuery.get();

    final appointmentsQuery = db.select(db.appointments)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm(expression: t.appointmentAt)]);
    if (range != null) {
      appointmentsQuery.where((t) =>
          t.appointmentAt.isBiggerOrEqualValue(from!) &
          t.appointmentAt.isSmallerThanValue(to!));
    } else {
      appointmentsQuery
        ..where((t) =>
            t.isDone.equals(false) &
            t.appointmentAt.isBiggerOrEqualValue(DateTime.now()))
        ..limit(10);
    }
    final appointments = await appointmentsQuery.get();

    return MedicalSummaryData(
      profile: profile,
      latestVitals: vitals.isEmpty ? null : vitals.first,
      vitalsHistory: vitals,
      medications: meds,
      symptoms: symptoms,
      appointments: appointments,
      range: range,
    );
  }

  // -------------------------------------------------------------------
  // PUBLIC ACTIONS (call these from your UI)
  // -------------------------------------------------------------------

  /// Opens the system preview with print / save-as-PDF / share built in.
  ///
  /// [onReady] is called once the PDF has been built, just before the system
  /// preview appears, so the caller can dismiss a loading indicator.
  Future<void> preview(
    int profileId, {
    DateTimeRange? range,
    void Function()? onReady,
  }) async {
    final data = await load(profileId, range: range);
    final bytes = await buildPdf(data);
    onReady?.call();
    await Printing.layoutPdf(
      name: _fileName(data.profile),
      onLayout: (_) async => bytes,
    );
  }

  /// Opens the share sheet directly (email, messaging apps, cloud drive...).
  Future<void> share(
    int profileId, {
    DateTimeRange? range,
    void Function()? onReady,
  }) async {
    final data = await load(profileId, range: range);
    final bytes = await buildPdf(data);
    onReady?.call();
    await Printing.sharePdf(bytes: bytes, filename: _fileName(data.profile));
  }

  String _fileName(Profile p) {
    final safe = p.name.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    return 'medical_summary_${safe}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
  }

  // -------------------------------------------------------------------
  // PDF
  // -------------------------------------------------------------------

  // Same date-only rule as DailyMedicationSchedule: a medication whose end
  // date is today is still active for the whole day.
  bool _isActive(Medication m) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start =
        DateTime(m.startDate.year, m.startDate.month, m.startDate.day);
    final end = m.endDate == null
        ? null
        : DateTime(m.endDate!.year, m.endDate!.month, m.endDate!.day);
    if (today.isBefore(start)) return false;
    if (end != null && today.isAfter(end)) return false;
    return true;
  }

  // A medication belongs in a period summary if its start/end dates overlap
  // the selected range (date-only comparison, both end days included).
  bool _overlapsRange(Medication m, DateTimeRange r) {
    final start = _startOfDay(m.startDate);
    final end = m.endDate == null ? null : _startOfDay(m.endDate!);
    if (start.isAfter(_startOfDay(r.end))) return false;
    if (end != null && end.isBefore(_startOfDay(r.start))) return false;
    return true;
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);

  String _v(String? s) => (s == null || s.trim().isEmpty) ? '-' : s.trim();

  Future<Uint8List> buildPdf(MedicalSummaryData d) async {
    final doc = pw.Document(
      title: 'Medical Summary - ${d.profile.name}',
      author: 'Health Tracker',
    );

    final range = d.range;
    final activeMeds = (range == null
            ? d.medications.where(_isActive)
            : d.medications.where((m) => _overlapsRange(m, range)))
        .toList();
    List<Medication> ofType(PrescriptionType t) =>
        activeMeds.where((m) => m.prescriptionType == t).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // Pages after the first repeat the patient name so a loose sheet
        // can never be separated from whose it is.
        header: (ctx) => ctx.pageNumber == 1
            ? pw.SizedBox()
            : pw.Container(
                alignment: pw.Alignment.centerLeft,
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.only(bottom: 4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey400),
                  ),
                ),
                child: pw.Text(
                  '${d.profile.name} - Medical Summary (continued)',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${d.profile.name} | Self-reported, not an official medical record',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        build: (ctx) => [
          _header(d.profile, range),
          _section(range == null ? 'Latest Vital Signs' : 'Latest Vital Signs In Period'),
          _latestVitals(d.latestVitals, periodOnly: range != null),
          if (d.vitalsHistory.length > 1) ...[
            _section('Vital Signs History'),
            _vitalsTable(d.vitalsHistory),
          ],
          _section(range == null ? 'Current Medications' : 'Medications During Period'),
          if (activeMeds.isEmpty)
            _muted('No active medications recorded.')
          else ...[
            _medGroup('Maintenance', ofType(PrescriptionType.maintenance)),
            _medGroup('Temporary', ofType(PrescriptionType.temporary)),
            _medGroup('As needed (PRN)', ofType(PrescriptionType.prn)),
          ],
          _section(range == null
              ? 'Upcoming Appointments'
              : 'Appointments During Period'),
          if (d.appointments.isEmpty)
            _muted(range == null
                ? 'No upcoming appointments.'
                : 'No appointments in this period.')
          else
            ...d.appointments.map(_appointmentCard),
          _section(range == null ? 'Recent Symptoms' : 'Symptoms During Period'),
          if (d.symptoms.isEmpty)
            _muted('No symptoms logged.')
          else
            ...d.symptoms.map(_symptomCard),
          pw.SizedBox(height: 18),
          _muted(
            'This summary was generated from information entered by the '
            'patient or caregiver in a personal health app. It is not an '
            'official medical record. Please verify details with a '
            'healthcare professional.',
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ---- building blocks ----------------------------------------------

  pw.Widget _header(Profile p, DateTimeRange? range) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.blueGrey800, width: 2),
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Medical Summary',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              p.name,
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text('Age: ${p.age}    Primary condition: ${_v(p.primaryCondition)}'),
            pw.SizedBox(height: 2),
            pw.Text(
              range == null
                  ? 'Period: Most recent entries'
                  : 'Period: ${_date.format(range.start)} - ${_date.format(range.end)}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Generated: ${_dateTime.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      );

  pw.Widget _section(String title) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
        child: pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1,
            color: PdfColors.blueGrey700,
          ),
        ),
      );

  pw.Widget _muted(String text) => pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontStyle: pw.FontStyle.italic,
          color: PdfColors.grey700,
        ),
      );

  pw.Widget _kv(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 120,
              child: pw.Text(
                k,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(v, style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );

  pw.Widget _latestVitals(VitalsTableData? v, {bool periodOnly = false}) {
    if (v == null) {
      return _muted(periodOnly
          ? 'No vital signs recorded in this period.'
          : 'No vital signs recorded.');
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _kv('Recorded', _dateTime.format(v.recordedAt)),
          _kv('Blood pressure', _v(v.bp)),
          _kv('Temperature', _v(v.temperature)),
          _kv('Pulse rate', _v(v.pulseRate)),
          _kv('Respiratory rate', _v(v.respiratoryRate)),
          _kv('Oxygen saturation', _v(v.oxygenSaturation)),
          _kv('Pain', v.pain == null ? '-' : '${v.pain}/10'),
        ],
      ),
    );
  }

  pw.Widget _vitalsTable(List<VitalsTableData> list) =>
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration:
            const pw.BoxDecoration(color: PdfColors.blueGrey700),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
        headers: ['Date', 'BP', 'Temp', 'Pulse', 'RR', 'SpO2', 'Pain /10'],
        data: list
            .map((v) => [
                  _dateTime.format(v.recordedAt),
                  _v(v.bp),
                  _v(v.temperature),
                  _v(v.pulseRate),
                  _v(v.respiratoryRate),
                  _v(v.oxygenSaturation),
                  _v(v.pain),
                ])
            .toList(),
      );

  pw.Widget _medGroup(String label, List<Medication> meds) {
    if (meds.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ),
        ...meds.map(_medCard),
      ],
    );
  }

  pw.Widget _medCard(Medication m) {
    final name = m.brandName == null || m.brandName!.trim().isEmpty
        ? m.medicationName
        : '${m.medicationName} (${m.brandName})';

    final dose = [
      if (m.strength != null && m.strength!.trim().isNotEmpty) m.strength,
      m.dosage,
      m.dosageForm,
    ].join(', ');

    final schedule = [
      m.frequency,
      if (m.specificTime != null && m.specificTime!.trim().isNotEmpty)
        'at ${m.specificTime}',
      if (m.relationToMeals != null && m.relationToMeals!.trim().isNotEmpty)
        m.relationToMeals,
    ].join(', ');

    final duration = m.endDate == null
        ? 'Since ${_date.format(m.startDate)} (ongoing)'
        : '${_date.format(m.startDate)} to ${_date.format(m.endDate!)}';

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            name,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          _kv('Dose', dose),
          _kv('Route', _v(m.route)),
          _kv('Schedule', schedule),
          _kv('Duration', duration),
          if (m.prescriptionType == PrescriptionType.prn) ...[
            _kv('Indication', _v(m.prnIndication)),
            _kv('Max frequency', _v(m.maxPrnDoseFrequency)),
          ],
          if (m.specialInstructions != null &&
              m.specialInstructions!.trim().isNotEmpty)
            _kv('Instructions', m.specialInstructions!),
          if (m.prescriberName != null && m.prescriberName!.trim().isNotEmpty)
            _kv('Prescribed by', m.prescriberName!),
        ],
      ),
    );
  }

  pw.Widget _appointmentCard(Appointment a) {
    final status = a.isDone
        ? 'Completed'
        : a.appointmentAt.isBefore(DateTime.now())
            ? 'Not marked completed'
            : 'Upcoming';

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            a.title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          _kv('When', _dateTime.format(a.appointmentAt)),
          if (a.doctorName != null && a.doctorName!.trim().isNotEmpty)
            _kv('Doctor', a.doctorName!.trim()),
          if (a.location != null && a.location!.trim().isNotEmpty)
            _kv('Clinic / hospital', a.location!.trim()),
          _kv('Status', status),
          if (a.notes != null && a.notes!.trim().isNotEmpty)
            _kv('Notes', a.notes!.trim()),
        ],
      ),
    );
  }

  pw.Widget _symptomCard(Symptom s) => pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(bottom: 6),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _dateTime.format(s.loggedAt),
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 3),
            // COLDSPA: Character, Onset, Location, Duration,
            //          Severity, Pattern, Associated factors
            _kv('Character', _v(s.character)),
            _kv('Onset', _v(s.onset)),
            _kv('Location', _v(s.location)),
            _kv('Duration', _v(s.duration)),
            _kv('Severity', _v(s.severity)),
            _kv('Pattern', _v(s.pattern)),
            _kv('Associated factors', _v(s.associatedFactors)),
          ],
        ),
      );
}
