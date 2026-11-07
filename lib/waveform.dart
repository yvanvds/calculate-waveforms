import 'dart:math' as math;
import 'dart:typed_data';

import 'envelope.dart';

/// Shared timebase for graphs, future audio and derived waveforms.
/// Samples cover [0, 2): 96,000 samples / 48,000 Hz = exactly two seconds.
const sampleRate = 48000;
const durationSeconds = 2;
const minFrequency = 1.0;
const maxFrequency = 20000.0; // Below the 24 kHz Nyquist limit.

class Waveform {
  Waveform({required this.id, double frequency = 440}) {
    updateFrequency(frequency);
  }

  final String id;
  late double frequency;
  late Float64List samples;
  Waveform? sourceA, sourceB;
  double? factor;
  Envelope? envelope;
  bool get isSine => sourceA == null;
  String get formula => isSine
      ? '$id = sin(2π × ${number(frequency)} × t)'
      : envelope != null
      ? '$id = ${sourceA!.id} × ${envelope!.id}'
      : sourceB == null
      ? '$id = ${sourceA!.id} × ${number(factor!).replaceAll('.', ',')}'
      : '$id = ${sourceA!.id} + ${sourceB!.id}';

  void recalculate() {
    if (isSine) return;
    frequency = sourceA!.frequency;
    samples = Float64List.fromList(
      List.generate(
        sampleRate * durationSeconds,
        (i) => envelope != null
            ? sourceA!.samples[i] * envelope!.valueAt(i / sampleRate)
            : sourceB == null
            ? sourceA!.samples[i] * factor!
            : sourceA!.samples[i] + sourceB!.samples[i],
      ),
    );
    if (samples.any((value) => !value.isFinite)) {
      throw ArgumentError('Het resultaat is te groot. Kies een kleiner getal.');
    }
  }

  void updateFrequency(double value) {
    if (!value.isFinite || value < minFrequency || value > maxFrequency) {
      throw ArgumentError('Kies een frequentie van 1 tot en met 20.000 Hz.');
    }
    frequency = value;
    samples = Float64List.fromList(
      List.generate(
        sampleRate * durationSeconds,
        (i) => math.sin(2 * math.pi * value * i / sampleRate),
      ),
    );
  }
}

String number(double value) =>
    value.abs() < 1e15 && value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

class WaveformWorkspace {
  final List<Waveform> waves = [];
  int _nextId = 1;
  final List<Envelope> envelopes = [];
  Envelope addEnvelope() {
    final envelope = Envelope(id: 'E${envelopes.length + 1}');
    envelopes.add(envelope);
    return envelope;
  }

  Waveform applyEnvelope() {
    final wave = Waveform(id: 'W${_nextId++}');
    wave.sourceA = waves.first;
    wave.envelope = envelopes.first;
    wave.recalculate();
    waves.add(wave);
    return wave;
  }

  WaveformWorkspace() {
    addSine();
  }

  Waveform addSine() {
    final wave = Waveform(id: 'W${_nextId++}');
    waves.add(wave);
    return wave;
  }

  List<Waveform> sourcesFor(Waveform wave) =>
      waves.takeWhile((w) => w != wave).toList();

  Waveform addOperation({bool sum = false}) {
    final wave = Waveform(id: 'W${_nextId++}');
    wave.sourceA = waves.first;
    wave.sourceB = sum ? waves.first : null;
    wave.factor = sum ? null : 0.5;
    wave.recalculate();
    waves.add(wave);
    return wave;
  }

  void updateOperation(Waveform wave, Waveform a, Waveform? b, double? factor) {
    final allowed = sourcesFor(wave);
    if (!allowed.contains(a) || (b != null && !allowed.contains(b))) {
      throw ArgumentError(
        'Kies een eerdere golf om kringverwijzingen te voorkomen.',
      );
    }
    if (wave.envelope == null &&
        b == null &&
        (factor == null || !factor.isFinite)) {
      throw ArgumentError('Vul een eindig getal in, met een komma of punt.');
    }
    final oldA = wave.sourceA, oldB = wave.sourceB;
    final oldFactor = wave.factor;
    wave.sourceA = a;
    wave.sourceB = b;
    wave.factor = factor;
    try {
      recalculate();
    } catch (_) {
      wave.sourceA = oldA;
      wave.sourceB = oldB;
      wave.factor = oldFactor;
      recalculate();
      rethrow;
    }
  }

  void updateFrequency(Waveform wave, double frequency) {
    final old = wave.frequency;
    try {
      wave.updateFrequency(frequency);
      recalculate();
    } catch (_) {
      wave.updateFrequency(old);
      recalculate();
      rethrow;
    }
  }

  void recalculate() {
    for (final wave in waves) {
      wave.recalculate();
    }
  }
}
