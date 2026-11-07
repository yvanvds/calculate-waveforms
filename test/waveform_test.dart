import 'dart:math';

import 'package:calculate_waveforms/waveform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sinuswaarden en tijdsbasis zijn exact twee seconden', () {
    final wave = Waveform(id: 'W1', frequency: 1000);
    expect(wave.samples.length / sampleRate, 2);
    expect(wave.samples[0], 0);
    expect(wave.samples[12], closeTo(1, 1e-12));
    expect(wave.samples[24], closeTo(0, 1e-12));
    expect(wave.samples[36], closeTo(-1, 1e-12));
    expect(wave.samples[48], closeTo(wave.samples[0], 1e-12));
    expect(
      wave.samples[100],
      closeTo(sin(2 * pi * 1000 * 100 / sampleRate), 1e-12),
    );
  });
  test('Wijzigen herberekent data en toevoegen behoudt unieke bronnen', () {
    final workspace = WaveformWorkspace();
    final first = workspace.waves.first;
    first.updateFrequency(220.5);
    final second = workspace.addSine();
    final third = workspace.addSine();
    expect([first.id, second.id, third.id], ['W1', 'W2', 'W3']);
    expect(first.frequency, 220.5);
    expect(second.frequency, 440);
    expect(
      first.samples[100],
      closeTo(sin(2 * pi * 220.5 * 100 / sampleRate), 1e-12),
    );
    expect(WaveformWorkspace().waves.single.id, 'W1');
  });
  test('Frequentiegrenzen beschermen geldige data', () {
    final wave = Waveform(id: 'W1');
    for (final value in [0.0, -1.0, 20001.0, double.nan, double.infinity]) {
      expect(() => wave.updateFrequency(value), throwsArgumentError);
    }
    expect(wave.frequency, 440);
    wave.updateFrequency(1);
    wave.updateFrequency(20000);
  });
}
