import 'dart:typed_data';

import 'package:calculate_waveforms/audio.dart';
import 'package:calculate_waveforms/waveform.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingOutput implements AudioOutput {
  late Float32List samples;
  late int rate;
  @override
  Future<void> play(
    Float32List samples,
    int rate,
    void Function() ended,
  ) async {
    this.samples = samples;
    this.rate = rate;
  }

  @override
  void stop() {}
  @override
  void dispose() {}
}

void main() {
  test('Afgeleide audio gebruikt de actuele keten zonder rekenamplitudes te beperken', () async {
    final workspace = WaveformWorkspace();
    final source = workspace.waves.first;
    final scaled = workspace.addOperation();
    workspace.updateOperation(scaled, source, null, 2);
    final sum = workspace.addOperation(sum: true);
    workspace.updateOperation(sum, scaled, source, null);
    final output = RecordingOutput();
    await playWave(output, sum, () {});
    final before = output.samples[12];
    workspace.updateFrequency(source, 1000);
    await playWave(output, sum, () {});
    expect(sum.samples[12], closeTo(3, 1e-12));
    expect(output.samples[12], closeTo(0.6, 1e-7));
    expect(output.samples[12], isNot(before));
  });
  test(
    'Audio copies current graph data at fixed gain and exact duration',
    () async {
      final wave = Waveform(id: 'W1');
      final output = RecordingOutput();
      final original = wave.samples.toList();
      await playWave(output, wave, () {});
      expect(output.samples.length, 96000);
      expect(output.samples.length / output.rate, 2);
      for (var i = 0; i < original.length; i++) {
        expect(
          output.samples[i],
          closeTo(original[i] * playbackGain, 0.00000002),
        );
      }
      expect(wave.samples, original);
      final first = output.samples;
      wave.updateFrequency(880);
      await playWave(output, wave, () {});
      expect(
        output.samples[20],
        closeTo(wave.samples[20] * playbackGain, 0.00000002),
      );
      expect(output.samples[20], isNot(first[20]));
    },
  );
  test(
    'Playback clips symmetrically without normalizing or changing inputs',
    () {
      final input = [-100.0, -1.0, 0.0, 0.5, 1.0, 100.0];
      final output = audioSamples(input);
      expect(output[0], closeTo(-0.9, 0.0000001));
      expect(output[5], closeTo(0.9, 0.0000001));
      expect(output[3], closeTo(0.1, 0.0000001));
      expect(output[4], closeTo(0.2, 0.0000001));
      expect(input, [-100, -1, 0, 0.5, 1, 100]);
    },
  );
}
