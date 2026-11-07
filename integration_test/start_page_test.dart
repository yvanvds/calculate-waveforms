import 'package:calculate_waveforms/main.dart' as app;
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
    await tester.tap(find.byKey(const Key('add-wave')));
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
    expect(find.text('W1 = sin(2π × 220.5 × t)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
