import 'dart:math' as math;
import 'dart:typed_data';

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

class WaveformWorkspace {
  final List<Waveform> waves = [];
  int _nextId = 1;

  WaveformWorkspace() {
    addSine();
  }

  Waveform addSine() {
    final wave = Waveform(id: 'W${_nextId++}');
    waves.add(wave);
    return wave;
  }
}
