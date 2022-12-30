import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/app.dart';
import 'package:tsukimisou/app_state.dart';
import 'package:tsukimisou/memo_store.dart';

void main() {
  testWidgets('App widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MemoStore>(create: (context) => MemoStore()),
          ChangeNotifierProvider<AppState>(create: (context) => AppState()),
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
