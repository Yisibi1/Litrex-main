import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../network/AuthApis.dart';
import '../../main.dart';
import '../../utils/Extensions/Widget_extensions.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Extensions/Commons.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';

class PremiumScreen extends StatefulWidget {
  static String tag = '/PremiumScreen';

  const PremiumScreen({super.key});

  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> with SingleTickerProviderStateMixin {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = true;
  String? _selectedProductId; // Track selected plan

  // Google Play Console Product IDs
  // Google Play Console Product IDs
  final Set<String> _kIds = {'litrex_premium_monthly', 'litrex_premium_quarterly', 'android.test.purchased'};

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error
    });
    
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _isLoading = false;
      });
      return;
    }

    // Load products
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
    if (response.error != null) {
      // Handle error
    }
    
    if (mounted) {
      setState(() {
        _isAvailable = isAvailable;
        _products = response.productDetails;
        // Default select the second item (usually better value) or first
        if (_products.isNotEmpty) {
           _selectedProductId = _products.length > 1 ? _products[1].id : _products[0].id;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
      for (var purchaseDetails in purchaseDetailsList) {
        print("Purchase Update Status: ${purchaseDetails.status}");
        
        if (purchaseDetails.status == PurchaseStatus.pending) {
          toast("Ödeme bekleniyor...");
        } else if (purchaseDetails.status == PurchaseStatus.error) {
           print("Purchase Error Details: ${purchaseDetails.error}");
           toast("İşlem başarısız: ${purchaseDetails.error?.message}");
           setState(() => _isLoading = false);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
           
           if (authStore.authToken.validate().isEmpty) {
             toast("Doğrulama hatası: Oturum açılmamış.");
             setState(() => _isLoading = false);
             continue;
           }

           setState(() => _isLoading = true);
           String? error = await _verifyPurchase(purchaseDetails);
           setState(() => _isLoading = false);
           
           if (error == null) {
             toast("Premium aktif edildi! Keyfini çıkarın.");
             
             if (purchaseDetails.pendingCompletePurchase) {
               await _inAppPurchase.completePurchase(purchaseDetails);
             }
             
             finish(context);
           } else {
             toast("Doğrulama hatası: $error");
             // Hata durumunda completePurchase yapmıyoruz, böylece tekrar denenebilir.
           }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
           toast("İşlem iptal edildi.");
           setState(() => _isLoading = false);
        }
      }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    try {
      await _inAppPurchase.restorePurchases();
      toast("Abonelik geçmişi kontrol ediliyor...");
    } catch (e) {
      toast("Geri yükleme hatası: $e");
    } finally {
      // Stream listener results will handle the rest
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }
  
  Future<String?> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      String? purchaseToken = purchaseDetails.verificationData.serverVerificationData;
      
      print("Verifying purchase: ${purchaseDetails.productID}, Token: $purchaseToken");

      if (purchaseToken.isEmptyOrNull) {
        print("Bilinmeyen Doğrulama Hatası: serverVerificationData boş");
        return "Doğrulama verisi boş (Token null)";
      }

      // Backend'e doğrulama gönder
      final response = await updatePremiumStatus(
        purchaseToken: purchaseToken,
        productId: purchaseDetails.productID,
        orderId: purchaseDetails.purchaseID ?? '',
        purchaseTime: purchaseDetails.transactionDate ?? '',
      );
      
      if ((response.success ?? false)) {
        // Başarılı ise store'u güncelle. Response.user null olabilir, kontrol et.
        if (response.user != null) {
            await authStore.setUser(response.user!);
        } else {
            // Success ama user objesi dönmemişse profili tekrar çekelim
            try {
              final user = await getProfile();
              await authStore.setUser(user);
            } catch (error) {
              print("Profil güncellenirken hata oluştu: $error");
            }
        }
        return null; // Başarılı, hata yok
      }
      return response.message ?? "Sunucu doğrulama hatası: Bilinmeyen hata";
    } catch (e) {
      print("Premium Doğrulama Hatası: $e");
      return "Bağlantı hatası: $e";
    }
  }

  void _buyProduct(ProductDetails prod) {
    print("Initiating purchase for: ${prod.id}");
    toast("Ödeme başlatılıyor: ${prod.id}..."); // Debug toast
    
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    
    try {
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      print("buyNonConsumable called.");
    } catch (e) {
      print("Purchase Error: $e");
      toast("Hata: $e");
    }
  }

   void _handleMainButtonTap() {
    print("Button Tapped. Loading: $_isLoading, Available: $_isAvailable");
    if (_isLoading) {
      toast("Yükleniyor, lütfen bekleyin...");
      return;
    }
    if (!_isAvailable) {
      toast("Mağaza bağlantısı yok. Lütfen Google Play Store'a giriş yapın.");
      return;
    }
    
    if (_products.isEmpty) {
        // Retry loading or show message
        _initStoreInfo();
        toast("Ürünler yükleniyor, lütfen tekrar deneyin.");
        return;
    }

    // Default to first available if selection failed
    if (_selectedProductId == null && _products.isNotEmpty) {
        _selectedProductId = _products[0].id;
    }
    
    if (_selectedProductId != null) {
        ProductDetails prod;
        try {
           prod = _products.firstWhere((p) => p.id == _selectedProductId);
        } catch (e) {
           prod = _products[0];
        }
        _buyProduct(prod);
    } else {
         toast("Ürün seçilemedi.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A), // Deep Navy
                  Color(0xFF1E293B),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),
          
          // Ambient Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 100,
                    spreadRadius: 20
                  )
                ],
              ),
            ).cornerRadiusWithClipRRect(150).opacity(opacity: 0.6),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 20
                  )
                ],
              ),
            ).cornerRadiusWithClipRRect(125).opacity(opacity: 0.6),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. Header (Close button)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => finish(context),
                    icon: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                      child: Icon(Icons.close, color: Colors.white70, size: 20),
                    ),
                  ),
                ).paddingRight(16),

                Expanded(
                  child: AnimationLimiter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 600),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          // 3. Hero Icon & Title
                          Column(
                            children: [
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                                    boxShadow: [
                                      BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 40, spreadRadius: 5)
                                    ]
                                  ),
                                  child: Icon(Icons.diamond, size: 48, color: Colors.white),
                                ),
                              ),
                              24.height,
                              Text(
                                "Premium'a Yükselt",
                                style: boldTextStyle(size: 28, color: Colors.white, fontFamily: GoogleFonts.poppins().fontFamily),
                                textAlign: TextAlign.center,
                              ),
                              8.height,
                              Text(
                                "Tüm sınırları kaldır ve özgürce oku.",
                                style: secondaryTextStyle(color: Colors.white60, size: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          // 4. Compact Benefits
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCompactBenefit(Icons.do_not_disturb, "Reklamsız"),
                              _buildCompactBenefit(Ionicons.infinite_outline, "Sınırsız"),
                              _buildCompactBenefit(Ionicons.cloud_download_outline, "Çevrimdışı"),
                            ],
                          ).paddingSymmetric(horizontal: 16),

                          // 5. Plan Selection
                          Container(
                             margin: EdgeInsets.symmetric(horizontal: 16),
                             padding: EdgeInsets.all(4),
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.05),
                               borderRadius: radius(20),
                               border: Border.all(color: Colors.white10),
                             ),
                             child: _buildRealPlans(),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ),

                // 6. Bottom Action Area
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A).withOpacity(0.8),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       GestureDetector(
                         onTap: _handleMainButtonTap,
                         child: Container(
                           width: double.infinity,
                           padding: EdgeInsets.symmetric(vertical: 18),
                           decoration: BoxDecoration(
                             gradient: LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
                             borderRadius: radius(30),
                             boxShadow: [
                               BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, offset: Offset(0, 8))
                             ]
                           ),
                           child: Text(
                             "Hemen Başla",
                             style: boldTextStyle(color: Colors.white, size: 18),
                             textAlign: TextAlign.center,
                           ),
                         ),
                       ),
                       16.height,
                       Text(
                         "İstediğin zaman iptal edebilirsin.",
                         style: secondaryTextStyle(color: Colors.white38, size: 12),
                       ),
                       12.height,
                       TextButton(
                         onPressed: _isLoading ? null : _restorePurchases,
                         child: Text(
                           "Satın Alımları Geri Yükle",
                           style: secondaryTextStyle(color: Colors.amber.withOpacity(0.8), decoration: TextDecoration.underline),
                         ),
                       ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBenefit(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: radius(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        8.height,
        Text(label, style: boldTextStyle(color: Colors.white70, size: 12)),
      ],
    );
  }

  // --- Layout for REAL PRODUCTS ---
  Widget _buildRealPlans() {
    if (_products.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Ürünler yükleniyor veya bulunamadı.\nLütfen internet bağlantınızı kontrol edin.",
              style: secondaryTextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            16.height,
            if (!_isAvailable)
              Text("Google Play Hizmetleri kullanılamıyor.", style: primaryTextStyle(color: Colors.redAccent, size: 12))
          ],
        ),
      );
    }

    // Sort products by price (optional logic, usually monthly is cheaper total wise but we want to encourage annual/quarterly)
    // Logic: Identify Quarterly/Annual as "Best Value"
    
    // Mapping mechanism:
    // We expect IDs: 'premium_monthly' and 'premium_quarterly'
    ProductDetails? monthly;
    ProductDetails? quarterly;
    
    try {
       monthly = _products.firstWhere((p) => p.id.contains('monthly'));
    } catch (e) {
      // Fallback for testing
      try {
        monthly = _products.firstWhere((p) => p.id == 'android.test.purchased');
      } catch (e) {}
    }
    
    try {
       quarterly = _products.firstWhere((p) => p.id.contains('quarterly') || p.id.contains('3_months'));
    } catch (e) {}

    // Fallback if naming convention fails, just take first 2
    if (monthly == null && _products.isNotEmpty) monthly = _products[0];
    if (quarterly == null && _products.length > 1) quarterly = _products[1];

    if (monthly != null && quarterly != null) {
       return Row(
        children: [
          Expanded(child: _buildPlanOption(
             id: monthly.id,
             title: "Aylık",
             price: monthly.price,
             subContext: "/ay",
             isBest: false
          )),
          Expanded(child: _buildPlanOption(
             id: quarterly.id,
             title: "3 Aylık",
             price: quarterly.price,
             subContext: "/3 ay",
             isBest: true
          )),
        ],
      );
    } else if (monthly != null) {
       // Single plan available
       return _buildPlanOption(
         id: monthly.id,
         title: monthly.title,
         price: monthly.price,
         subContext: "",
         isBest: true
       );
    }
    
    return SizedBox();
  }

  Widget _buildPlanOption({
    required String id, 
    required String title, 
    required String price, 
    required String subContext,
    required bool isBest
  }) {
    // If nothing selected, select the 'Best' option by default
    if (_selectedProductId == null && isBest) {
        // We use Future.delayed to avoid setState during build
        Future.delayed(Duration.zero, () {
           if (mounted && _selectedProductId == null) setState(() => _selectedProductId = id);
        });
    }

    bool isSelected = _selectedProductId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductId = id;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.15) : Colors.transparent,
          borderRadius: radius(16),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent, 
            width: 2
          ),
        ),
        child: Column(
          children: [
            if (isBest) 
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber, borderRadius: radius(8)),
                child: Text("EN ÇOK TERCİH EDİLEN", style: boldTextStyle(size: 10, color: Colors.black)),
              )
            else
               // Placeholder for alignment
               SizedBox(height: 18),
            
            Text(title, style: secondaryTextStyle(color: isSelected ? Colors.white : Colors.white60, size: 14)),
            4.height,
            Text(price, style: boldTextStyle(color: Colors.white, size: 18)),
            if (subContext.isNotEmpty)
              Text(subContext, style: secondaryTextStyle(color: Colors.white38, size: 12)),
          
            12.height,
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.amber : Colors.white24,
              size: 20
            ) 
          ],
        ),
      ),
    );
  }
}
