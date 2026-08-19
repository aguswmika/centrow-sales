import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/widgets/app_segmented_control.dart';

void main() {
  const items = [
    SegmentItem(label: 'Semua', value: 'all'),
    SegmentItem(label: 'Villa', value: 'villa'),
    SegmentItem(label: 'Hotel', value: 'hotel'),
    SegmentItem(label: 'Resto', value: 'resto'),
  ];

  testWidgets('AppSegmentedControl renders items and triggers onValueChanged', (
    tester,
  ) async {
    String selected = 'all';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 400,
                child: AppSegmentedControl<String>(
                  items: items,
                  selectedValue: selected,
                  onValueChanged: (val) {
                    setState(() => selected = val);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Villa'), findsOneWidget);
    expect(find.text('Hotel'), findsOneWidget);
    expect(find.text('Resto'), findsOneWidget);
    expect(find.byType(AnimatedPositioned), findsOneWidget);

    // Tap Villa
    await tester.tap(find.text('Villa'));
    await tester.pumpAndSettle();

    expect(selected, 'villa');

    // Tap Hotel
    await tester.tap(find.text('Hotel'));
    await tester.pumpAndSettle();

    expect(selected, 'hotel');
  });
}
