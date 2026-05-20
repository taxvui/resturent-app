part of 'manage_business_payment_method_view.dart';

class ManageBusinessPaymentMethodViewNotifier extends ChangeNotifier {
  ManageBusinessPaymentMethodViewNotifier(this.ref) : _repo = ref.read(businessPaymentMethodRepoProvider);

  final Ref ref;
  final BusinessPaymentMethodRepo _repo;

  late final nameController = TextEditingController();
  bool isActive = true;
  void toggleIsActive(bool value) {
    isActive = value;
    notifyListeners();
  }

  bool isQuickView = false;
  void toggleQuickView(bool value) {
    isQuickView = value;
    notifyListeners();
  }

  void initEdit(BusinessPaymentMethod data) {
    nameController.text = data.name ?? '';
    isActive = data.status == true;
    isQuickView = data.isView == true;
  }

  Future<Either<String, BusinessPaymentMethod>> handleManagePaymentMethod([
    BusinessPaymentMethod? data,
  ]) async {
    final _data = (data ?? BusinessPaymentMethod()).copyWith(
      name: nameController.text,
      status: isActive,
      isView: isQuickView,
    );

    return await Future.microtask(
      () => _repo.manageBusinessPaymentMethod(_data),
    );
  }
}

final manageBusinessPaymentMethodViewProvider = ChangeNotifierProvider.autoDispose(
  ManageBusinessPaymentMethodViewNotifier.new,
);
