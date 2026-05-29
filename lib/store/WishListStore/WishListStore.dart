import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../utils/constant.dart';
import '../../utils/Extensions/Commons.dart';
import 'package:mobx/mobx.dart';

import '../../model/DashboardResponse.dart';
import '../../utils/Extensions/Widget_extensions.dart';
import '../../utils/Extensions/shared_pref.dart';
part 'WishListStore.g.dart';

class WishListStore = _WishListStore with _$WishListStore;

abstract class _WishListStore with Store {

  @observable
  List<Book> wishList = ObservableList<Book>();

  @observable
  bool isNetworkAvailable = false;

  @action
  Future<void> addToWishList(Book data) async {
    if (wishList.any((element) => element.id == data.id)) {
      wishList.removeWhere((element) => element.id == data.id);
      toast("Removed");
    } else {
      wishList.add(data);
      toast("Added");
    }
    storeWishlistData();
  }

  @action
  void setConnectionState(ConnectivityResult val) {
    isNetworkAvailable = val != ConnectivityResult.none;
  }

  bool isItemInWishlist(int id1) {
    return wishList.any((element) => element.id == id1.toString());
  }

  @action
  Future<void> storeWishlistData() async {
    if (wishList.isNotEmpty) {
      await setValue(WISHLIST_ITEM_LIST, jsonEncode(wishList));
      log(getStringAsync(WISHLIST_ITEM_LIST));
    } else {
      await setValue(WISHLIST_ITEM_LIST, '');
    }
  }

  @action
  void addAllWishListItem(List<Book> productList) {
    wishList.addAll(productList);
  }

  @action
  Future<void> clearWishlist() async {
    wishList.clear();
    storeWishlistData();
  }
}
