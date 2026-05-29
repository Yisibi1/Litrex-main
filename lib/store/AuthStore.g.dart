// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AuthStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStore, Store {
  Computed<bool>? _$isPremiumUserComputed;

  @override
  bool get isPremiumUser =>
      (_$isPremiumUserComputed ??= Computed<bool>(() => super.isPremiumUser,
              name: '_AuthStore.isPremiumUser'))
          .value;

  late final _$isLoggedInAtom =
      Atom(name: '_AuthStore.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AuthStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$currentUserAtom =
      Atom(name: '_AuthStore.currentUser', context: context);

  @override
  UserModel? get currentUser {
    _$currentUserAtom.reportRead();
    return super.currentUser;
  }

  @override
  set currentUser(UserModel? value) {
    _$currentUserAtom.reportWrite(value, super.currentUser, () {
      super.currentUser = value;
    });
  }

  late final _$authTokenAtom =
      Atom(name: '_AuthStore.authToken', context: context);

  @override
  String? get authToken {
    _$authTokenAtom.reportRead();
    return super.authToken;
  }

  @override
  set authToken(String? value) {
    _$authTokenAtom.reportWrite(value, super.authToken, () {
      super.authToken = value;
    });
  }

  late final _$coinsAtom = Atom(name: '_AuthStore.coins', context: context);

  @override
  int get coins {
    _$coinsAtom.reportRead();
    return super.coins;
  }

  @override
  set coins(int value) {
    _$coinsAtom.reportWrite(value, super.coins, () {
      super.coins = value;
    });
  }

  late final _$setLoggedInAsyncAction =
      AsyncAction('_AuthStore.setLoggedIn', context: context);

  @override
  Future<void> setLoggedIn(bool val) {
    return _$setLoggedInAsyncAction.run(() => super.setLoggedIn(val));
  }

  late final _$setUserAsyncAction =
      AsyncAction('_AuthStore.setUser', context: context);

  @override
  Future<void> setUser(UserModel? user) {
    return _$setUserAsyncAction.run(() => super.setUser(user));
  }

  late final _$setAuthTokenAsyncAction =
      AsyncAction('_AuthStore.setAuthToken', context: context);

  @override
  Future<void> setAuthToken(String? token) {
    return _$setAuthTokenAsyncAction.run(() => super.setAuthToken(token));
  }

  late final _$loadUserFromPrefsAsyncAction =
      AsyncAction('_AuthStore.loadUserFromPrefs', context: context);

  @override
  Future<void> loadUserFromPrefs() {
    return _$loadUserFromPrefsAsyncAction.run(() => super.loadUserFromPrefs());
  }

  late final _$logoutAsyncAction =
      AsyncAction('_AuthStore.logout', context: context);

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$forceLogoutAsyncAction =
      AsyncAction('_AuthStore.forceLogout', context: context);

  @override
  Future<void> forceLogout() {
    return _$forceLogoutAsyncAction.run(() => super.forceLogout());
  }

  late final _$_AuthStoreActionController =
      ActionController(name: '_AuthStore', context: context);

  @override
  void setLoading(bool val) {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.setLoading');
    try {
      return super.setLoading(val);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoggedIn: ${isLoggedIn},
isLoading: ${isLoading},
currentUser: ${currentUser},
authToken: ${authToken},
coins: ${coins},
isPremiumUser: ${isPremiumUser}
    ''';
  }
}
