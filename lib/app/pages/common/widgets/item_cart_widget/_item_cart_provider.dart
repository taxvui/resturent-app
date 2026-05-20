part of 'item_cart_widget.dart';

abstract class ItemCartNotifierBase extends ChangeNotifier with PaginatedControllerMixin<PItem> {
  ItemCartNotifierBase(this.ref) : repo = ref.read(itemsRepoProvider) {
    initPaging();
  }

  final Ref ref;
  final ItemsRepository repo;

  //---------------------Item  Filtering---------------------//
  late final searchController = TextEditingController();
  final filters = <ItemFilterType, dynamic>{};
  int get filterCount {
    return filters.entries.where((element) => element.value != null).length;
  }

  void handleFilter(Map<ItemFilterType, dynamic> newFilters) {
    if (mapEquals(newFilters, filters)) return;

    filters
      ..clear()
      ..addAll(newFilters);
    pagingController.refresh();
    notifyListeners();
  }
  //---------------------Item  Filtering---------------------//

  //---------------------Cart Items---------------------//
  final List<ItemCartModel> cartItems = [];
  CartAmountOverview get cartAmountOverview {
    final _totalAmount = cartItems.fold<num>(
      0,
      (p, eV) => p + eV.totalPrice,
    );
    final _totalQuantity = cartItems.fold<int>(
      0,
      (p, eV) => p + eV.cartQuantity,
    );

    return (totalAmount: _totalAmount, totalQuantity: _totalQuantity);
  }

  void handleCartItem(ItemCartModel item) {
    if (item.cartQuantity <= 0) {
      cartItems.removeWhere((element) => element.itemId == item.itemId);
    } else {
      final _itemIndex = cartItems.indexWhere(
        (element) => element.itemId == item.itemId,
      );

      _itemIndex < 0 ? cartItems.add(item) : cartItems[_itemIndex] = item;
    }

    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }
  //---------------------Cart Items---------------------//

  @override
  void pageDispose() {
    cartItems.clear();
    searchController.dispose();
    super.pageDispose();
  }
}

class ItemCartNotifierImpl extends ItemCartNotifierBase {
  ItemCartNotifierImpl(super.ref);

  @override
  Future<PaginatedListModel<PItem>> fetchData(int page) {
    return repo.getItemList(
      page: page,
      search: searchController.text,
      categoryId: filters[ItemFilterType.category],
      menuId: filters[ItemFilterType.menu],
      sortBy: filters[ItemFilterType.price],
    );
  }

  @override
  void dispose() {
    _apiEventSub?.cancel();
    super.dispose();
  }

  EventSub<ItemsApiEvent>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.item) {
        pagingController.refresh();
      }
    });
    super.initRefreshListener();
  }
}

abstract class ItemCartEvent {
  ItemCartEvent get clear;
}

enum QuickOrderCartEvent implements ItemCartEvent {
  clearCart;

  @override
  ItemCartEvent get clear => QuickOrderCartEvent.clearCart;
}

final quickOrderCartProvider = ChangeNotifierProvider<ItemCartNotifierBase>((ref) {
  final _provider = ItemCartNotifierImpl(ref);

  final _cartEventSub = GlobalEventManager.I.on<QuickOrderCartEvent>().listen((event) {
    if (event == QuickOrderCartEvent.clearCart) {
      _provider.clearCart();
    }
  });

  ref.onDispose(_cartEventSub.cancel);

  return _provider;
});

final editOrderCartProvider = ChangeNotifierProvider.autoDispose(
  ItemCartNotifierImpl.new,
);

final quotationCartProvider = ChangeNotifierProvider.autoDispose(
  ItemCartNotifierImpl.new,
);
