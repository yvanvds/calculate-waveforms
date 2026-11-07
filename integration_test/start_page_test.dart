import 'package:calculate_waveforms/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('De echte app opent de startpagina en werkruimte', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();
    expect(find.text('Rekenen met waveforms'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Het experiment is in opbouw.'),
      200,
    );
    expect(find.text('Jouw golfexperiment'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
