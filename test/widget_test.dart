import 'package:centrow_sales/app/app.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    getIt.reset();
    setupDi();
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('CentrowSalesApp smoke test renders login page with logo', (
    tester,
  ) async {
    await tester.pumpWidget(const CentrowSalesApp());
    await tester.pumpAndSettle();

    expect(find.text('Centrow Sales'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
  });
}
