import 'package:flutter_test/flutter_test.dart';

import 'package:crud_projek/main.dart';

void main() {
  testWidgets('Menampilkan halaman login aplikasi reservasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReservationApp());

    expect(find.text('Login Reservasi Lapangan'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
