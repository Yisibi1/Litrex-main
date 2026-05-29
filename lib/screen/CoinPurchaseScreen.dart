import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../main.dart';
import '../model/CoinPackageModel.dart';
import '../network/RestApis.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../utils/Extensions/shared_pref.dart';
/// Jeton satın alma ekranı.
/// Paketler admin panelden gelir (SKU, coin miktarı); fiyat Google Play'den çekilir.
class CoinPurchaseScreen extends StatefulWidget {
  static String tag = '/CoinPurchaseScreen';

  const CoinPurchaseScreen({super.key});

  @override
  State<CoinPurchaseScreen> createState() => _CoinPurchaseScreenState();
}

class _CoinPurchaseScreenState extends State<CoinPurchaseScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<CoinPackage> _packages = [];
  Map<String, ProductDetails> _productDetailsBySku = {};
  bool _isStoreAvailable = false;
  bool _isLoading = true;
  String? _purchasingSku;

  @override
  void initState() {
    super.initState();
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (e) => _log('Purchase stream error: $e'),
    );
    _loadPackagesAndProducts();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _log(String msg) {
    if (!mounted) return;
    debugPrint('[CoinPurchase] $msg');
  }

  Future<void> _loadPackagesAndProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final packages = await getCoinPackages();
      if (!mounted) return;
      if (packages.isEmpty) {
        setState(() {
          _packages = [];
          _isLoading = false;
          _isStoreAvailable = false;
        });
        return;
      }

      _isStoreAvailable = await _inAppPurchase.isAvailable();
      if (!_isStoreAvailable) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
        return;
      }

      final skuSet = packages.map((p) => p.sku!).where((s) => s.isNotEmpty).toSet();
      if (skuSet.isEmpty) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
        return;
      }

      final response = await _inAppPurchase.queryProductDetails(skuSet);
      if (!mounted) return;

      final Map<String, ProductDetails> bySku = {};
      for (final p in response.productDetails) {
        bySku[p.id] = p;
      }

      // Paketleri sort_order'a göre sırala
      packages.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

      setState(() {
        _packages = packages;
        _productDetailsBySku = bySku;
        _isLoading = false;
      });
    } catch (e) {
      _log('Load error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        toast('Paketler yüklenirken hata: $e');
      }
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final details in purchaseDetailsList) {
      _log('Purchase status: ${details.status} product=${details.productID}');

      if (details.status == PurchaseStatus.pending) {
        if (mounted) setState(() => _purchasingSku = details.productID);
        toast('Ödeme işleniyor...');
        continue;
      }

      if (details.status == PurchaseStatus.error) {
        if (mounted) setState(() => _purchasingSku = null);
        toast('Ödeme hatası: ${details.error?.message ?? "Bilinmeyen"}');
        continue;
      }

      if (details.status == PurchaseStatus.canceled) {
        if (mounted) setState(() => _purchasingSku = null);
        toast('İşlem iptal edildi.');
        continue;
      }

      if (details.status == PurchaseStatus.purchased || details.status == PurchaseStatus.restored) {
        if (authStore.authToken.validate().isEmpty) {
          toast('Oturum açmanız gerekiyor.');
          if (mounted) setState(() => _purchasingSku = null);
          continue;
        }

        final token = details.verificationData.serverVerificationData;
        if (token.isEmptyOrNull) {
          toast('Doğrulama verisi alınamadı.');
          if (mounted) setState(() => _purchasingSku = null);
          continue;
        }

        try {
          final res = await verifyCoinPurchase(
            purchaseToken: token,
            productId: details.productID,
            orderId: details.purchaseID ?? '',
            purchaseTime: details.transactionDate ?? '',
          );

          if (res['success'] == true && res['new_balance'] != null) {
            int newCoins = res['new_balance'] is int
                ? res['new_balance'] as int
                : int.tryParse(res['new_balance'].toString()) ?? authStore.coins;
                
            authStore.coins = newCoins;
            setValue('COINS', newCoins);
            if (authStore.currentUser != null) {
              authStore.currentUser!.coins = newCoins;
            }
            toast(res['message'] ?? 'Jetonlar hesabınıza eklendi.');
            if (details.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(details);
            }
          } else {
            toast(res['message'] ?? 'Doğrulama başarısız.');
          }
        } catch (e) {
          toast('Doğrulama hatası: $e');
        }

        if (mounted) setState(() => _purchasingSku = null);
      }
    }
  }

  void _buyPackage(CoinPackage package, ProductDetails? product) {
    if (product == null) {
      toast('Bu paket mağazada bulunamadı.');
      return;
    }
    if (_purchasingSku != null) {
      toast('Lütfen mevcut işlemin bitmesini bekleyin.');
      return;
    }

    setState(() => _purchasingSku = product.id);
    _inAppPurchase.buyConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? scaffoldColorDark : scaffoldColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text('Jeton Satın Al', style: boldTextStyle(size: 18, color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => finish(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mevcut bakiye
                  Observer(
                    builder: (_) => Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF5A623).withOpacity(0.2), Color(0xFFFF8C00).withOpacity(0.15)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: radius(16),
                        border: Border.all(color: Color(0xFFF5A623).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.monetization_on_rounded, size: 28, color: Color(0xFFF5A623)),
                          12.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mevcut bakiye', style: secondaryTextStyle(size: 12)),
                              4.height,
                              Text(
                                '${authStore.coins} Jeton',
                                style: boldTextStyle(size: 22, color: primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  24.height,

                  if (!_isStoreAvailable && _packages.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.orange),
                          8.width,
                          Expanded(
                            child: Text(
                              'Mağaza bağlantısı yok. Google Play girişi yapıp tekrar deneyin.',
                              style: secondaryTextStyle(size: 12, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Text('Paketler', style: boldTextStyle(size: 16)),
                  12.height,

                  if (_packages.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Satın alınabilir paket bulunamadı.',
                          style: secondaryTextStyle(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._packages.map((pkg) {
                      final product = pkg.sku != null ? _productDetailsBySku[pkg.sku] : null;
                      final price = product?.price ?? pkg.displayPrice ?? '—';
                      final isPurchasing = _purchasingSku == pkg.sku;
                      final canBuy = _isStoreAvailable && product != null && !isPurchasing;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: appStore.isDarkModeOn
                              ? Colors.white.withOpacity(0.06)
                              : Colors.white,
                          borderRadius: radius(16),
                          border: Border.all(
                            color: canBuy
                                ? Color(0xFFF5A623).withOpacity(0.4)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: canBuy ? () => _buyPackage(pkg, product) : null,
                            borderRadius: radius(16),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5A623).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(child: Icon(Icons.monetization_on_rounded, size: 28, color: Color(0xFFF5A623))),
                                  ),
                                  16.width,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pkg.title.validate().isNotEmpty
                                              ? pkg.title!
                                              : '${pkg.coinAmount ?? 0} Jeton',
                                          style: boldTextStyle(size: 15),
                                        ),
                                        4.height,
                                        Text(
                                          '${pkg.coinAmount ?? 0} jeton',
                                          style: secondaryTextStyle(size: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        price,
                                        style: boldTextStyle(size: 16, color: primaryColor),
                                      ),
                                      if (canBuy)
                                        isPurchasing
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: primaryColor,
                                                ),
                                              )
                                            : Text(
                                                'Satın al',
                                                style: secondaryTextStyle(size: 12, color: primaryColor),
                                              ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                  24.height,

                  // İade edilmez uyarısı
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: radius(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, size: 20, color: Colors.orange),
                        10.width,
                        Expanded(
                          child: Text(
                            'Satın alınan jetonlar kullanıldığında (kitap açma vb.) iade edilmez. Harcama öncesi lütfen tercihinizi kontrol edin.',
                            style: secondaryTextStyle(size: 12, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
