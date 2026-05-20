import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../services.dart';
import '../../core/core.dart' show DAppSPrefsKeys;

class CustomAppLocale extends Locale {
  CustomAppLocale({
    required String languageCode,
    String? countryCode,
    required this.languageName,
    this.currencySymbol = "\$",
    this.currencyName = "US Dollar",
    this.currencyCode = "USD",
  }) : super(languageCode, countryCode);

  final String languageName;
  final String currencySymbol;
  final String currencyName;
  final String currencyCode;

  CustomAppLocale copyWith({
    String? languageName,
    String? languageCode,
    String? countryCode,
    String? currencySymbol,
    String? currencyName,
    String? currencyCode,
  }) {
    return CustomAppLocale(
      languageName: languageName ?? this.languageName,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyName: currencyName ?? this.currencyName,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  factory CustomAppLocale.fromJson(String json) {
    final Map<String, dynamic> jsonMap = jsonDecode(json);
    return CustomAppLocale(
      languageName: jsonMap['languageName'] as String,
      languageCode: jsonMap['languageCode'] as String,
      countryCode: jsonMap['countryCode'] as String?,
      currencySymbol: jsonMap['currencySymbol'] as String,
      currencyName: jsonMap['currencyName'] as String,
      currencyCode: jsonMap['currencyCode'] as String,
    );
  }

  String toJson() {
    return jsonEncode({
      'languageName': languageName,
      'languageCode': languageCode,
      'countryCode': countryCode,
      'currencySymbol': currencySymbol,
      'currencyName': currencyName,
      'currencyCode': currencyCode,
    });
  }
}

class AppLocaleService extends ChangeNotifier {
  final SharedPreferences prefs;
  AppLocaleService(this.prefs) {
    loadSavedLocale();
  }

  static final _supportedLocale = <CustomAppLocale>[
    CustomAppLocale(
      languageName: "Afrikans",
      languageCode: "af",
      countryCode: "ZA",
      currencySymbol: "R",
    ),
    /*
    CustomAppLocale(
      languageName: "Albanian",
      languageCode: "sq",
      countryCode: "AL",
      currencySymbol: "Lek",
    ),
    CustomAppLocale(
      languageName: "Amharic",
      languageCode: "am",
      countryCode: "ET",
      currencySymbol: "Br",
    ),
    */
    CustomAppLocale(
      languageName: "Arabic",
      languageCode: "ar",
      countryCode: "SA",
      currencySymbol: "﷼",
    ),
    /*
    CustomAppLocale(
      languageName: "Armenian",
      languageCode: "hy",
      countryCode: "AM",
      currencySymbol: "֏",
    ),
    CustomAppLocale(
      languageName: "Assamese",
      languageCode: "as",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    CustomAppLocale(
      languageName: "Azerbaijani",
      languageCode: "az",
      countryCode: "AZ",
      currencySymbol: "₼",
    ),
    */
    CustomAppLocale(
      languageName: "Bangla",
      languageCode: "bn",
      countryCode: "BD",
      currencySymbol: "৳",
    ),
    /*
    CustomAppLocale(
      languageName: "Basque",
      languageCode: "eu",
      countryCode: "ES",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Belarusian",
      languageCode: "be",
      countryCode: "BY",
      currencySymbol: "Br",
    ),
    CustomAppLocale(
      languageName: "Bosnian",
      languageCode: "bs",
      countryCode: "BA",
      currencySymbol: "KM",
    ),
    */
    CustomAppLocale(
      languageName: "Bulgarian",
      languageCode: "bg",
      countryCode: "BG",
      currencySymbol: "лв",
    ),
    /*
    CustomAppLocale(
      languageName: "Burmese",
      languageCode: "my",
      countryCode: "MM",
      currencySymbol: "Ks",
    ),
    CustomAppLocale(
      languageName: "Catalan Valencian",
      languageCode: "ca",
      countryCode: "ES",
      currencySymbol: "€",
    ),
    */
    CustomAppLocale(
      languageName: "Chinese",
      languageCode: "zh",
      countryCode: "CN",
      currencySymbol: "¥",
    ),
    CustomAppLocale(
      languageName: "Croatian",
      languageCode: "hr",
      countryCode: "HR",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Czech",
      languageCode: "cs",
      countryCode: "CZ",
      currencySymbol: "Kč",
    ),
    CustomAppLocale(
      languageName: "Danish",
      languageCode: "da",
      countryCode: "DK",
      currencySymbol: "kr",
    ),
    CustomAppLocale(
      languageName: "Dutch Flemish",
      languageCode: "nl",
      countryCode: "BE",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "English",
      languageCode: "en",
      countryCode: "US",
      currencySymbol: "\$",
    ),
    CustomAppLocale(
      languageName: "English (Australia)",
      countryCode: "AU",
      languageCode: "en",
      currencySymbol: "\$",
      currencyName: "Australian Dollar",
      currencyCode: "AUD",
    ),
    CustomAppLocale(
      languageName: "English (Canada)",
      countryCode: "CA",
      languageCode: "en",
      currencySymbol: "\$",
      currencyName: "Canadian Dollar",
      currencyCode: "CAD",
    ),
    CustomAppLocale(
      languageName: "Estonian",
      languageCode: "et",
      countryCode: "EE",
      currencySymbol: "€",
    ),
    /*
    CustomAppLocale(
      languageName: "Filipino",
      languageCode: "fil",
      countryCode: "PH",
      currencySymbol: "₱",
    ),
    */
    CustomAppLocale(
      languageName: "Finnish",
      languageCode: "fi",
      countryCode: "FI",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "French",
      languageCode: "fr",
      countryCode: "FR",
      currencySymbol: "€",
    ),
    /*
    CustomAppLocale(
      languageName: "Galician",
      languageCode: "gl",
      countryCode: "ES",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Georgian",
      languageCode: "ka",
      countryCode: "GE",
      currencySymbol: "ლ",
    ),
    */
    CustomAppLocale(
      languageName: "German",
      languageCode: "de",
      countryCode: "DE",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Greek",
      languageCode: "el",
      countryCode: "GR",
      currencySymbol: "€",
    ),
    /*
    CustomAppLocale(
      languageName: "Gujarati",
      languageCode: "gu",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    */
    CustomAppLocale(
      languageName: "Hebrew",
      languageCode: "he",
      countryCode: "IL",
      currencySymbol: "₪",
    ),
    CustomAppLocale(
      languageName: "Hindi",
      languageCode: "hi",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    CustomAppLocale(
      languageName: "Hungarian",
      languageCode: "hu",
      countryCode: "HU",
      currencySymbol: "Ft",
    ),
    /*
    CustomAppLocale(
      languageName: "Icelandic",
      languageCode: "is",
      countryCode: "IS",
      currencySymbol: "kr",
    ),
    */
    CustomAppLocale(
      languageName: "Indonesian",
      languageCode: "id",
      countryCode: "ID",
      currencySymbol: "Rp",
    ),
    CustomAppLocale(
      languageName: "Italian",
      languageCode: "it",
      countryCode: "IT",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Japanese",
      languageCode: "ja",
      countryCode: "JP",
      currencySymbol: "¥",
    ),
    /*
    CustomAppLocale(
      languageName: "Kannada",
      languageCode: "kn",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    CustomAppLocale(
      languageName: "Kazakh",
      languageCode: "kk",
      countryCode: "KZ",
      currencySymbol: "₸",
    ),
    CustomAppLocale(
      languageName: "Kirghiz Kyrgyz",
      languageCode: "ky",
      countryCode: "KG",
      currencySymbol: "с",
    ),
    */
    CustomAppLocale(
      languageName: "Khmer",
      languageCode: "km",
      countryCode: "KH",
      currencySymbol: "៛",
    ),
    CustomAppLocale(
      languageName: "Korean",
      languageCode: "ko",
      countryCode: "KR",
      currencySymbol: "₩",
    ),
    /*
    CustomAppLocale(
      languageName: "Lao",
      languageCode: "lo",
      countryCode: "LA",
      currencySymbol: "₭",
    ),
    */
    CustomAppLocale(
      languageName: "Latvian",
      languageCode: "lv",
      countryCode: "LV",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Lithuanian",
      languageCode: "lt",
      countryCode: "LT",
      currencySymbol: "€",
    ),
    /*
    CustomAppLocale(
      languageName: "Macedonian",
      languageCode: "mk",
      countryCode: "MK",
      currencySymbol: "ден",
    ),
    */
    CustomAppLocale(
      languageName: "Malay",
      languageCode: "ms",
      countryCode: "MY",
      currencySymbol: "RM",
    ),
    /*
    CustomAppLocale(
      languageName: "Malayalam",
      languageCode: "ml",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    CustomAppLocale(
      languageName: "Marathi",
      languageCode: "mr",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    CustomAppLocale(
      languageName: "Mongolian",
      languageCode: "mn",
      countryCode: "MN",
      currencySymbol: "₮",
    ),
    CustomAppLocale(
      languageName: "Nepali",
      languageCode: "ne",
      countryCode: "NP",
      currencySymbol: "₨",
    ),
    */
    CustomAppLocale(
      languageName: "Norwegian",
      languageCode: "no",
      countryCode: "NO",
      currencySymbol: "kr",
    ),
    /*
    CustomAppLocale(
      languageName: "Norwegian Bokmål",
      languageCode: "nb",
      countryCode: "NO",
      currencySymbol: "kr",
    ),
    CustomAppLocale(
      languageName: "Oriya",
      languageCode: "or",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    CustomAppLocale(
      languageName: "Panjabi",
      languageCode: "pa",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    CustomAppLocale(
      languageName: "Persian",
      languageCode: "fa",
      countryCode: "IR",
      currencySymbol: "﷼",
    ),
    */
    CustomAppLocale(
      languageName: "Polish",
      languageCode: "pl",
      countryCode: "PL",
      currencySymbol: "zł",
    ),
    CustomAppLocale(
      languageName: "Portuguese",
      languageCode: "pt",
      countryCode: "PT",
      currencySymbol: "€",
    ),
    /*
    CustomAppLocale(
      languageName: "Pushto",
      languageCode: "ps",
      countryCode: "AF",
      currencySymbol: "؋",
    ),
    */
    CustomAppLocale(
      languageName: "Romanian",
      languageCode: "ro",
      countryCode: "RO",
      currencySymbol: "lei",
    ),
    CustomAppLocale(
      languageName: "Serbian",
      languageCode: "sr",
      countryCode: "RS",
      currencySymbol: "дин",
    ),
    /*
    CustomAppLocale(
      languageName: "Sinhala",
      languageCode: "si",
      countryCode: "LK",
      currencySymbol: "රු",
    ),
    */
    CustomAppLocale(
      languageName: "Slovak",
      languageCode: "sk",
      countryCode: "SK",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Slovenian",
      languageCode: "sl",
      countryCode: "SI",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Spanish",
      languageCode: "es",
      countryCode: "ES",
      currencySymbol: "€",
    ),
    CustomAppLocale(
      languageName: "Spanish (Uruguay)",
      countryCode: "UY",
      languageCode: "es",
      currencySymbol: "\$U",
      currencyName: "Peso Uruguayo",
      currencyCode: "UYU",
    ),
    CustomAppLocale(
      languageName: "Swahili",
      languageCode: "sw",
      countryCode: "TZ",
      currencySymbol: "TSh",
    ),
    CustomAppLocale(
      languageName: "Swedish",
      languageCode: "sv",
      countryCode: "SE",
      currencySymbol: "kr",
    ),
    /*
    CustomAppLocale(
      languageName: "Swiss German Alemannic Alsatian",
      languageCode: "gsw",
      countryCode: "CH",
      currencySymbol: "CHF",
    ),
    CustomAppLocale(
      languageName: "Tamil",
      languageCode: "ta",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    CustomAppLocale(
      languageName: "Telugu",
      languageCode: "te",
      countryCode: "IN",
      currencySymbol: "₹",
    ),
    */
    CustomAppLocale(
      languageName: "Thai",
      languageCode: "th",
      countryCode: "TH",
      currencySymbol: "฿",
    ),
    CustomAppLocale(
      languageName: "Turkish",
      languageCode: "tr",
      countryCode: "TR",
      currencySymbol: "₺",
    ),
    CustomAppLocale(
      languageName: "Ukrainian",
      languageCode: "uk",
      countryCode: "UA",
      currencySymbol: "₴",
    ),
    /*
    CustomAppLocale(
      languageName: "Urdu",
      languageCode: "ur",
      countryCode: "PK",
      currencySymbol: "₨",
    ),
    */
    CustomAppLocale(
      languageName: "Vietnamese",
      languageCode: "vi",
      countryCode: "VN",
      currencySymbol: "₫",
    ),
    /*
    CustomAppLocale(
      languageName: "Welsh",
      languageCode: "cy",
      countryCode: "GB",
      currencySymbol: "£",
    ),
    */
    CustomAppLocale(
      languageName: "Русский",
      languageCode: "ru",
      countryCode: "RU",
      currencySymbol: "₽",
    ),
  ];
  static final _fallbackLocale = _supportedLocale.firstWhere(
    (locale) => locale.languageCode == 'en' && locale.countryCode == 'US',
  );

  List<CustomAppLocale> get supportedLocale => _supportedLocale;
  late CustomAppLocale activeLocale = _fallbackLocale;
  late final List<CustomAppLocale> currencyList = [
    ...(() {
      final Map<String, CustomAppLocale> uniqueCurrencies = {};

      for (final locale in supportedLocale) {
        uniqueCurrencies.putIfAbsent(locale.currencyCode, () => locale);
      }

      return uniqueCurrencies.values.toList();
    })(),
  ];

  Future<Either<String, String>> saveLocale(CustomAppLocale newLocale) async {
    try {
      final _result = await prefs.setString(
        DAppSPrefsKeys.savedLocale,
        newLocale.toJson(),
      );

      if (_result) {
        activeLocale = newLocale;

        if (activeLocale.currencySymbol != currencyNotifier.value) {
          currencyNotifier.value = activeLocale.currencySymbol;
        }

        await LocaleSettings.setLocaleRaw(activeLocale.languageCode);
        return Either.success('Locale saved successfully');
      }

      return Either.failure('Failed to save locale');
    } catch (e) {
      return Either.failure('Error saving locale: $e');
    }
  }

  Future<void> loadSavedLocale() async {
    final savedLocale = prefs.getString(DAppSPrefsKeys.savedLocale);
    if (savedLocale != null) {
      activeLocale = CustomAppLocale.fromJson(savedLocale);
      await LocaleSettings.setLocaleRaw(activeLocale.languageCode);

      currencyNotifier.value = activeLocale.currencySymbol;
    }
  }

  /// Sets up plural resolvers for languages not supported by slang out of the box
  /// Must be called before creating AppLocaleService instance
  static Future<void> initializePluralResolvers() async {
    // Bengali (bn) - one form for 1, other for everything else
    await LocaleSettings.setPluralResolver(
      language: 'bn',
      cardinalResolver: (num n, {String? zero, String? one, String? two, String? few, String? many, String? other}) {
        if (n == 1) return one ?? other!;
        return other!;
      },
    );

    // Khmer (km) - no plural distinction
    await LocaleSettings.setPluralResolver(
      language: 'km',
      cardinalResolver: (num n, {String? zero, String? one, String? two, String? few, String? many, String? other}) {
        return other!;
      },
    );

    // Thai (th) - no plural distinction
    await LocaleSettings.setPluralResolver(
      language: 'th',
      cardinalResolver: (num n, {String? zero, String? one, String? two, String? few, String? many, String? other}) {
        return other!;
      },
    );

    // Chinese (zh) - no plural distinction
    await LocaleSettings.setPluralResolver(
      language: 'zh',
      cardinalResolver: (num n, {String? zero, String? one, String? two, String? few, String? many, String? other}) {
        return other!;
      },
    );

    // Japanese (ja) - no plural distinction
    await LocaleSettings.setPluralResolver(
      language: 'ja',
      cardinalResolver: (num n, {String? zero, String? one, String? two, String? few, String? many, String? other}) {
        return other!;
      },
    );

    // Korean (ko) - no plural distinction
    await LocaleSettings.setPluralResolver(
      language: 'ko',
      cardinalResolver: (num n, {String? zero, String? one, String? two, String? few, String? many, String? other}) {
        return other!;
      },
    );

    // Indonesian (id) / Malay (ms) - no plural distinction
    for (final lang in ['id', 'ms']) {
      await LocaleSettings.setPluralResolver(
        language: lang,
        cardinalResolver: (num n, {String? zero, String? one, String? two, String? few, String? many, String? other}) {
          return other!;
        },
      );
    }

    // Swahili (sw) - one form for 1, other for everything else
    await LocaleSettings.setPluralResolver(
      language: 'sw',
      cardinalResolver: (num n, {String? zero, String? one, String? two, String? few, String? many, String? other}) {
        if (n == 1) return one ?? other!;
        return other!;
      },
    );
  }
}

final appLocaleServiceProvider = Provider<AppLocaleService>((ref) {
  throw UnimplementedError('AppLocaleService not implemented');
});

final currencyNotifier = ValueNotifier<String>(
  AppLocaleService._fallbackLocale.currencySymbol,
);
