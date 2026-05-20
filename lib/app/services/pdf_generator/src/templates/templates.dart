import 'package:pdf/widgets.dart' as pw;

import '_image_resolver.dart';

export '_report_pdf_template.dart';
export '_sale_purchase_invoice_template.dart';

abstract class PDFTemplateBase {
  Future<pw.Page> get page;
  String get fileName;

  Future<pw.Document> generateTemplate() async {
    try {
      final _document = pw.Document();
      _document.addPage(await page);
      return _document;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<pw.Widget?> resolvedImage(
    dynamic data, {
    pw.BoxFit fit = pw.BoxFit.contain,
    pw.Alignment alignment = pw.Alignment.center,
    double? width,
    double? height,
    double? dpi,
  }) async {
    return ImageResolver.resolve(
      data,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      dpi: dpi,
    );
  }
}
