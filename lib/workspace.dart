import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'main.dart' show DesignTokens;
import 'waveform.dart';
import 'audio.dart';

class Workspace extends StatefulWidget {
  const Workspace({super.key, required this.tokens});
  final DesignTokens tokens;
  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  final workspace = WaveformWorkspace();
  AudioOutput? audio;
  String? playing;
  String? audioError;

  Future<void> play(Waveform wave) async {
    setState(() {
      playing = wave.id;
      audioError = null;
    });
    try {
      await playWave(audio ??= createAudioOutput(), wave, () {
        if (mounted) setState(() => playing = null);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          playing = null;
          audioError = 'Afspelen lukt niet. Probeer opnieuw.';
        });
      }
    }
  }

  void stop() {
    audio?.stop();
    setState(() => playing = null);
  }

  @override
  void dispose() {
    audio?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final wave in workspace.waves)
        WaveCard(
          key: ValueKey(wave.id),
          wave: wave,
          tokens: widget.tokens,
          playing: playing == wave.id,
          onPlay: () => play(wave),
          onStop: stop,
        ),
      if (audioError != null) Text(audioError!),
      const SizedBox(height: 16),
      FilledButton.icon(
        key: const Key('add-wave'),
        style: FilledButton.styleFrom(
          backgroundColor: widget.tokens.color('primary'),
          foregroundColor: widget.tokens.color('on-primary'),
        ),
        onPressed: () => setState(workspace.addSine),
        icon: const Icon(Icons.add),
        label: const Text('Nieuwe waveform toevoegen'),
      ),
    ],
  );
}

class WaveCard extends StatefulWidget {
  const WaveCard({
    super.key,
    required this.wave,
    required this.tokens,
    required this.playing,
    required this.onPlay,
    required this.onStop,
  });
  final Waveform wave;
  final bool playing;
  final VoidCallback onPlay, onStop;
  final DesignTokens tokens;
  @override
  State<WaveCard> createState() => _WaveCardState();
}

class _WaveCardState extends State<WaveCard> {
  String? error;
  @override
  Widget build(BuildContext context) {
    final wave = widget.wave;
    final tokens = widget.tokens;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.color('surface-sunken'),
        borderRadius: BorderRadius.circular(tokens.size('radius', 'radius-md')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${wave.id} · Sinusgolf',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: tokens.color('forest'),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                key: Key('play-${wave.id}'),
                onPressed: widget.playing ? widget.onStop : widget.onPlay,
                icon: Icon(widget.playing ? Icons.stop : Icons.play_arrow),
                label: Text(widget.playing ? 'Stoppen' : 'Afspelen'),
              ),
              Text(
                widget.playing
                    ? '${wave.id} speelt · 2 seconden'
                    : 'Klaar om te luisteren · 2 seconden',
                key: Key('status-${wave.id}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: Key('frequency-${wave.id}'),
            initialValue: '${wave.frequency.toInt()}',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Frequentie ${wave.id} (Hz)',
              helperText: '1 tot 20.000 Hz · amplitude 1',
              errorText: error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (text) {
              final value = double.tryParse(text.replaceAll(',', '.'));
              setState(() {
                if (value == null ||
                    !value.isFinite ||
                    value < minFrequency ||
                    value > maxFrequency) {
                  error = 'Kies een getal van 1 tot en met 20.000 Hz.';
                } else {
                  error = null;
                  wave.updateFrequency(value);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            '${wave.id} = sin(2π × ${wave.frequency == wave.frequency.roundToDouble() ? wave.frequency.toInt().toString() : wave.frequency.toString()} × t)',
            key: Key('formula-${wave.id}'),
          ),
          const SizedBox(height: 16),
          Text(
            'Volledige golf · 0–2 s',
            style: TextStyle(color: tokens.color('ink-muted')),
          ),
          WaveGraph(wave: wave, tokens: tokens, endTime: 2),
          const SizedBox(height: 16),
          Text(
            'Detail · maximaal drie oscillaties (${(1000 * math.min(2, 3 / wave.frequency)).toStringAsFixed(2)} ms)',
            style: TextStyle(color: tokens.color('ink-muted')),
          ),
          WaveGraph(
            wave: wave,
            tokens: tokens,
            endTime: math.min(2, 3 / wave.frequency),
          ),
        ],
      ),
    );
  }
}

class WaveGraph extends StatelessWidget {
  const WaveGraph({
    super.key,
    required this.wave,
    required this.tokens,
    required this.endTime,
  });
  final Waveform wave;
  final DesignTokens tokens;
  final double endTime;
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'Grafiek ${wave.id}, ${wave.frequency} Hz, tijd 0 tot $endTime seconden, amplitude min 1 tot plus 1',
    child: SizedBox(
      height: 170,
      width: double.infinity,
      child: CustomPaint(
        painter: WavePainter(
          samples: wave.samples,
          endTime: endTime,
          line: tokens.color('line-strong'),
          ink: tokens.color('ink-muted'),
          waveColor: tokens.color('brand-text'),
        ),
      ),
    ),
  );
}

class WavePainter extends CustomPainter {
  WavePainter({
    required this.samples,
    required this.endTime,
    required this.line,
    required this.ink,
    required this.waveColor,
  });
  final List<double> samples;
  final double endTime;
  final Color line, ink, waveColor;
  @override
  void paint(Canvas canvas, Size size) {
    final area = Rect.fromLTRB(38, 12, size.width - 12, size.height - 36);
    final axis = Paint()
      ..color = line
      ..strokeWidth = 1;
    canvas.drawLine(area.topLeft, area.bottomLeft, axis);
    canvas.drawLine(
      Offset(area.left, area.center.dy),
      Offset(area.right, area.center.dy),
      axis,
    );
    void label(String text, Offset position) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: ink, fontSize: 12, fontFamily: 'Figtree'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, position);
    }

    label('+1', Offset(4, area.top));
    label('−1', Offset(4, area.bottom - 12));
    label('0', Offset(area.left, area.bottom + 5));
    label(
      '${endTime.toStringAsPrecision(3)} s',
      Offset(math.max(area.left, area.right - 55), area.bottom + 5),
    );
    label('Amplitude', Offset(area.left + 6, area.top));
    label('Tijd (s)', Offset(area.center.dx - 20, area.bottom + 20));
    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    final count = math.min(samples.length, (endTime * sampleRate).ceil());
    final path = Path();
    // A min/max envelope per pixel preserves high-frequency peaks in the overview.
    final pixels = math.max(1, area.width.ceil());
    for (var x = 0; x < pixels; x++) {
      final start = x * count ~/ pixels;
      final stop = math.min(
        count,
        math.max(start + 1, (x + 1) * count ~/ pixels),
      );
      var low = samples[math.min(start, count - 1)];
      var high = low;
      for (var i = start; i < stop; i++) {
        low = math.min(low, samples[i]);
        high = math.max(high, samples[i]);
      }
      final dx = area.left + x * area.width / pixels;
      final y =
          area.center.dy -
          samples[math.min(start, count - 1)] * area.height / 2;
      if (x == 0) {
        path.moveTo(dx, y);
      } else {
        path.lineTo(dx, y);
      }
      if (stop - start > 1) {
        canvas.drawLine(
          Offset(dx, area.center.dy - low * area.height / 2),
          Offset(dx, area.center.dy - high * area.height / 2),
          paint,
        );
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      oldDelegate.samples != samples || oldDelegate.endTime != endTime;
}
