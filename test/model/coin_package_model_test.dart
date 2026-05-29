import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_ebook/model/CoinPackageModel.dart';

void main() {
  group('CoinPackage', () {
    group('fromJson', () {
      test('tüm alanlar dolu map ile doğru parse eder', () {
        final json = {
          'id': 1,
          'sku': 'coins_100',
          'coin_amount': 100,
          'title': '100 Jeton',
          'sort_order': 2,
          'currency': 'TRY',
          'display_price': '19,99 TL',
        };
        final p = CoinPackage.fromJson(json);
        expect(p.id, 1);
        expect(p.sku, 'coins_100');
        expect(p.coinAmount, 100);
        expect(p.title, '100 Jeton');
        expect(p.sortOrder, 2);
        expect(p.currency, 'TRY');
        expect(p.displayPrice, '19,99 TL');
      });

      test('string id ve coin_amount ile parse eder', () {
        final json = {
          'id': '5',
          'sku': 'coins_500',
          'coin_amount': '500',
          'title': '500 Jeton',
          'sort_order': '1',
        };
        final p = CoinPackage.fromJson(json);
        expect(p.id, 5);
        expect(p.coinAmount, 500);
        expect(p.sortOrder, 1);
      });

      test('eksik alanlar null olur', () {
        final json = <String, dynamic>{'sku': 'only_sku'};
        final p = CoinPackage.fromJson(json);
        expect(p.id, isNull);
        expect(p.sku, 'only_sku');
        expect(p.coinAmount, isNull);
        expect(p.title, isNull);
        expect(p.sortOrder, isNull);
        expect(p.currency, isNull);
        expect(p.displayPrice, isNull);
      });

      test('boş map ile çökmez', () {
        final p = CoinPackage.fromJson({});
        expect(p.id, isNull);
        expect(p.sku, isNull);
        expect(p.coinAmount, isNull);
      });
    });

    group('toJson', () {
      test('round-trip: fromJson(toJson()) aynı değerleri verir', () {
        final json = {
          'id': 2,
          'sku': 'coins_200',
          'coin_amount': 200,
          'title': '200 Jeton',
          'sort_order': 1,
          'currency': 'USD',
          'display_price': '\$2.99',
        };
        final p = CoinPackage.fromJson(json);
        final out = p.toJson();
        expect(out['id'], 2);
        expect(out['sku'], 'coins_200');
        expect(out['coin_amount'], 200);
        expect(out['title'], '200 Jeton');
        expect(out['sort_order'], 1);
        expect(out['currency'], 'USD');
        expect(out['display_price'], '\$2.99');
      });

      test('null alanlar da toJson içinde yer alır', () {
        final p = CoinPackage(sku: 'x', coinAmount: 10);
        final out = p.toJson();
        expect(out['id'], isNull);
        expect(out['sku'], 'x');
        expect(out['coin_amount'], 10);
      });
    });
  });
}
