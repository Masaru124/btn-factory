import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:btn_factory/core/storage/secure_storage.dart';
import 'package:btn_factory/main.dart';

void main() {
  testWidgets('boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secureStorageProvider.overrideWithValue(InMemorySecureStorage())],
        child: const ButtonFactoryApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Button Factory MES'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
  });
}
