import 'dart:typed_data';

import 'waveform.dart' show sampleRate, durationSeconds;

enum EnvelopeType { swell, fade, adsr }

class Envelope {
  Envelope({required this.id});
  final String id;
  EnvelopeType type = EnvelopeType.swell;
  double attack = 0.2, decay = 0.3, sustain = 0.7, release = 0.5;

  void update(EnvelopeType kind, double a, double d, double s, double r) {
    if ([a, d, s, r].any((v) => !v.isFinite) ||
        a < 0 ||
        d < 0 ||
        r < 0 ||
        a + d + r > 2 ||
        s < 0 ||
        s > 1) {
      throw ArgumentError(
        'Tijden moeten positief of nul zijn en samen maximaal 2 s; aanhoudniveau moet tussen 0 en 1 liggen.',
      );
    }
    type = kind;
    attack = a;
    decay = d;
    sustain = s;
    release = r;
  }

  double valueAt(double t) {
    t = t.clamp(0, 2);
    if (type == EnvelopeType.swell) return t / 2;
    if (type == EnvelopeType.fade) return 1 - t / 2;
    if (t >= 2) return 0;
    if (t < attack) return t / attack;
    if (t < attack + decay) return 1 + (sustain - 1) * (t - attack) / decay;
    if (t < 2 - release) return sustain;
    return release == 0 ? sustain : sustain * (2 - t) / release;
  }

  Float64List get samples => Float64List.fromList(
    List.generate(sampleRate * durationSeconds, (i) => valueAt(i / sampleRate)),
  );
}
