part of 'manage_party_view.dart';

class ManagePartyViewNotifier extends ChangeNotifier {
  ManagePartyViewNotifier(this.ref) : _repo = ref.watch(partyRepoProvider);

  final Ref ref;
  final PartyRepository _repo;

  //------------------Form Props------------------//
  late final nameController = TextEditingController();
  late final phoneController = TextEditingController();
  late final openingBalanceController = TextEditingController();

  PartyType? selectedPartyType = PartyType.customer;
  void handleChangingPartyType(PartyType? value) {
    selectedPartyType = value;
    notifyListeners();
  }

  DynamicFileType? avatarImage;
  void handleAvatarImage(DynamicFileType? value) {
    if (value == null || value.local?.path.isEmpty == true) return;
    avatarImage = value;
    notifyListeners();
  }

  late final emailController = TextEditingController();
  late final addressController = TextEditingController();

  final List<CustomerAddressData> customerAddressList = [];
  void handleCustomerAddress(CustomerAddressData? value, [int index = -1]) {
    if (value == null && index >= 0 && index < customerAddressList.length) {
      customerAddressList.removeAt(index);
    } else if (value != null) {
      if (index >= 0 && index < customerAddressList.length) {
        customerAddressList[index] = value;
      } else {
        customerAddressList.add(value);
      }
    }
    notifyListeners();
  }
  //------------------Form Props------------------//

  void initEdit(Party data) {
    nameController.text = data.name ?? '';
    phoneController.text = data.phone ?? '';
    openingBalanceController.setNumber(data.openingBalance);
    selectedPartyType = PartyType.fromString(data.type);
    avatarImage = data.image;
    emailController.text = data.email ?? '';
    addressController.text = data.address ?? '';

    if (data.deliveryAddresses?.isNotEmpty == true) {
      customerAddressList
        ..clear()
        ..addAll([
          ...?data.deliveryAddresses?.map((address) {
            return CustomerAddressData(
              id: address.id,
              name: address.name,
              phone: address.phone,
              address: address.address,
            );
          })
        ]);
    }
  }

  Future<Either<String, Party>> handleManageParty([
    Party? data,
  ]) async {
    final _data = (data ?? Party()).copyWith(
      name: nameController.text,
      phone: phoneController.text,
      type: selectedPartyType?.name,
      image: avatarImage,
      email: emailController.text,
      address: addressController.text,
      openingBalance: openingBalanceController.getNumber,
      deliveryAddresses: [
        if (selectedPartyType == PartyType.customer && customerAddressList.isNotEmpty)
          ...customerAddressList.map((address) {
            return DeliveryAddress(
              id: address.id,
              name: address.name,
              phone: address.phone,
              address: address.address,
            );
          })
      ],
    );

    return await Future.microtask(() => _repo.manageParty(_data));
  }
}

final managePartyViewProvider = ChangeNotifierProvider.autoDispose(
  ManagePartyViewNotifier.new,
);
