import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_6/main.dart';

void main() {
  testWidgets('shows student record creation interface', (tester) async {
    await tester.pumpWidget(const StudentApp());
    expect(find.text('Student Records'), findsOneWidget);
    expect(find.text('Add student'), findsOneWidget);
    expect(find.text('Student name'), findsOneWidget);
    expect(find.text('Course / class'), findsOneWidget);
    expect(find.text('Local SQLite database'), findsOneWidget);
  });
}
