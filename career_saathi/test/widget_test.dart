import 'package:flutter_test/flutter_test.dart';

import 'package:career_saathi/main.dart';

void main() {
  testWidgets('CareerSaathi app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CareerSaathiApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue your CareerSaathi journey.'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}