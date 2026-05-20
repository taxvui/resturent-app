part of 'printing_option_view.dart';

class PrintingOptionViewNotifier extends ChangeNotifier {
  PrintingOptionViewNotifier(this.ref) : _repo = ref.read(userRepositoryProvider.notifier);
  final Ref ref;
  final UserRepository _repo;

  //-------------------------Form Field Props-------------------------//
  DynamicFileType? avatarImage = DynamicFileType();
  void handleAvatarImage(File? value) {
    if (value == null || value.path.isEmpty) return;
    avatarImage = DynamicFileType(local: value);
    notifyListeners();
  }

  late final shopNameController = TextEditingController(),
      businessPhoneController = TextEditingController(),
      shopAddressController = TextEditingController(),
      noteLabelController = TextEditingController(),
      noteController = TextEditingController(),
      postSaleMessage = TextEditingController(),
      printerDpiController = TextEditingController(),
      printerMarginController = TextEditingController();
  late PrinterSetttingsModel printerSettings;

  void toggleAutoPrint(bool value) {
    printerSettings = printerSettings.copyWith(autoPrint: value);
    notifyListeners();
  }

  void handleSelectPrintingMethod(ThermalPrinterPrintingMethod? value) {
    printerSettings = printerSettings.copyWith(printingMethod: value);
    notifyListeners();
  }

  void handleSelectPrinterProfile(PrinterProfile? value) {
    printerSettings = printerSettings.copyWith(profile: value);
    notifyListeners();
  }

  void handleSelectPrinterPaperSize(ThermalPrinterPaperSize? value) {
    printerSettings = printerSettings.copyWith(paperSize: value);
    notifyListeners();
  }
  //-------------------------Form Field Props-------------------------//

  void initEdit() {
    ref.read(userRepositoryProvider).whenData((data) {
      avatarImage = data?.invoiceLogo;
      shopNameController.text = data?.business?.companyName ?? '';
      businessPhoneController.text = data?.business?.phoneNumber ?? '';
      shopAddressController.text = data?.business?.address ?? '';
      noteLabelController.text = data?.invoiceNoteLabel ?? '';
      noteController.text = data?.invoiceNote ?? '';
      postSaleMessage.text = data?.gratitudeMessage ?? '';
      printerSettings = ref.read(printerSettingsProvider);
      printerDpiController.text = printerSettings.printerDpi?.toString() ?? '';
      printerMarginController.text = printerSettings.printerMargin?.toString() ?? '';
    });
  }

  Future<void> handleManagePrintingOption() async {
    try {
      final user = ref.read(userRepositoryProvider).value;
      final _data = (ref.read(userRepositoryProvider).value ?? User()).copyWith(
        invoiceLogo: avatarImage,
        invoiceNoteLabel: noteLabelController.text,
        invoiceNote: noteController.text,
        gratitudeMessage: postSaleMessage.text,
        invoiceSize: printerSettings.paperSize,
        business: user?.business?.copyWith(
          companyName: shopNameController.text,
          phoneNumber: businessPhoneController.text,
          address: shopAddressController.text,
        ),
      );

      final _ = await (
        _repo.updateProfile(_data),
        ref.read(printerSettingsProvider.notifier).saveSettings(
              printerSettings.copyWith(
                printerDpi: printerDpiController.getNumber?.toInt(),
                printerMargin: printerMarginController.getNumber,
              ),
            ),
      ).wait;
      await Future.microtask(ref.read(userRepositoryProvider.notifier).getUser);
    } catch (e) {
      throw Exception(e);
    }
  }
}

final printingOptionViewProvider = ChangeNotifierProvider.autoDispose(
  PrintingOptionViewNotifier.new,
);
