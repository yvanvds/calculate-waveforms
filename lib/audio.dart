import 'dart:typed_data';

import 'waveform.dart';
import 'audio_stub.dart'
    if (dart.library.js_interop) 'audio_web.dart'
    as platform;

/// Fixed playback gain; hard clipping is applied only to the audio copy.
const playbackGain = 0.2;
const playbackLimit = 0.9;

Float32List audioSamples(List<double> samples) => Float32List.fromList(
  samples
      .map(
        (sample) => (sample * playbackGain)
            .clamp(-playbackLimit, playbackLimit)
            .toDouble(),
      )
      .toList(),
);

abstract class AudioOutput {
  Future<void> play(Float32List samples, int rate, void Function() onEnded);
  void stop();
  void dispose();
}

AudioOutput createAudioOutput() => platform.createAudioOutput();

Future<void> playWave(
  AudioOutput output,
  Waveform wave,
  void Function() ended,
) => output.play(audioSamples(wave.samples), sampleRate, ended);
