part of 'quick_order_view.dart';

class QuickOrderViewNotifier extends ManageOrderNotifierBase {
  QuickOrderViewNotifier(super.ref) : super(cartProvider: ref.read(quickOrderCartProvider)) {
    initializeEventListener();
  }

  //------------------------Event Managers------------------------------//
  late EventSub<TableAE> _tableEventSub;
  late EventSub<StaffAE> _staffEventSub;
  late EventSub<PartyAE> _partyEventSub;
  void initializeEventListener() {
    _tableEventSub = GlobalEventManager.I.on<TableDeletedAE>().listen((event) {
      if (event.id == dropdownValues['table_id']) {
        dropdownValues['table_id'] = null;
      }
    });

    _staffEventSub = GlobalEventManager.I.on<StaffDeletedAE>().listen((event) {
      if (event.id == dropdownValues['waiter_id']) {
        dropdownValues['waiter_id'] = null;
      }
    });

    _partyEventSub = GlobalEventManager.I.on<PartyDeletedAE>().listen((event) {
      if (event.id == dropdownValues['customer_id']) {
        dropdownValues['customer_id'] = null;
        dropdownValues['delivery_address_id'] = null;
      }
    });
  }

  void disposeEventListeners() {
    _tableEventSub.cancel();
    _staffEventSub.cancel();
    _partyEventSub.cancel();
  }
  //------------------------Event Managers------------------------------//

  @override
  void dispose() {
    disposeEventListeners();
    super.dispose();
  }
}

final quickOrderViewProvider = ManageOrderViewNotifier(
  QuickOrderViewNotifier.new,
);
