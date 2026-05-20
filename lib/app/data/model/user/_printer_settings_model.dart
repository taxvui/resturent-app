part of '_user_model.dart';

class PrinterSetttingsModel {
  final bool autoPrint;
  final core.ThermalPrinterPrintingMethod printingMethod;
  final tUtil.PrinterProfile profile;
  final core.ThermalPrinterPaperSize paperSize;
  final num? printerDpi;
  final num? printerMargin;

  PrinterSetttingsModel({
    required this.autoPrint,
    required this.printingMethod,
    required this.profile,
    required this.paperSize,
    this.printerDpi,
    this.printerMargin,
  });

  PrinterSetttingsModel copyWith({
    bool? autoPrint,
    core.ThermalPrinterPrintingMethod? printingMethod,
    tUtil.PrinterProfile? profile,
    core.ThermalPrinterPaperSize? paperSize,
    num? printerDpi,
    num? printerMargin,
  }) {
    return PrinterSetttingsModel(
      autoPrint: autoPrint ?? this.autoPrint,
      printingMethod: printingMethod ?? this.printingMethod,
      profile: profile ?? this.profile,
      paperSize: paperSize ?? this.paperSize,
      printerDpi: printerDpi, // Acccepting null
      printerMargin: printerMargin, // Acccepting null
    );
  }

  factory PrinterSetttingsModel.fromJson(Map<String, dynamic> json) {
    return PrinterSetttingsModel(
      autoPrint: json["autoPrint"] == true,
      printingMethod: json["printingMethod"] == null
          ? core.ThermalPrinterPrintingMethod.kDefault
          : core.ThermalPrinterPrintingMethod.values.byName(json["printingMethod"]),
      profile:
          json["profile"] == null ? tUtil.PrinterProfile.fallback : tUtil.PrinterProfile.tryFromName(json["profile"]),
      paperSize: json["paperSize"] == null
          ? core.ThermalPrinterPaperSize.mm803Inch
          : core.ThermalPrinterPaperSize.values.byName(json["paperSize"]),
      printerDpi: json["printerDpi"],
      printerMargin: json["printerMargin"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "autoPrint": autoPrint,
      "printingMethod": printingMethod.name,
      "profile": profile.name,
      "paperSize": paperSize.name,
      "printerDpi": printerDpi,
      "printerMargin": printerMargin,
    };
  }
}
