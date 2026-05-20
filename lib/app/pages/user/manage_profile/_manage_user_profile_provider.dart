part of 'manage_user_profile.dart';

class ManageUserProfileNotifier extends ChangeNotifier {
  ManageUserProfileNotifier(this.ref)
      : _repo = ref.watch(userRepositoryProvider.notifier),
        user = ref.watch(userRepositoryProvider).value;

  final Ref ref;
  final UserRepository _repo;
  final User? user;

  void initData() {
    if (user == null) return;

    fullNameController.text = user?.name ?? '';
    userEmailController.text = user?.email ?? '';
    userPhoneController.text = user?.phone ?? '';

    avatarImage = user?.profileImage;
    selectedBusinessCategory = user?.business?.businessCategoryId;
    shopNameController.text = user?.business?.companyName ?? '';
    businessPhoneController.text = user?.business?.phoneNumber ?? '';
    shopAddressController.text = user?.business?.address ?? '';
    openingBalanceController.setNumber(user?.business?.shopOpeningBalance);
    vatGstTitleController.text = user?.business?.vatName ?? '';
    vatGstNumberController.text = user?.business?.vatNo ?? '';
    // notifyListeners();
  }

  //-------------------------Form Field Props-------------------------//
  DynamicFileType? avatarImage;
  void handleAvatarImage(File? value) {
    if (value == null || value.path.isEmpty) return;
    avatarImage = DynamicFileType(local: value);
    notifyListeners();
  }

  int? selectedBusinessCategory;
  void selectBusinessCategory(int? value) {
    selectedBusinessCategory = value;
    notifyListeners();
  }

  late final fullNameController = TextEditingController();
  late final userEmailController = TextEditingController();
  late final userPhoneController = TextEditingController();

  late final shopNameController = TextEditingController();
  late final businessPhoneController = TextEditingController();
  late final shopAddressController = TextEditingController();
  late final openingBalanceController = TextEditingController();
  late final vatGstTitleController = TextEditingController();
  late final vatGstNumberController = TextEditingController();
  //-------------------------Form Field Props-------------------------//

  Future<User> handleUpdateProfile() async {
    final _userData = (user ?? User()).copyWith(
      name: fullNameController.text,
      email: userEmailController.text,
      phone: userPhoneController.text,
      image: avatarImage,
      business: Business(
        image: avatarImage,
        businessCategoryId: selectedBusinessCategory,
        companyName: shopNameController.text,
        phoneNumber: businessPhoneController.text,
        address: shopAddressController.text,
        shopOpeningBalance: openingBalanceController.getNumber,
        vatName: vatGstTitleController.text,
        vatNo: vatGstNumberController.text,
      ),
    );

    return await Future.microtask(() => _repo.updateProfile(_userData));
  }
}

final manageUserProfileProvider = ChangeNotifierProvider.autoDispose(
  ManageUserProfileNotifier.new,
);
