import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_locations_tab.dart';

void main() {
  const primaryLocation = CustomerLocation(
    id: 'loc-1',
    customerId: 'cust-1',
    label: 'Gudang Utama',
    addressLine: 'Jl. Sunset Road No. 88, Kuta',
    village: 'Seminyak',
    district: 'Kuta',
    regency: 'Badung',
    province: 'Bali',
    areaSize: 250,
    latitude: -8.6913,
    longitude: 115.1682,
    isPrimary: true,
  );

  const secondaryLocation = CustomerLocation(
    id: 'loc-2',
    customerId: 'cust-1',
    label: 'Outlet Renon',
    addressLine: 'Jl. Raya Puputan No. 12, Renon',
    village: 'Renon',
    district: 'Denpasar Selatan',
    regency: 'Denpasar',
    province: 'Bali',
    isPrimary: false,
  );

  group('CustomerLocationsTab', () {
    testWidgets('renders empty placeholder when locations list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomerLocationsTab(locations: [], customerId: 'cust-1'),
          ),
        ),
      );

      expect(
        find.text('Belum ada lokasi titik servis terdaftar'),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders customer locations properly (label, address, primary badge)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomerLocationsTab(
                locations: [primaryLocation, secondaryLocation],
                customerId: 'cust-1',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Location 1 checks
        expect(find.text('Gudang Utama'), findsOneWidget);
        expect(find.text('Jl. Sunset Road No. 88, Kuta'), findsOneWidget);
        expect(find.text('Utama'), findsOneWidget);
        expect(
          find.text('Kecamatan: Kuta', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.text('Kab/Kota: Badung', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.text('Provinsi: Bali', findRichText: true),
          findsNWidgets(2),
        );

        // Location 2 checks
        expect(find.text('Outlet Renon'), findsOneWidget);
        expect(find.text('Jl. Raya Puputan No. 12, Renon'), findsOneWidget);
        expect(
          find.text('Kecamatan: Denpasar Selatan', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.text('Kab/Kota: Denpasar', findRichText: true),
          findsOneWidget,
        );

        // Primary badge should only appear once (for primaryLocation)
        expect(find.text('Utama'), findsOneWidget);
      },
    );

    testWidgets(
      'explicitly does NOT render "Penilaian Risiko (SRA)" button or icon',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomerLocationsTab(
                locations: [primaryLocation, secondaryLocation],
                customerId: 'cust-1',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // SRA button text and security icon must not exist
        expect(find.text('Penilaian Risiko (SRA)'), findsNothing);
        expect(find.byIcon(Icons.security_outlined), findsNothing);
      },
    );
  });
}
