import 'package:centrow_sales/shared/widgets/app_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppSegmentedControl renders fixed-width items and handles tap', (
    tester,
  ) async {
    String selected = 'all';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: StatefulBuilder(
              builder: (context, setState) {
                return AppSegmentedControl<String>(
                  items: const [
                    SegmentItem<String>(label: 'Semua', value: 'all'),
                    SegmentItem<String>(label: 'Draf', value: 'draft'),
                    SegmentItem<String>(label: 'Aktif', value: 'active'),
                  ],
                  selectedValue: selected,
                  onValueChanged: (val) {
                    setState(() {
                      selected = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Draf'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);

    await tester.tap(find.text('Draf'));
    await tester.pumpAndSettle();
    expect(selected, 'draft');

    await tester.tap(find.text('Aktif'));
    await tester.pumpAndSettle();
    expect(selected, 'active');
  });

  testWidgets(
    'AppSegmentedControl scrollable mode renders items in SingleChildScrollView and handles tap',
    (tester) async {
      int? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return AppSegmentedControl<int?>(
                    isScrollable: true,
                    items: const [
                      SegmentItem<int?>(label: 'Semua', value: null),
                      SegmentItem<int?>(label: 'Draf', value: 1),
                      SegmentItem<int?>(label: 'Aktif', value: 2),
                      SegmentItem<int?>(label: 'Ditangguhkan', value: 3),
                      SegmentItem<int?>(label: 'Diterminasi', value: 5),
                      SegmentItem<int?>(label: 'Dibatalkan', value: 6),
                    ],
                    selectedValue: selected,
                    onValueChanged: (val) {
                      setState(() {
                        selected = val;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Draf'), findsOneWidget);
      expect(find.text('Ditangguhkan'), findsOneWidget);

      await tester.tap(find.text('Draf'));
      await tester.pumpAndSettle();
      expect(selected, 1);

      await tester.tap(find.text('Ditangguhkan'));
      await tester.pumpAndSettle();
      expect(selected, 3);
    },
  );
}
