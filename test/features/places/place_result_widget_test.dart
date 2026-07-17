import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/providers/settings_provider.dart';
import 'package:haogpt/widgets/place_result_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('empty results expose a retry without building map content',
      (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: MaterialApp(
          theme: HowAITheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PlaceResultWidget(
              places: const [],
              searchQuery: 'coffee nearby',
              onRetry: () => retryCount += 1,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.location_off), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    expect(retryCount, 1);
  });
}
