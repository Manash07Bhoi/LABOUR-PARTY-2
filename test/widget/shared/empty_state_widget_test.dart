import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/shared/widgets/empty_state.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('renders correctly with default icon', (WidgetTester tester) async {
      bool buttonPressed = false;
      const message = 'No items found';
      const ctaText = 'Add Item';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: message,
              ctaText: ctaText,
              onCtaPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify default icon is rendered
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);

      // Verify text is rendered
      expect(find.text(message), findsOneWidget);
      expect(find.text(ctaText), findsOneWidget);

      // Verify button tap
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(buttonPressed, isTrue);
    });

    testWidgets('renders correctly with custom icon', (WidgetTester tester) async {
      const message = 'No history available';
      const ctaText = 'Refresh';
      const customIcon = Icons.history;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: message,
              ctaText: ctaText,
              icon: customIcon,
              onCtaPressed: () {},
            ),
          ),
        ),
      );

      // Verify custom icon is rendered
      expect(find.byIcon(customIcon), findsOneWidget);

      // Verify text is rendered
      expect(find.text(message), findsOneWidget);
      expect(find.text(ctaText), findsOneWidget);

      // Verify default icon is not rendered
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });
  });
}
