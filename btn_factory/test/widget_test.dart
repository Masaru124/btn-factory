import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:btn_factory/core/storage/secure_storage.dart';
import 'package:btn_factory/main.dart';

class DelayedInMemorySecureStorage extends InMemorySecureStorage {
  @override
  Future<String?> read(String key) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return super.read(key);
  }
}

void main() {
  testWidgets('boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secureStorageProvider.overrideWithValue(DelayedInMemorySecureStorage())],
        child: const ButtonFactoryApp(),
      ),
    );

    // Initial pump shows the loading splash screen
    await tester.pump();
    expect(find.text('Button Factory MES'), findsOneWidget);

    // Wait for the delayed future and animations to settle
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Sign in'), findsOneWidget);
  });
}

