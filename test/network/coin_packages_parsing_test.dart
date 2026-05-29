import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_ebook/network/RestApis.dart';

void main() {
  group('parseCoinPackagesResponse', () {
    test('List yanıtı ile paket listesi döner', () {
      final data = [
        {'id': 1, 'sku': 'coins_100', 'coin_amount': 100, 'title': '100 Jeton'},
        {'id': 2, 'sku': 'coins_500', 'coin_amount': 500, 'title': '500 Jeton'},
      ];
      final list = parseCoinPackagesResponse(data);
      expect(list.length, 2);
      expect(list[0].sku, 'coins_100');
      expect(list[0].coinAmount, 100);
      expect(list[1].sku, 'coins_500');
      expect(list[1].coinAmount, 500);
    });

    test('packages anahtarlı Map yanıtı ile paket listesi döner', () {
      final data = {
        'packages': [
          {'id': 1, 'sku': 'coins_100', 'coin_amount': 100},
        ],
      };
      final list = parseCoinPackagesResponse(data);
      expect(list.length, 1);
      expect(list[0].id, 1);
      expect(list[0].sku, 'coins_100');
      expect(list[0].coinAmount, 100);
    });

    test('boş List ile boş liste döner', () {
      expect(parseCoinPackagesResponse([]), isEmpty);
    });

    test('packages null veya yok ise boş liste döner', () {
      expect(parseCoinPackagesResponse({'other': 1}), isEmpty);
      expect(parseCoinPackagesResponse({'packages': null}), isEmpty);
    });

    test('geçersiz tip (string) ile boş liste döner', () {
      expect(parseCoinPackagesResponse('invalid'), isEmpty);
    });

    test('null ile boş liste döner', () {
      expect(parseCoinPackagesResponse(null), isEmpty);
    });

    test('List içinde string sayılar doğru parse edilir', () {
      final data = [
        {'id': '1', 'sku': 'c1', 'coin_amount': '50', 'sort_order': '0'},
      ];
      final list = parseCoinPackagesResponse(data);
      expect(list.length, 1);
      expect(list[0].id, 1);
      expect(list[0].coinAmount, 50);
      expect(list[0].sortOrder, 0);
    });
  });
}
