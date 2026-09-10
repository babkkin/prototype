// lib/models/vitals.dart
class Vitals {
  final String? bp;
  final String? temperature;
  final String? pulseRate;
  final String? respiratoryRate;
  final String? oxygenSaturation;
  final String? pain;

  const Vitals({
    this.bp,
    this.temperature,
    this.pulseRate,
    this.respiratoryRate,
    this.oxygenSaturation,
    this.pain,
  });
}