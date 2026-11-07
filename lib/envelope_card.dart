part of 'workspace.dart';

class EnvelopeCard extends StatefulWidget {
  const EnvelopeCard({
    super.key,
    required this.envelope,
    required this.tokens,
    required this.onChanged,
  });
  final Envelope envelope;
  final DesignTokens tokens;
  final VoidCallback onChanged;
  @override
  State<EnvelopeCard> createState() => _EnvelopeCardState();
}

class _EnvelopeCardState extends State<EnvelopeCard> {
  String? error;
  late final values = [
    widget.envelope.attack,
    widget.envelope.decay,
    widget.envelope.sustain,
    widget.envelope.release,
  ].map((v) => v.toString()).toList();
  void update(EnvelopeType type) {
    setState(() {
      try {
        final v = values
            .map((s) => double.tryParse(s.replaceAll(',', '.')) ?? double.nan)
            .toList();
        widget.envelope.update(type, v[0], v[1], v[2], v[3]);
        error = null;
        widget.onChanged();
      } on ArgumentError catch (e) {
        error = e.message.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.envelope;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.tokens.color('surface-sunken'),
        borderRadius: BorderRadius.circular(
          widget.tokens.size('radius', 'radius-md'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${e.id} · Volumeverloop',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: widget.tokens.color('forest'),
            ),
          ),
          DropdownButtonFormField<EnvelopeType>(
            key: Key('type-${e.id}'),
            initialValue: e.type,
            decoration: const InputDecoration(labelText: 'Envelopevorm'),
            items: const [
              DropdownMenuItem(
                value: EnvelopeType.swell,
                child: Text('Lineair aanzwellen'),
              ),
              DropdownMenuItem(
                value: EnvelopeType.fade,
                child: Text('Lineair uitdoven'),
              ),
              DropdownMenuItem(value: EnvelopeType.adsr, child: Text('ADSR')),
            ],
            onChanged: (type) {
              if (type != null) update(type);
            },
          ),
          if (e.type == EnvelopeType.adsr) ...[
            const Text(
              'ADSR: aanzet naar 1, terugval naar het aanhoudniveau, aanhouden en loslaten naar 0. De resterende tijd van de twee seconden is de aanhoudfase.',
            ),
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextFormField(
                  key: Key('adsr-${e.id}-$i'),
                  initialValue: values[i],
                  decoration: InputDecoration(
                    labelText: [
                      'Aanzet (s)',
                      'Terugval (s)',
                      'Aanhoudniveau (0–1)',
                      'Loslaten (s)',
                    ][i],
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    values[i] = text;
                    update(e.type);
                  },
                ),
              ),
          ],
          if (error != null) Text(error!, key: Key('error-${e.id}')),
          const Text('Volumeverloop · 0–2 s · niveau 0–1'),
          Semantics(
            label: 'Grafiek ${e.id}, tijd 0 tot 2 seconden, niveau 0 tot 1',
            child: SizedBox(
              height: 170,
              width: double.infinity,
              child: CustomPaint(
                painter: WavePainter(
                  samples: [...e.samples, e.valueAt(2)],
                  unipolar: true,
                  endTime: 2,
                  line: widget.tokens.color('line-strong'),
                  ink: widget.tokens.color('ink-muted'),
                  waveColor: widget.tokens.color('brand-text'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
