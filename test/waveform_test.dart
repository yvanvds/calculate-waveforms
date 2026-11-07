import 'dart:math';

import 'package:calculate_waveforms/waveform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Grote eindige factoren behouden hun formulewaarde', () {
    final workspace = WaveformWorkspace();
    final wave = workspace.addOperation();
    workspace.updateOperation(wave, workspace.waves.first, null, 1e100);
    expect(wave.formula, 'W2 = W1 × 1e+100');
    expect(wave.samples.every((value) => value.isFinite), isTrue);
  });
  test('Bewerkingen bewaren amplitudes, bronnen en doorwerking', () {
    final workspace = WaveformWorkspace();
    final a = workspace.waves.first;
    final scaled = workspace.addOperation();
    for (final factor in [0.0, -1.0, 2.5]) {
      workspace.updateOperation(scaled, a, null, factor);
      for (final i in [0, 12, 57, 95999]) {
        expect(scaled.samples[i], a.samples[i] * factor);
      }
    }
    final sum = workspace.addOperation(sum: true);
    workspace.updateOperation(sum, a, a, null);
    expect(sum.samples[12], a.samples[12] * 2);
    workspace.updateOperation(scaled, a, null, -1);
    workspace.updateOperation(sum, a, scaled, null);
    expect(sum.samples.every((v) => v == 0), isTrue);
    workspace.updateOperation(sum, scaled, scaled, null);
    workspace.updateFrequency(a, 1000);
    expect(sum.samples[12], closeTo(-2, 1e-12));
    expect(sum.samples.length, 96000);
    expect(workspace.waves.map((w) => w.id).toSet().length, 3);
    expect(
      () => workspace.updateOperation(scaled, sum, null, 1),
      throwsArgumentError,
    );
    for (final invalid in [double.nan, double.infinity, 1e308]) {
      expect(
        () => workspace.updateOperation(scaled, a, null, invalid),
        throwsArgumentError,
      );
    }
    expect(scaled.factor, -1);
    expect(sum.samples[12], closeTo(-2, 1e-12));
  });
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
