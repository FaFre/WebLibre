import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/autostart_chip.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/profile_subtitle.dart';

void main() {
  testWidgets('autostart marker does not crowd out the type label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            // Deliberately narrow: the marker used to share the label's line,
            // which ellipsized "Onion routing" away on tiles this size.
            child: SizedBox(
              width: 180,
              child: ProfileSubtitle(
                typeLabel: 'Onion routing',
                latency: null,
                autostart: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Onion routing'), findsOneWidget);
    expect(find.text('Autostart'), findsOneWidget);

    final label = tester.renderObject<RenderBox>(find.text('Onion routing'));
    expect(label.size.width, greaterThan(0));

    // The marker sits below the label, flush with its left edge.
    final labelOffset = tester.getTopLeft(find.text('Onion routing'));
    final chipOffset = tester.getTopLeft(find.byType(AutostartChip));
    expect(chipOffset.dy, greaterThan(labelOffset.dy));
    expect(chipOffset.dx, closeTo(labelOffset.dx, 0.5));
  });

  testWidgets('renders the bare label when nothing is flagged', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSubtitle(typeLabel: 'Onion routing', latency: null),
        ),
      ),
    );

    expect(find.text('Onion routing'), findsOneWidget);
    expect(find.text('Autostart'), findsNothing);
  });
}
