import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/models/memo_store.dart';
import 'package:tsukimisou/models/settings.dart';
import 'package:tsukimisou/uis/app.dart';
import 'package:tsukimisou/uis/app_state.dart';

import 'mocks.dart';

void main() {
  setUpAll(() {
    Settings.sharedPreferencesCreatorHook = () async {
      return MockSharedPreferencesWithCache();
    };
  });

  tearDownAll(() {
    Settings.sharedPreferencesCreatorHook = null;
  });

  testWidgets('App widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MemoStore>(create: (context) => MemoStore()),
          ChangeNotifierProvider<AppState>(create: (context) => AppState()),
          ChangeNotifierProvider<Settings>(create: (context) => Settings()),
        ],
        child: const App(),
      ),
    );
    expect(find.text('Tsukimisou'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  });
}
