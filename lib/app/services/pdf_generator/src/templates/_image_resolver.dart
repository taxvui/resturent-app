library;

import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:dio/dio.dart';

sealed class ImageSource {
  final dynamic data;
  ImageSource(this.data);
}

class Uint8ListSource extends ImageSource {
  Uint8ListSource(super.data);
  Uint8List get bytes => data as Uint8List;
}

class UrlSource extends ImageSource {
  UrlSource(super.data);
  String get url => data as String;
}

class Base64Source extends ImageSource {
  Base64Source(super.data);
  String get base64 => data as String;
}

class SvgSource extends ImageSource {
  SvgSource(super.data);
  String get svg => data as String;
}

class InvalidSource extends ImageSource {
  final String reason;
  InvalidSource(this.reason, super.data);
}

class ImageResolver {
  ImageResolver._();

  static Future<pw.Widget?> resolve(
    dynamic data, {
    pw.BoxFit fit = pw.BoxFit.contain,
    pw.Alignment alignment = pw.Alignment.center,
    double? width,
    double? height,
    double? dpi,
  }) async {
    try {
      if (data == null) return null;

      final source = _classifyImage(data);

      if (source is Uint8ListSource && source.bytes.isNotEmpty) {
        if (_isValidRasterImage(source.bytes)) {
          return _buildRasterImage(source.bytes, fit: fit, width: width, height: height, dpi: dpi);
        }
        return null;
      }
      if (source is UrlSource) {
        return await _fetchAndBuildImage(source.url, fit: fit, width: width, height: height, dpi: dpi);
      }
      if (source is Base64Source) {
        return await _decodeAndBuildImage(source.base64, fit: fit, width: width, height: height, dpi: dpi);
      }
      if (source is SvgSource) {
        return _buildSvgImage(source.svg, fit: fit, width: width, height: height);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static ImageSource _classifyImage(dynamic data) {
    if (data is Uint8List) {
      return Uint8ListSource(data);
    }

    if (data is String) {
      final trimmed = data.trim();

      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return UrlSource(trimmed);
      }

      if (trimmed.contains('base64,')) {
        return Base64Source(trimmed);
      }

      if (trimmed.startsWith('<svg')) {
        return SvgSource(trimmed);
      }

      return InvalidSource('Unknown string format', data);
    }

    return InvalidSource('Unknown type: ${data.runtimeType}', data);
  }

  static bool _isValidRasterImage(Uint8List bytes) {
    if (bytes.length < 8) return false;

    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) return true;

    return false;
  }

  static bool _isSvgUrl(String url) {
    return url.toLowerCase().endsWith('.svg');
  }

  static pw.Image _buildRasterImage(
    Uint8List bytes, {
    required pw.BoxFit fit,
    double? width,
    double? height,
    double? dpi,
  }) {
    return pw.Image(
      pw.MemoryImage(bytes),
      width: width,
      height: height,
      fit: fit,
      dpi: dpi,
    );
  }

  static Future<pw.Widget?> _fetchAndBuildImage(
    String url, {
    required pw.BoxFit fit,
    double? width,
    double? height,
    double? dpi,
  }) async {
    try {
      if (_isSvgUrl(url)) {
        return await _fetchSvgImage(url, fit: fit, width: width, height: height);
      }

      final response = await Dio().get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'image/*'},
        ),
      );

      if (response.data == null || response.data!.isEmpty) return null;

      final bytes = Uint8List.fromList(response.data!);
      if (!_isValidRasterImage(bytes)) return null;

      return _buildRasterImage(bytes, fit: fit, width: width, height: height, dpi: dpi);
    } catch (e) {
      return null;
    }
  }

  static Future<pw.SvgImage?> _fetchSvgImage(
    String url, {
    required pw.BoxFit fit,
    double? width,
    double? height,
  }) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'image/svg+xml'},
        ),
      );

      if (response.data == null || response.data!.isEmpty) return null;

      final svgData = utf8.decode(response.data!).trim();
      if (!svgData.startsWith('<svg')) return null;

      return _buildSvgImage(svgData, fit: fit, width: width, height: height);
    } catch (e) {
      return null;
    }
  }

  static Future<pw.Image?> _decodeAndBuildImage(
    String base64, {
    required pw.BoxFit fit,
    double? width,
    double? height,
    double? dpi,
  }) async {
    try {
      final cleanBase64 = base64.split(',').last;
      final bytes = base64Decode(cleanBase64);
      if (!_isValidRasterImage(bytes)) return null;

      return _buildRasterImage(bytes, fit: fit, width: width, height: height, dpi: dpi);
    } catch (e) {
      return null;
    }
  }

  static pw.SvgImage _buildSvgImage(
    String svg, {
    required pw.BoxFit fit,
    double? width,
    double? height,
  }) {
    return pw.SvgImage(
      svg: svg,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
