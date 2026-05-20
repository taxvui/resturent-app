part of 'manage_tax_group_view.dart';

class ManageTaxGroupViewNotifier extends ChangeNotifier {
  ManageTaxGroupViewNotifier(this.ref) : _repo = ref.watch(taxRepoProvider);
  final Ref ref;
  final TaxRepository _repo;

  late final nameController = TextEditingController();
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

  List<TaxModel> selectedSubTaxes = [];
  void handleSelectSubTaxes(List<TaxModel> value) {
    selectedSubTaxes = value;
    notifyListeners();
  }

  void initEdit(TaxModel data) {
    nameController.text = data.name ?? '';
    isActive = data.status == true;
    selectedSubTaxes = [...?data.subTax];
    isVATOnSales = data.isVatOnSales == true;
  }

  Future<Either<String, TaxModel>> handleManageTax([TaxModel? data]) async {
    final _data = (data ?? TaxModel()).copyWith(
      name: nameController.text,
      status: isActive,
      subTax: selectedSubTaxes,
      isVatOnSales: isVATOnSales,
    );

    return await Future.microtask(() => _repo.manageTax(_data));
  }
}

final manageTaxGroupViewProvider = ChangeNotifierProvider.autoDispose(
  ManageTaxGroupViewNotifier.new,
);
