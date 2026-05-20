import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../services/services.dart';

extension DateHelperExtension on DateTime {
  DateTime get getDateOnly => DateTime(year, month, day);

  String getFormatedString({String? pattern = 'dd MMM yyyy'}) {
    return intl.DateFormat(pattern).format(this);
  }

  String get dbFormat {
    return intl.DateFormat('yyyy-MM-dd').format(this);
  }

  String get backSlashDateFormat {
    return getFormatedString(pattern: 'dd/MM/yyyy');
  }

  /// Formats time as "HH:mm" for API
  String get timeFormat {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Formats time as "hh:mm a" for display (e.g., "09:30 AM")
  String get timeFormat12Hour {
    return intl.DateFormat('hh:mm a').format(this);
  }

  /// Formats time as "HH:mm" for display (e.g., "09:30")
  String get timeFormat24Hour {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

extension StringFormatterExtension on String {
  num get plainNumber {
    final _num = num.tryParse(replaceAll(',', '')) ?? 0;
    return _num;
  }

  /// Parses various date/time formats into DateTime
  /// Supports ISO 8601, common date formats, and time formats
  DateTime? get parseDate {
    if (isEmpty) return null;

    final trimmed = trim();

    // Try parsing as ISO 8601 first (most common in APIs)
    try {
      final isoDate = DateTime.tryParse(trimmed);
      if (isoDate != null) return isoDate;
    } catch (_) {}

    // Try intelligent slash date parsing for ambiguous formats
    final slashDate = _parseSlashDate(trimmed);
    if (slashDate != null) return slashDate;

    // List of patterns to try for parsing (excluding slash dates which are handled above)
    final patterns = [
      // ISO 8601 / RFC 3339 formats
      "yyyy-MM-ddTHH:mm:ssZ", // 2025-02-05T14:30:45Z
      "yyyy-MM-ddTHH:mm:ss.SSSZ", // 2025-02-05T14:30:45.123Z
      "yyyy-MM-ddTHH:mm:ss", // 2025-02-05T14:30:45
      "yyyy-MM-dd HH:mm:ss", // 2025-02-05 14:30:45
      "yyyy-MM-dd", // 2025-02-05
      "yyyyMMdd", // 20250205
      "yyyy-MM", // 2025-02
      // Date with dots
      "dd.MM.yyyy HH:mm:ss", // 05.02.2025 14:30:45
      "dd.MM.yyyy", // 05.02.2025
      // Named month formats
      "dd MMM yyyy HH:mm:ss", // 05 Feb 2025 14:30:45
      "dd MMM yyyy", // 05 Feb 2025
      "dd MMMM yyyy", // 05 February 2025
      "MMM dd, yyyy", // Feb 05, 2025
      "MMMM dd, yyyy", // February 05, 2025
      "EEE, dd MMM yyyy", // Tue, 05 Feb 2025
      "EEEE, dd MMMM yyyy", // Tuesday, 05 February 2025
      // 12-hour time formats with dates
      "yyyy-MM-dd hh:mm:ss a", // 2025-02-05 02:30:45 PM
      "yyyy-MM-dd hh:mm a", // 2025-02-05 02:30 PM
      // Time only formats (24-hour)
      "HH:mm:ss.SSS", // 14:30:45.123
      "HH:mm:ss", // 14:30:45
      "HH:mm", // 14:30
      // Time only formats (12-hour)
      "hh:mm:ss a", // 02:30:45 PM
      "hh:mm a", // 02:30 PM
      "h:mm a", // 2:30 PM
      // RFC formats (HTTP headers, email)
      "EEE, dd MMM yyyy HH:mm:ss 'GMT'", // Tue, 05 Feb 2025 14:30:45 GMT
      "EEE, dd MMM yyyy HH:mm:ss Z", // Tue, 05 Feb 2025 14:30:45 +0000
    ];

    for (final pattern in patterns) {
      try {
        final date = intl.DateFormat(pattern).parseLoose(trimmed);
        return date;
      } catch (_) {
        continue;
      }
    }

    // Try parsing Unix timestamps (seconds and milliseconds)
    final numericValue = num.tryParse(trimmed);
    if (numericValue != null) {
      // Check if it's milliseconds (13 digits) or seconds (10 digits)
      if (numericValue > 1000000000000) {
        // Milliseconds
        return DateTime.fromMillisecondsSinceEpoch(numericValue.toInt());
      } else if (numericValue > 1000000000) {
        // Seconds
        return DateTime.fromMillisecondsSinceEpoch(numericValue.toInt() * 1000);
      }
    }

    return null;
  }

  /// Intelligently parses slash-separated dates (dd/MM/yyyy or MM/dd/yyyy)
  /// Uses value-based detection to determine format
  DateTime? _parseSlashDate(String input) {
    // Match patterns like dd/MM/yyyy, MM/dd/yyyy with optional time
    final dateOnlyRegex = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final dateTimeRegex = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?$');

    // Try date + time first
    final timeMatch = dateTimeRegex.firstMatch(input);
    if (timeMatch != null) {
      final first = int.parse(timeMatch.group(1)!);
      final second = int.parse(timeMatch.group(2)!);
      final year = int.parse(timeMatch.group(3)!);
      final hour = int.parse(timeMatch.group(4)!);
      final minute = int.parse(timeMatch.group(5)!);
      final secondVal = timeMatch.group(6) != null ? int.parse(timeMatch.group(6)!) : 0;

      // Determine format based on values
      // If first > 12, it must be dd/MM (day can't be > 12 in MM/dd)
      // If second > 12, it must be MM/dd (month can't be > 12 in dd/MM)
      // If both <= 12, default to dd/MM (more common internationally)
      int day, month;
      if (first > 12) {
        // Definitely dd/MM/yyyy
        day = first;
        month = second;
      } else if (second > 12) {
        // Definitely MM/dd/yyyy
        month = first;
        day = second;
      } else {
        // Ambiguous case - default to dd/MM/yyyy (international standard)
        day = first;
        month = second;
      }

      try {
        return DateTime(year, month, day, hour, minute, secondVal);
      } catch (_) {
        return null;
      }
    }

    // Try date only
    final dateMatch = dateOnlyRegex.firstMatch(input);
    if (dateMatch != null) {
      final first = int.parse(dateMatch.group(1)!);
      final second = int.parse(dateMatch.group(2)!);
      final year = int.parse(dateMatch.group(3)!);

      int day, month;
      if (first > 12) {
        // Definitely dd/MM/yyyy
        day = first;
        month = second;
      } else if (second > 12) {
        // Definitely MM/dd/yyyy
        month = first;
        day = second;
      } else {
        // Ambiguous case - default to dd/MM/yyyy (international standard)
        day = first;
        month = second;
      }

      try {
        return DateTime(year, month, day);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  String get obscure => '*' * length;
}

extension NumberFormatterExtension on num {
  bool get _isDouble => this != toInt();
  String quickCurrency({
    String? customCurrency,
    int decimalDigits = 2,
    String? locale,
  }) {
    final _symbol = customCurrency ?? currencyNotifier.value;
    // intl.NumberFormat.simpleCurrency().currencySymbol;
    return intl.NumberFormat.currency(
      symbol: _symbol,
      decimalDigits: _isDouble ? decimalDigits : 0,
      locale: locale,
    ).format(this);
  }

  String compactCurrency({
    String? customCurrency,
    int decimalDigits = 2,
    String? locale,
  }) {
    final _symbol = customCurrency ?? currencyNotifier.value;
    // intl.NumberFormat.simpleCurrency(locale: locale).currencySymbol;

    return intl.NumberFormat.compactCurrency(
      locale: locale,
      symbol: _symbol,
      decimalDigits: _isDouble ? decimalDigits : 0,
    ).format(this);
  }

  String compactNumber({
    bool explicitSign = false,
    String? locale,
  }) {
    return intl.NumberFormat.compact(
      explicitSign: explicitSign,
      locale: locale,
    ).format(this);
  }

  String commaSeparated({
    int decimalDigits = 2,
    String? locale,
  }) {
    return intl.NumberFormat.decimalPatternDigits(
      decimalDigits: _isDouble ? decimalDigits : 0,
      locale: locale,
    ).format(this);
  }

  num toFixedDecimal({int decimalDigits = 2}) {
    return num.parse(toStringAsFixed(decimalDigits));
  }
}

extension ValueNotifierX<T> on ValueNotifier<T> {
  void set(T newValue) => value = newValue;
}
