import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:japanese_learning_mobile/app/mobile_app.dart';

void main() {
  testWidgets('app builds', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MobileApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Nihongo Study'), findsOneWidget);
    expect(find.text('记住密码'), findsOneWidget);
  });
}
