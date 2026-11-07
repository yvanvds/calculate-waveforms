import 'package:calculate_waveforms/envelope.dart';
import 'package:calculate_waveforms/waveform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lineaire envelopes duren twee seconden en bereiken hun eindpunten', () {
    final e = Envelope(id: 'E1');
    expect(e.samples.length / sampleRate, 2);
    expect([e.valueAt(0), e.valueAt(1), e.valueAt(2)], [0, .5, 1]);
    e.update(EnvelopeType.fade, .2, .3, .7, .5);
    expect([e.valueAt(0), e.valueAt(1), e.valueAt(2)], [1, .5, 0]);
  });
  test('ADSR faseovergangen, nulduur en grenzen', () {
    final e = Envelope(id: 'E1')..update(EnvelopeType.adsr, .2, .3, .7, .5);
    for (final entry in {
      0.0: 0.0,
      .1: .5,
      .2: 1.0,
      .5: .7,
      1.5: .7,
      1.75: .35,
      2.0: 0.0,
    }.entries) {
      expect(e.valueAt(entry.key), closeTo(entry.value, 1e-12));
    }
    e.update(EnvelopeType.adsr, 0, 0, 1, 0);
    expect(e.samples.every((v) => v == 1), isTrue);
    expect(e.valueAt(2), 0);
    e.update(EnvelopeType.adsr, 1, 1, 0, 0);
    expect(e.valueAt(1), 1);
    for (final v in [
      [-1.0, 0.0, 0.0, 0.0],
      [1.0, 1.0, .5, .1],
      [0.0, 0.0, 1.1, 0.0],
      [0.0, 0.0, -.1, 0.0],
      [double.nan, 0.0, .5, 0.0],
    ]) {
      expect(
        () => e.update(EnvelopeType.adsr, v[0], v[1], v[2], v[3]),
        throwsArgumentError,
      );
    }
  });
  test('Unieke IDs, vermenigvuldigen en keten werken door', () {
    final ws = WaveformWorkspace();
    final e = ws.addEnvelope();
    expect(ws.addEnvelope().id, 'E2');
    final applied = ws.applyEnvelope();
    final sum = ws.addOperation(sum: true);
    ws.updateOperation(sum, applied, ws.waves.first, null);
    ws.updateFrequency(ws.waves.first, 1);
    expect(applied.formula, 'W2 = W1 × E1');
    expect(applied.samples[12000], closeTo(.125, 1e-12));
    expect(sum.samples[12000], closeTo(1.125, 1e-12));
    e.update(EnvelopeType.fade, 0, 0, 1, 0);
    ws.recalculate();
    expect(sum.samples[12000], closeTo(1.875, 1e-12));
    expect(applied.samples.length, 96000);
  });
}
