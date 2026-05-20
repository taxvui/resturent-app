import 'dart:ui';

import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import '../core.dart';
export 'dart:io' show File;

class DynamicFileType {
  final Either<File?, String?> _either;
  final String? baseUrl;
  DynamicFileType({
    File? local,
    String? remote,
    this.baseUrl = DAPIEndpoints.baseURL,
  }) : _either = local != null ? Either.failure(local) : Either.success(remote);

  File? get local => _either.isFailure ? _either.left : null;
  String? get remote {
    return _either.isSuccess
        ? (_either.right == null
            ? null
            : baseUrl == null
                ? _either.right!
                : "$baseUrl/${_either.right!}")
        : null;
  }

  bool get isLocal => _either.isFailure;
  bool get isRemote => _either.isSuccess;
}

typedef SvgImageHolder = ({String svgPath, Color? baseColor});
