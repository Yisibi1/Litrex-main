import 'package:mobx/mobx.dart';
import '../model/UserModel.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/constant.dart';
import '../utils/OfflineReadingService.dart';

part 'AuthStore.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  bool isLoading = false;

  @observable
  UserModel? currentUser;

  @observable
  String? authToken;
  
  @observable
  int coins = 0;
  
  @computed
  bool get isPremiumUser => currentUser?.isPremium == 1;


  @action
  Future<void> setLoggedIn(bool val) async {
    isLoggedIn = val;
    await setValue(IS_LOGGED_IN, val);
  }

  @action
  void setLoading(bool val) => isLoading = val;

  @action
  Future<void> setUser(UserModel? user) async {
    currentUser = user;
    if (user != null) {
      await setValue(USER_ID, user.id ?? 0);
      await setValue(USER_NAME, user.name ?? '');
      await setValue(USER_EMAIL, user.email ?? '');
      await setValue(USER_PHONE, user.phone ?? '');
      await setValue(USER_AVATAR, user.avatar ?? '');
      await setValue(USER_BIO, user.bio ?? '');
      await setValue('IS_PREMIUM', user.isPremium ?? 0);
      await setValue('STATUS', user.status ?? 'active');
      await setValue('COINS', user.coins ?? 0);
      coins = user.coins ?? 0;

    }
  }

  @action
  Future<void> setAuthToken(String? token) async {
    authToken = token;
    if (token != null) {
      await setValue(AUTH_TOKEN, token);
    }
  }

  @action
  Future<void> loadUserFromPrefs() async {
    isLoggedIn = getBoolAsync(IS_LOGGED_IN);
    authToken = getStringAsync(AUTH_TOKEN);
    
    if (isLoggedIn) {
      currentUser = UserModel(
        id: getIntAsync(USER_ID),
        name: getStringAsync(USER_NAME),
        email: getStringAsync(USER_EMAIL),
        phone: getStringAsync(USER_PHONE),
        avatar: getStringAsync(USER_AVATAR),
        bio: getStringAsync(USER_BIO),
        isPremium: getIntAsync('IS_PREMIUM'),
        status: getStringAsync('STATUS', defaultValue: 'active'),
        coins: getIntAsync('COINS'),
      );
      coins = getIntAsync('COINS');
    }
  }

  @action
  Future<void> logout() async {
    isLoggedIn = false;
    currentUser = null;
    authToken = null;
    
    await setValue(IS_LOGGED_IN, false);
    await setValue(AUTH_TOKEN, '');
    await setValue(USER_ID, 0);
    await setValue(USER_NAME, '');
    await setValue(USER_EMAIL, '');
    await setValue(USER_PHONE, '');
    await setValue(USER_AVATAR, '');
    await setValue(USER_BIO, '');
    await setValue('IS_PREMIUM', 0);
    await setValue('STATUS', '');
    await setValue('COINS', 0);
    coins = 0;

  }

  @action
  Future<void> forceLogout() async {
    // İndirilen kitapları sil
    try {
      await OfflineReadingService().clearAllBooks();
    } catch (e) {
      print("Force logout error: $e");
    }
    
    await logout();
  }
}
