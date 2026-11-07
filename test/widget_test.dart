import 'package:calculate_waveforms/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Startpagina toont uitleg en toekomstige werkruimte op mobiel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(WaveformsApp(tokens: await DesignTokens.load()));
    await tester.pumpAndSettle();
    expect(find.text('Rekenen met waveforms'), findsOneWidget);
    expect(
      find.textContaining('Bekijk, beluister en combineer'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('W1 · Sinusgolf'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('experiment')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
