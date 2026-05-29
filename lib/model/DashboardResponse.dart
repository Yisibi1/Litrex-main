class DashboardResponse {
  Appconfiguration? appconfiguration;
  Adsconfiguration? adsconfiguration;
  OnesignalConfiguration? onesignalConfiguration;
  Apiconfiguration? apiconfiguration;
  List<AppSlider>? slider;
  List<Book>? popularBook;
  List<Book>? featuredBook;
  List<Book>? latestBook;
  List<Category>? category;
  List<Author>? author;

  DashboardResponse(
      {this.appconfiguration,
        this.adsconfiguration,
        this.onesignalConfiguration,
        this.apiconfiguration,
        this.slider,
        this.popularBook,
        this.featuredBook,
        this.latestBook,
        this.category,
        this.author});

  DashboardResponse.fromJson(Map<String, dynamic> json) {
    appconfiguration = json['appconfiguration'] != null
        ? Appconfiguration.fromJson(json['appconfiguration'])
        : null;
    adsconfiguration = json['adsconfiguration'] != null
        ? Adsconfiguration.fromJson(json['adsconfiguration'])
        : null;
    onesignalConfiguration = json['onesignal_configuration'] != null
        ? OnesignalConfiguration.fromJson(json['onesignal_configuration'])
        : null;
    apiconfiguration = json['apiconfiguration'] != null
        ? Apiconfiguration.fromJson(json['apiconfiguration'])
        : null;
    if (json['slider'] != null) {
      slider = <AppSlider>[];
      json['slider'].forEach((v) {
        slider!.add(AppSlider.fromJson(v));
      });
    }
    if (json['popular_book'] != null) {
      popularBook = <Book>[];
      json['popular_book'].forEach((v) {
        popularBook!.add(Book.fromJson(v));
      });
    }
    if (json['featured_book'] != null) {
      featuredBook = <Book>[];
      json['featured_book'].forEach((v) {
        featuredBook!.add(Book.fromJson(v));
      });
    }
    if (json['latest_book'] != null) {
      latestBook = <Book>[];
      json['latest_book'].forEach((v) {
        latestBook!.add(Book.fromJson(v));
      });
    }
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(Category.fromJson(v));
      });
    }
    if (json['author'] != null) {
      author = <Author>[];
      json['author'].forEach((v) {
        author!.add(Author.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (appconfiguration != null) {
      data['appconfiguration'] = appconfiguration!.toJson();
    }
    if (adsconfiguration != null) {
      data['adsconfiguration'] = adsconfiguration!.toJson();
    }
    if (onesignalConfiguration != null) {
      data['onesignal_configuration'] = onesignalConfiguration!.toJson();
    }
    if (apiconfiguration != null) {
      data['apiconfiguration'] = apiconfiguration!.toJson();
    }
    if (slider != null) {
      data['slider'] = slider!.map((v) => v.toJson()).toList();
    }
    if (popularBook != null) {
      data['popular_book'] = popularBook!.map((v) => v.toJson()).toList();
    }
    if (featuredBook != null) {
      data['featured_book'] =
          featuredBook!.map((v) => v.toJson()).toList();
    }
    if (latestBook != null) {
      data['latest_book'] = latestBook!.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (author != null) {
      data['author'] = author!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Appconfiguration {
  String? facebook;
  String? instagram;
  String? twitter;
  String? whatsapp;
  String? privacyPolicy;
  String? termsCondition;
  String? contactUs;
  String? aboutUs;
  String? copyright;
  int? coinWelcomeBonus;
  int? coinUnlockDuration;
  int? adRewardCoins;
  int? pdfAdPageInterval;
  int? minAppVersionCode;
  String? playStoreUrl;

  Appconfiguration(
      {this.facebook,
        this.instagram,
        this.twitter,
        this.whatsapp,
        this.privacyPolicy,
        this.termsCondition,
        this.contactUs,
        this.aboutUs,
        this.copyright,
        this.coinWelcomeBonus,
        this.coinUnlockDuration,
        this.adRewardCoins,
        this.pdfAdPageInterval,
        this.minAppVersionCode,
        this.playStoreUrl});

  Appconfiguration.fromJson(Map<String, dynamic> json) {
    facebook = json['facebook'];
    instagram = json['instagram'];
    twitter = json['twitter'];
    whatsapp = json['whatsapp'];
    privacyPolicy = json['privacy_policy'];
    termsCondition = json['terms_condition'];
    contactUs = json['contact_us'];
    aboutUs = json['about_us'];
    copyright = json['copyright'];
    coinWelcomeBonus = json['coin_welcome_bonus'] is String ? int.tryParse(json['coin_welcome_bonus']) : json['coin_welcome_bonus'];
    coinUnlockDuration = json['coin_unlock_duration'] is String ? int.tryParse(json['coin_unlock_duration']) : json['coin_unlock_duration'];
    adRewardCoins = json['ad_reward_coins'] is String ? int.tryParse(json['ad_reward_coins']) : json['ad_reward_coins'];
    pdfAdPageInterval = json['pdf_ad_page_interval'] is String ? int.tryParse(json['pdf_ad_page_interval']) : json['pdf_ad_page_interval'];
    minAppVersionCode = json['min_app_version_code'] is String ? int.tryParse(json['min_app_version_code']) : json['min_app_version_code'];
    playStoreUrl = json['play_store_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['facebook'] = facebook;
    data['instagram'] = instagram;
    data['twitter'] = twitter;
    data['whatsapp'] = whatsapp;
    data['privacy_policy'] = privacyPolicy;
    data['terms_condition'] = termsCondition;
    data['contact_us'] = contactUs;
    data['about_us'] = aboutUs;
    data['copyright'] = copyright;
    data['coin_welcome_bonus'] = coinWelcomeBonus;
    data['coin_unlock_duration'] = coinUnlockDuration;
    data['ad_reward_coins'] = adRewardCoins;
    data['pdf_ad_page_interval'] = pdfAdPageInterval;
    data['min_app_version_code'] = minAppVersionCode;
    data['play_store_url'] = playStoreUrl;
    return data;
  }
}

class Adsconfiguration {
  String? adsType;
  String? admobBannerId;
  String? admobInterstitialId;
  String? admobBannerIdIos;
  String? admobInterstitialIdIos;
  String? admobNativeId;
  String? admobNativeIdIos;
  String? admobAdaptiveBannerId;
  String? admobAdaptiveBannerIdIos;
  String? admobRewardedId;
  String? admobRewardedIdIos;
  
  String? facebookBannerId;
  String? facebookInterstitialId;
  String? facebookBannerIdIos;
  String? facebookInterstitialIdIos;
  String? facebookNativeId;
  String? facebookNativeIdIos;
  String? facebookRewardedId;
  String? facebookRewardedIdIos;
  
  String? interstitialAdsInterval;
  String? bannerAdBookList;
  String? bannerAdCategoryList;
  String? bannerAdAuthorList;
  String? bannerAdAuthorDetail;
  String? bannerAdBookDetail;
  String? bannerAdBookSearch;
  String? interstitialAdBookList;
  String? interstitialAdCategoryList;
  String? interstitialAdBookDetail;
  String? interstitialAdAuthorList;
  String? interstitialAdAuthorDetail;

  Adsconfiguration(
      {this.adsType,
        this.admobBannerId,
        this.admobInterstitialId,
        this.admobBannerIdIos,
        this.admobInterstitialIdIos,
        this.admobNativeId,
        this.admobNativeIdIos,
        this.admobAdaptiveBannerId,
        this.admobAdaptiveBannerIdIos,
        this.admobRewardedId,
        this.admobRewardedIdIos,
        this.facebookBannerId,
        this.facebookInterstitialId,
        this.facebookBannerIdIos,
        this.facebookInterstitialIdIos,
        this.facebookNativeId,
        this.facebookNativeIdIos,
        this.facebookRewardedId,
        this.facebookRewardedIdIos,
        this.interstitialAdsInterval,
        this.bannerAdBookList,
        this.bannerAdCategoryList,
        this.bannerAdAuthorList,
        this.bannerAdAuthorDetail,
        this.bannerAdBookDetail,
        this.bannerAdBookSearch,
        this.interstitialAdBookList,
        this.interstitialAdCategoryList,
        this.interstitialAdBookDetail,
        this.interstitialAdAuthorList,
        this.interstitialAdAuthorDetail});

  Adsconfiguration.fromJson(Map<String, dynamic> json) {
    adsType = json['ads_type'];
    admobBannerId = json['admob_banner_id'];
    admobInterstitialId = json['admob_interstitial_id'];
    admobBannerIdIos = json['admob_banner_id_ios'];
    admobInterstitialIdIos = json['admob_interstitial_id_ios'];
    admobNativeId = json['admob_native_id'];
    admobNativeIdIos = json['admob_native_id_ios'];
    admobAdaptiveBannerId = json['admob_adaptive_banner_id'];
    admobAdaptiveBannerIdIos = json['admob_adaptive_banner_id_ios'];
    admobRewardedId = json['admob_rewarded_id'];
    admobRewardedIdIos = json['admob_rewarded_id_ios'];
    
    facebookBannerId = json['facebook_banner_id'];
    facebookInterstitialId = json['facebook_interstitial_id'];
    facebookBannerIdIos = json['facebook_banner_id_ios'];
    facebookInterstitialIdIos = json['facebook_interstitial_id_ios'];
    facebookNativeId = json['facebook_native_id'];
    facebookNativeIdIos = json['facebook_native_id_ios'];
    facebookRewardedId = json['facebook_rewarded_id'];
    facebookRewardedIdIos = json['facebook_rewarded_id_ios'];
    
    interstitialAdsInterval = json['interstitial_ads_interval'];
    bannerAdBookList = json['banner_ad_book_list'];
    bannerAdCategoryList = json['banner_ad_category_list'];
    bannerAdAuthorList = json['banner_ad_author_list'];
    bannerAdAuthorDetail = json['banner_ad_author_detail'];
    bannerAdBookDetail = json['banner_ad_book_detail'];
    bannerAdBookSearch = json['banner_ad_book_search'];
    interstitialAdBookList = json['interstitial_ad_book_list'];
    interstitialAdCategoryList = json['interstitial_ad_category_list'];
    interstitialAdBookDetail = json['interstitial_ad_book_detail'];
    interstitialAdAuthorList = json['interstitial_ad_author_list'];
    interstitialAdAuthorDetail = json['interstitial_ad_author_detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ads_type'] = adsType;
    data['admob_banner_id'] = admobBannerId;
    data['admob_interstitial_id'] = admobInterstitialId;
    data['admob_banner_id_ios'] = admobBannerIdIos;
    data['admob_interstitial_id_ios'] = admobInterstitialIdIos;
    data['admob_native_id'] = admobNativeId;
    data['admob_native_id_ios'] = admobNativeIdIos;
    data['admob_adaptive_banner_id'] = admobAdaptiveBannerId;
    data['admob_adaptive_banner_id_ios'] = admobAdaptiveBannerIdIos;
    data['admob_rewarded_id'] = admobRewardedId;
    data['admob_rewarded_id_ios'] = admobRewardedIdIos;
    
    data['facebook_banner_id'] = facebookBannerId;
    data['facebook_interstitial_id'] = facebookInterstitialId;
    data['facebook_banner_id_ios'] = facebookBannerIdIos;
    data['facebook_interstitial_id_ios'] = facebookInterstitialIdIos;
    data['facebook_native_id'] = facebookNativeId;
    data['facebook_native_id_ios'] = facebookNativeIdIos;
    data['facebook_rewarded_id'] = facebookRewardedId;
    data['facebook_rewarded_id_ios'] = facebookRewardedIdIos;
    
    data['interstitial_ads_interval'] = interstitialAdsInterval;
    data['banner_ad_book_list'] = bannerAdBookList;
    data['banner_ad_category_list'] = bannerAdCategoryList;
    data['banner_ad_author_list'] = bannerAdAuthorList;
    data['banner_ad_author_detail'] = bannerAdAuthorDetail;
    data['banner_ad_book_detail'] = bannerAdBookDetail;
    data['banner_ad_book_search'] = bannerAdBookSearch;
    data['interstitial_ad_book_list'] = interstitialAdBookList;
    data['interstitial_ad_category_list'] = interstitialAdCategoryList;
    data['interstitial_ad_book_detail'] = interstitialAdBookDetail;
    data['interstitial_ad_author_list'] = interstitialAdAuthorList;
    data['interstitial_ad_author_detail'] = interstitialAdAuthorDetail;
    return data;
  }
}

class OnesignalConfiguration {
  String? appId;
  String? restApiKey;

  OnesignalConfiguration({this.appId, this.restApiKey});

  OnesignalConfiguration.fromJson(Map<String, dynamic> json) {
    appId = json['app_id'];
    restApiKey = json['rest_api_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['app_id'] = appId;
    data['rest_api_key'] = restApiKey;
    return data;
  }
}

class Apiconfiguration {
  String? limit;
  String? categoryOrder;
  String? categoryOrderby;
  String? bookOrder;
  String? bookOrderby;
  String? authorOrder;
  String? authorOrderby;

  Apiconfiguration(
      {this.limit,
        this.categoryOrder,
        this.categoryOrderby,
        this.bookOrder,
        this.bookOrderby,
        this.authorOrder,
        this.authorOrderby});

  Apiconfiguration.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    categoryOrder = json['category_order'];
    categoryOrderby = json['category_orderby'];
    bookOrder = json['book_order'];
    bookOrderby = json['book_orderby'];
    authorOrder = json['author_order'];
    authorOrderby = json['author_orderby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['limit'] = limit;
    data['category_order'] = categoryOrder;
    data['category_orderby'] = categoryOrderby;
    data['book_order'] = bookOrder;
    data['book_orderby'] = bookOrderby;
    data['author_order'] = authorOrder;
    data['author_orderby'] = authorOrderby;
    return data;
  }
}

class AppSlider {
  String? id;
  String? title;
  String? url;
  String? image;
  String? status;
  String? imageUrl;

  AppSlider(
      {this.id, this.title, this.url, this.image, this.status, this.imageUrl});

  AppSlider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    status = json['status'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['url'] = url;
    data['image'] = image;
    data['status'] = status;
    data['image_url'] = imageUrl;
    return data;
  }
}

class Category {
  String? id;
  String? name;
  String? logo;
  List<Book>? book;

  Category({this.id, this.name, this.logo, this.book});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    if (json['book'] != null) {
      book = <Book>[];
      json['book'].forEach((v) {
        book!.add(Book.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    if (book != null) {
      data['book'] = book!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Author {
  String? id;
  String? name;
  String? description;
  String? designation;
  String? image;
  String? youtubeUrl;
  String? facebookUrl;
  String? instagramUrl;
  String? twitterUrl;
  String? websiteUrl;
  String? status;
  String? createdAt;
  String? imageUrl;

  Author(
      {this.id,
        this.name,
        this.description,
        this.designation,
        this.image,
        this.youtubeUrl,
        this.facebookUrl,
        this.instagramUrl,
        this.twitterUrl,
        this.websiteUrl,
        this.status,
        this.createdAt,
        this.imageUrl});

  Author.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    designation = json['designation'];
    image = json['image'];
    youtubeUrl = json['youtube_url'];
    facebookUrl = json['facebook_url'];
    instagramUrl = json['instagram_url'];
    twitterUrl = json['twitter_url'];
    websiteUrl = json['website_url'];
    status = json['status'];
    createdAt = json['created_at'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['designation'] = designation;
    data['image'] = image;
    data['youtube_url'] = youtubeUrl;
    data['facebook_url'] = facebookUrl;
    data['instagram_url'] = instagramUrl;
    data['twitter_url'] = twitterUrl;
    data['website_url'] = websiteUrl;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['image_url'] = imageUrl;
    return data;
  }
}

class Book {
  String? id;
  String? name;
  String? categoryId;
  String? authorId;
  String? type;
  String? file;
  String? logo;
  String? description;
  String? url;
  String? isPopular;
  String? isFeatured;
  String? createdAt;
  String? categoryName;
  String? authorName;
  String? authorImage;
  String? isPremium;
  int? coinPrice;
  bool? isUnlocked;
  String? unlockExpiresAt;
  // Tracks which addon this book came from (null = built-in library)
  String? addonSource;

  Book(
      {this.id,
        this.name,
        this.categoryId,
        this.authorId,
        this.type,
        this.file,
        this.logo,
        this.description,
        this.url,
        this.isPopular,
        this.isFeatured,
        this.createdAt,
        this.categoryName,
        this.authorName,
        this.authorImage,
        this.isPremium,
        this.coinPrice,
        this.isUnlocked,
        this.unlockExpiresAt,
        this.addonSource});

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    categoryId = json['category_id'];
    authorId = json['author_id'];
    type = json['type'];
    file = json['file'];
    logo = json['logo'];
    description = json['description'];
    url = json['url'];
    isPopular = json['is_popular'];
    isFeatured = json['is_featured'];
    createdAt = json['created_at'];
    categoryName = json['category_name'];
    authorName = json['author_name'];
    authorImage = json['author_image'];
    isPremium = json['is_premium']?.toString();
    coinPrice = json['coin_price'] is String ? int.tryParse(json['coin_price']) : json['coin_price'];
    isUnlocked = (json['is_unlocked'] == 1 || json['is_unlocked'] == '1' || json['is_unlocked'] == true || json['is_unlocked'] == 'true');
    unlockExpiresAt = json['unlock_expires_at'];
    addonSource = json['addon_source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category_id'] = categoryId;
    data['author_id'] = authorId;
    data['type'] = type;
    data['file'] = file;
    data['logo'] = logo;
    data['description'] = description;
    data['url'] = url;
    data['is_popular'] = isPopular;
    data['is_featured'] = isFeatured;
    data['created_at'] = createdAt;
    data['category_name'] = categoryName;
    data['author_name'] = authorName;
    data['author_image'] = authorImage;
    data['is_premium'] = isPremium;
    data['coin_price'] = coinPrice;
    data['is_unlocked'] = isUnlocked;
    data['unlock_expires_at'] = unlockExpiresAt;
    data['addon_source'] = addonSource;
    return data;
  }
}