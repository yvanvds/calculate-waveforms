import 'package:calculate_waveforms/main.dart' as app;
import 'package:calculate_waveforms/workspace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('De echte app opent de startpagina en werkruimte', (
    tester,
  ) async {
    // Capture the real text-input client ID; release builds reject the debug
    // fallback client (-1) used by an unregistered TestTextInput.
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);
    await app.main();
    await tester.pumpAndSettle();
    binding.reportData = {'stap': 'startpagina'};
    expect(find.text('Rekenen met waveforms'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('frequency-W1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Jouw golfexperiment'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('frequency-W1')), '220,5');
    await tester.pumpAndSettle();
    binding.reportData = {
      'stap': 'W1 wijzigen',
      'formules': tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList(),
    };
    expect(find.text('W1 = sin(2π × 220.5 × t)'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('add-wave')));
    await tester.tap(find.byKey(const Key('add-wave')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('multiply-wave')));
    await tester.tap(find.byKey(const Key('multiply-wave')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('factor-W3')));
    await tester.enterText(find.byKey(const Key('factor-W3')), '-0,5');
    await tester.pumpAndSettle();
    expect(find.text('W3 = W1 × -0,5'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('factor-W3')), 'NaN');
    await tester.pumpAndSettle();
    expect(
      find.text('Vul een eindig getal in, met een komma of punt.'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('factor-W3')), '-1.0');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('sum-wave')));
    await tester.tap(find.byKey(const Key('sum-wave')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('source-b-W4')));
    await tester.tap(find.byKey(const Key('source-b-W4')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('W3').last);
    await tester.pumpAndSettle();
    expect(find.text('W4 = W1 + W3'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('frequency-W1')));
    await tester.enterText(find.byKey(const Key('frequency-W1')), '1000');
    await tester.pumpAndSettle();
    final graphs = tester.widgetList<WaveGraph>(find.byType(WaveGraph));
    expect(
      graphs.firstWhere((g) => g.wave.id == 'W3').wave.samples[12],
      closeTo(-1, 1e-12),
    );
    expect(
      graphs
          .firstWhere((g) => g.wave.id == 'W4')
          .wave
          .samples
          .every((s) => s == 0),
      isTrue,
    );
    await tester.ensureVisible(find.byKey(const Key('play-W4')));
    await tester.tap(find.byKey(const Key('play-W4')));
    await tester.pumpAndSettle();
    expect(find.text('W4 speelt · 2 seconden'), findsOneWidget);
    await tester.tap(find.byKey(const Key('play-W4')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('frequency-W1')));
    await tester.enterText(find.byKey(const Key('frequency-W1')), '220,5');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('play-W1')));
    await tester.tap(find.byKey(const Key('play-W1')));
    await tester.pumpAndSettle();
    expect(find.text('W1 speelt · 2 seconden'), findsOneWidget);
    await tester.tap(find.byKey(const Key('play-W1')));
    await tester.pumpAndSettle();
    expect(find.text('W1 speelt · 2 seconden'), findsNothing);
    await tester.enterText(find.byKey(const Key('frequency-W1')), '0');
    await tester.pumpAndSettle();
    expect(
      find.text('Kies een getal van 1 tot en met 20.000 Hz.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('add-wave')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // W2 was added before the operations above.
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('frequency-W2')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byKey(const Key('frequency-W2')), '880');
    await tester.pumpAndSettle();
    binding.reportData = {
      'stap': 'W2 wijzigen',
      'formules': tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList(),
    };
    expect(find.text('W2 = sin(2π × 880 × t)'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('play-W2')));
    await tester.tap(find.byKey(const Key('play-W2')));
    await tester.pumpAndSettle();
    binding.reportData = {'stap': 'W2 afspelen'};
    expect(find.text('W2 speelt · 2 seconden'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('play-W1')));
    await tester.tap(find.byKey(const Key('play-W1')));
    await tester.pumpAndSettle();
    binding.reportData = {'stap': 'W1 neemt over'};
    expect(find.text('W1 speelt · 2 seconden'), findsOneWidget);
    expect(find.text('W2 speelt · 2 seconden'), findsNothing);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2300)),
    );
    await tester.pumpAndSettle();
    binding.reportData = {
      'stap': 'Automatisch einde',
      'status': tester.widget<Text>(find.byKey(const Key('status-W1'))).data,
    };
    expect(find.text('W1 speelt · 2 seconden'), findsNothing);
    expect(find.text('Afspelen lukt niet. Probeer opnieuw.'), findsNothing);
    expect(find.text('W1 = sin(2π × 220.5 × t)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
