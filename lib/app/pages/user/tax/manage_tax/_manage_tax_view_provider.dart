part of 'manage_tax_view.dart';

class ManageTaxViewNotifier extends ChangeNotifier {
  ManageTaxViewNotifier(this.ref) : _repo = ref.watch(taxRepoProvider);
  final Ref ref;
  final TaxRepository _repo;

  late final nameController = TextEditingController();
  late final rateController = TextEditingController();
  bool isActive = false;
  void toggleIsActive(bool value) {
    isActive = value;
    notifyListeners();
  }

  bool isVATOnSales = false;
  void toggleIsVATOnSales(bool value) {
    isVATOnSales = value;
    notifyListeners();
  }

  void initEdit(TaxModel data) {
    nameController.text = data.name ?? '';
    rateController.setNumber(data.rate);
    isActive = data.status == true;
    isVATOnSales = data.isVatOnSales == true;
  }

  Future<Either<String, TaxModel>> handleManageTax([TaxModel? data]) async {
    final _data = (data ?? TaxModel()).copyWith(
      name: nameController.text,
      rate: rateController.getNumber,
      status: isActive,
      isVatOnSales: isVATOnSales,
    );
    return await Future.microtask(() => _repo.manageTax(_data));
  }
}

final manageTaxViewProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ManageTaxViewNotifier(ref),
);
