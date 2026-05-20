import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'templates/templates.dart';

class PDFGenerator {
  PDFGenerator({required this.template});
  final PDFTemplateBase template;

  Future<File> getPDFFile() async {
    try {
      final _dir = await getTemporaryDirectory();
      final _file = File('${_dir.path}/${template.fileName}.pdf');

      final _pdfDocument = await template.generateTemplate();
      await _file.writeAsBytes((await _pdfDocument.save()));

      return _file;
    } catch (e) {
      throw Exception(e);
    }
  }
}
