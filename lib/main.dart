import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(WaveformsApp(tokens: await DesignTokens.load()));
}

class DesignTokens {
  DesignTokens(this.data);
  final Map<String, dynamic> data;
  static Future<DesignTokens> load() async => DesignTokens(
    jsonDecode(await rootBundle.loadString('design-system/tokens.json'))
        as Map<String, dynamic>,
  );
  dynamic token(String group, String name) => (data[group]['tokens'] as List)
      .firstWhere((dynamic t) => t['name'] == name)['value'];
  Color color(String name) => Color(
    int.parse(
      (token('color', name)['light'] as String).replaceFirst('#', 'ff'),
      radix: 16,
    ),
  );
  double size(String group, String name) =>
      double.parse((token(group, name) as String).replaceFirst('px', ''));
}

class WaveformsApp extends StatelessWidget {
  const WaveformsApp({super.key, required this.tokens});
  final DesignTokens tokens;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rekenen met waveforms',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Figtree',
      scaffoldBackgroundColor: tokens.color('bg'),
      textTheme: ThemeData().textTheme.apply(
        bodyColor: tokens.color('ink'),
        fontFamily: 'Figtree',
      ),
    ),
    home: StartPage(tokens: tokens),
  );
}

class StartPage extends StatelessWidget {
  const StartPage({super.key, required this.tokens});
  final DesignTokens tokens;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: tokens.size('layout', 'content-max'),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.size('spacing', 'space-5')),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'design-system/assets/Logos/arcadia-logo.svg',
                    height: 28,
                    semanticsLabel: 'Arcadia',
                  ),
                  SizedBox(height: tokens.size('spacing', 'space-8')),
                  Text(
                    'FYSICA · ZESDE MIDDELBAAR',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.04,
                      color: tokens.color('brand-text'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      'Rekenen met waveforms',
                      style: TextStyle(
                        fontSize: MediaQuery.sizeOf(context).width < 600
                            ? 40
                            : 56,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: tokens.color('forest'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: const Text(
                      'Ontdek hoe eenvoudige golven samen een geluid vormen. Bekijk, beluister en combineer straks je eigen golven.',
                      style: TextStyle(fontSize: 19, height: 28 / 19),
                    ),
                  ),
                  SizedBox(height: tokens.size('spacing', 'space-7')),
                  Container(
                    key: const Key('experiment'),
                    width: double.infinity,
                    padding: EdgeInsets.all(tokens.size('spacing', 'space-5')),
                    decoration: BoxDecoration(
                      color: tokens.color('surface'),
                      border: Border.all(color: tokens.color('line')),
                      borderRadius: BorderRadius.circular(
                        tokens.size('radius', 'radius-lg'),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'Jouw golfexperiment',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: tokens.color('forest'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 48,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.color('surface-sunken'),
                            borderRadius: BorderRadius.circular(
                              tokens.size('radius', 'radius-md'),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.waves_rounded,
                                size: 48,
                                color: tokens.color('forest'),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Hier krijgen je golven straks vorm.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.color('forest'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Het experiment is in opbouw.',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: tokens.color('ink-muted'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Binnenkort: sinusgolven van twee seconden, bewerkingen en envelopes.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 22 / 15,
                            color: tokens.color('ink-muted'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Een fysica-experiment met beeld en geluid.',
                    style: TextStyle(
                      fontSize: 15,
                      color: tokens.color('ink-muted'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
