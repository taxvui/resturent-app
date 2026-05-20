import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/core.dart' show DAPIEndpoints, DAppSPrefsKeys;

export 'dart:convert' show jsonEncode, jsonDecode;
export 'dart:developer' show log;

class HTTPDioClient {
  HTTPDioClient._({
    this.enableLogging = true,
    required this.prefs,
  });

  final SharedPreferences prefs;
  static HTTPDioClient? _instance;
  final bool enableLogging;
  late dio.Dio restClient;

  final _logger = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
    enabled: kDebugMode,
  );
  final _requestTimeout = const Duration(seconds: 20);

  factory HTTPDioClient.initClient({required SharedPreferences prefs}) {
    try {
      final _i = _instance ??= HTTPDioClient._(
        prefs: prefs,
        enableLogging: kDebugMode,
      );

      final _token = _i.prefs.getString(DAppSPrefsKeys.authToken);
      if (_token != null) _i.setToken(_token);

      _i.restClient = dio.Dio()
        ..options = dio.BaseOptions(
          baseUrl: DAPIEndpoints.apiURL,
          connectTimeout: _i._requestTimeout,
          headers: {"Accept": "application/json"},
        );

      if (_i.enableLogging) {
        _i.restClient.interceptors.add(_i._logger);
      }
      return _i;
    } catch (e, _) {
      if (kDebugMode) {
        print('Failed to initialize HTTPDioClient: $e');
      }
      throw Exception('HTTPDioClient initialization error');
    }
  }

  String? _token;
  Map<String, String> get getAuthHeader {
    return {
      "Authorization": "Bearer $_token",
    };
  }

  Future<void> setToken(String value, [bool save = false]) async {
    _token = value;
    if (save) {
      await prefs.setString(DAppSPrefsKeys.authToken, value);
    }
  }

  Future<Either<String, File>> downloadFile(
    String? urlPath, {
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    if (urlPath == null || urlPath.isEmpty) {
      return Either.failure('Invalid file path.');
    }

    try {
      final fileName = urlPath
          .split('/')
          .lastWhere(
            (element) => element.isNotEmpty,
            orElse: () => 'file',
          );

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');

      final response = await restClient.download(
        urlPath,
        file.path,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.statusCode == HttpStatus.ok) {
        return Either.success(file);
      } else {
        return Either.failure(
          'Failed to download file: ${response.statusMessage ?? 'Unknown error.'}',
        );
      }
    } on dio.DioException catch (e) {
      final errorMessage = e.response?.data?['message'] as String? ?? 'Failed to download file! Please try again.';
      return Either.failure(errorMessage);
    } catch (e) {
      return Either.failure('Failed to download file: ${e.toString()}');
    }
  }
}

final httpDioClientProvider = Provider<HTTPDioClient>(
  (ref) => throw AssertionError(
    "HTTPDioClient is not initialized. Ensure it is overridden in the ProviderScope.",
  ),
);

// Special Types
typedef Dio = dio.Dio;
typedef DioFormData = dio.FormData;
typedef DioOptions = dio.Options;
typedef DioResponse = dio.Response;
typedef DioRequestOptions = dio.RequestOptions;
typedef DioHeaders = dio.Headers;
typedef DioResponseType = dio.ResponseType;
typedef DioException = dio.DioException;

extension DioFormExtension on Map<String, dynamic> {
  Future<DioFormData> getTypedData() async {
    List<MapEntry<String, dio.MultipartFile>> files = [];
    Map<String, dynamic> fields = {};

    for (var element in entries) {
      final _value = element.value;

      if (_value is File && _value.path.isNotEmpty || (_value is File? && _value?.path.isNotEmpty == true)) {
        files.add(
          MapEntry(
            element.key,
            await dio.MultipartFile.fromFile(_value!.path),
          ),
        );
      } else {
        fields[element.key] = _value;
      }
    }

    return DioFormData.fromMap(fields)..files.addAll(files);
  }

  Future<Map<String, String>> toCheckMap() async {
    final _map = <String, String>{};
    final dioFormData = await Future.microtask(getTypedData);

    for (var entry in dioFormData.fields) {
      _map[entry.key] = entry.value;
    }
    for (var fileEntry in dioFormData.files) {
      _map[fileEntry.key] = fileEntry.value.filename ?? '';
    }
    return _map;
  }

  Map<String, dynamic> get removeNullValue {
    return Map.fromEntries(
      entries.where((element) => element.value != null),
    );
  }
}

class AuthListener extends dio.Interceptor {
  AuthListener({required this.onRevoke});
  final void Function() onRevoke;

  @override
  void onError(
    dio.DioException err,
    dio.ErrorInterceptorHandler handler,
  ) {
    final _response = err.response;
    final _reqOpt = _response?.requestOptions;
    if (_response?.statusCode == HttpStatus.unauthorized) {
      final _msg = _response?.data?['message'] ?? 'Unauthorized access';
      onRevoke();
      return handler.reject(
        dio.DioException(
          requestOptions: _reqOpt ?? dio.RequestOptions(),
          error: Exception(_msg),
          message: _msg,
          response: _response,
        ),
      );
    }
    super.onError(err, handler);
  }
}

// Event Manager
class GlobalEventManager {
  GlobalEventManager._();
  static final _instance = GlobalEventManager._();
  static GlobalEventManager get I => _instance;

  final _streamController = StreamController.broadcast();
  StreamController get streamController => _streamController;

  Stream<T> on<T>() {
    if (T == dynamic) {
      return streamController.stream as Stream<T>;
    } else {
      return streamController.stream.where((event) => event is T).cast<T>();
    }
  }

  void fire<T>(T event) => streamController.add(event);

  void destroy() => _streamController.close();
}

typedef EventSub<T> = StreamSubscription<T>;
