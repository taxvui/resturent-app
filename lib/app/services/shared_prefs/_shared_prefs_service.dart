import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

final sharedPrefsProvider = Provider.autoDispose<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

extension on AutoDisposeProvider<SharedPreferences> {}
