part of 'manage_coupon_view.dart';

class ManageCouponViewNotifier extends ChangeNotifier {
  ManageCouponViewNotifier(this.ref) : _repo = ref.read(couponRepoProvider);
  final Ref ref;
  final CouponRepository _repo;

  //----------------------Form Props----------------------//
  DynamicFileType? image;
  void handleImage(DynamicFileType? value) {
    if (value == null || (value.local?.path.isEmpty == true)) return;
    image = value;
    notifyListeners();
  }

  late final nameController = TextEditingController(),
      codeController = TextEditingController(),
      discountController = TextEditingController(),
      startDateController = TextEditingController(),
      endDateController = TextEditingController(),
      descriptionController = TextEditingController();

  RateModifierEnum? discountModifier = RateModifierEnum.percent;
  void handleDiscountModifierChange(RateModifierEnum? data) {
    discountModifier = data;
    notifyListeners();
  }
  //----------------------Form Props----------------------//

  void initEdit(CouponModel data) {
    image = data.image;
    nameController.text = data.name ?? '';
    codeController.text = data.code ?? '';
    discountController.text = data.discount?.toString() ?? '';
    discountModifier = RateModifierEnum.fromString(data.discountType);
    startDateController.text = data.startDate?.getFormatedString(pattern: 'dd/MM/yyyy') ?? '';
    endDateController.text = data.endDate?.getFormatedString(pattern: 'dd/MM/yyyy') ?? '';
    descriptionController.text = data.description ?? '';
  }

  Future<Either<String, CouponModel>> handleManageCoupon([
    CouponModel? data,
  ]) async {
    final _data = (data ?? CouponModel()).copyWith(
      image: image,
      name: nameController.text,
      code: codeController.text,
      discount: discountController.getNumber,
      discountType: discountModifier?.key,
      startDate: startDateController.text.parseDate,
      endDate: endDateController.text.parseDate,
      description: descriptionController.text,
    );

    return await Future.microtask(() => _repo.manageCoupon(_data));
  }
}

final manageCouponViewProvider = ChangeNotifierProvider.autoDispose(
  ManageCouponViewNotifier.new,
);
