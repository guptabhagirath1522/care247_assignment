import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:care247_assignment/state/theme_state.dart';
import 'package:care247_assignment/widgets/theme_toggle_button.dart';

void main() {
  group('ThemeState', () {
    test('defaults to ThemeMode.system', () {
      final state = ThemeState();
      expect(state.themeMode, ThemeMode.system);
    });

    test('initializes with custom mode', () {
      final state = ThemeState(initialMode: ThemeMode.dark);
      expect(state.themeMode, ThemeMode.dark);
    });

    test('updates theme mode and notifies listeners', () {
      final state = ThemeState();
      var notified = false;
      state.addListener(() => notified = true);

      state.setThemeMode(ThemeMode.dark);

      expect(state.themeMode, ThemeMode.dark);
      expect(notified, isTrue);
    });

    test('does not notify if setting same mode', () {
      final state = ThemeState(initialMode: ThemeMode.dark);
      var notified = false;
      state.addListener(() => notified = true);

      state.setThemeMode(ThemeMode.dark);

      expect(notified, isFalse);
    });
  });

  group('ThemeToggleButton Widget', () {
    Widget buildTestWidget(ThemeState themeState) {
      return ChangeNotifierProvider<ThemeState>.value(
        value: themeState,
        child: MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [ThemeToggleButton()])),
        ),
      );
    }

    testWidgets('renders toggle button', (WidgetTester tester) async {
      final state = ThemeState(initialMode: ThemeMode.light);

      await tester.pumpWidget(buildTestWidget(state));

      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });

    testWidgets('toggles from light to dark on tap', (
      WidgetTester tester,
    ) async {
      final state = ThemeState(initialMode: ThemeMode.light);

      await tester.pumpWidget(buildTestWidget(state));
      await tester.tap(find.byType(ThemeToggleButton));
      await tester.pumpAndSettle();

      expect(state.themeMode, ThemeMode.dark);
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    });

    testWidgets('toggles from dark to light on tap', (
      WidgetTester tester,
    ) async {
      final state = ThemeState(initialMode: ThemeMode.dark);

      await tester.pumpWidget(buildTestWidget(state));
      await tester.tap(find.byType(ThemeToggleButton));
      await tester.pumpAndSettle();

      expect(state.themeMode, ThemeMode.light);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });
  });
}
