import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_ebook/component/CoinBalanceComponent.dart';
import 'package:mighty_ebook/main.dart';

void main() {
  setUp(() {
    authStore.coins = 10;
  });

  testWidgets('CoinBalanceComponent mevcut jeton bakiyesini gösterir', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoinBalanceComponent(),
        ),
      ),
    );
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('CoinBalanceComponent tıklanabilir (InkWell) alan içerir', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoinBalanceComponent(),
        ),
      ),
    );
    expect(find.byType(InkWell), findsOneWidget);
  });

  testWidgets('onTapForTesting verildiğinde tıklanınca bu callback çağrılır', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoinBalanceComponent(
            onTapForTesting: () => tapped = true,
          ),
        ),
      ),
    );
    expect(tapped, false);
    await tester.tap(find.byType(CoinBalanceComponent));
    await tester.pump();
    expect(tapped, true);
  });

  testWidgets('bakiye değişince Observer güncel değeri gösterir', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoinBalanceComponent(),
        ),
      ),
    );
    expect(find.text('10'), findsOneWidget);
    authStore.coins = 25;
    await tester.pump();
    expect(find.text('25'), findsOneWidget);
  });
}
