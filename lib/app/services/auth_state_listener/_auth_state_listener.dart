import '../../data/repository/repository.dart';
import '../../pages/common/widgets/widgets.dart' show quickOrderCartProvider;

class AuthStateListener extends BaseRepository {
  AuthStateListener(super.ref);

  final _normalProviders = [
    // User Providers
    modulesProvider,
    businessCategoriesProvider,
    subscriptionPlansProvider,

    // Dropdown Providers
    businessPaymentMethodDropdownProvider,
    expenseCategoryDropdownProvider,
    incomeCategoryDropdownProvider,
    taxDropdownProvider,
    taxListProvider,
    taxGroupProvider,
    customerDropdownProvider,
    supplierDropdownProvider,
    tableDropdownProvider,
    areasDropdownProvider,
    allStaffDropdownProvider,
    waiterDropdownProvider,

    // Item Providers
    itemsDropdownProvider,
    itemDetailsProvider,
    itemCategoryDropdownProvider,
    itemUnitDropdownProvider,
    itemMenuDropdownProvider,
    itemModifierGroupDropdownProvider,

    // HRM Providers
    employeeDropdownProvider,
    departmentDropdownProvider,
    designationDropdownProvider,
    leaveTypeDropdownProvider,
    shiftDropdownProvider,

    // Cart Providers
    quickOrderCartProvider,

    kitchenDropdownProvider,
    unassignedProductsProvider,

    partyDetailsProvider,
    orderCancelReasonListProvider,
  ];

  void initListener() {
    gEventListener.on<UserAuthEvent>().listen((event) {
      if (event == UserAuthEvent.signedIn) {
        for (var provider in _normalProviders) {
          ref.invalidate(provider);
        }
      }
    });
  }
}

final authStateListenerProvider = Provider(AuthStateListener.new);
