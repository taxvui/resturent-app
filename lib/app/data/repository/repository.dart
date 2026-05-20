import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/services.dart';

// Dependency Export
export 'dart:io';
export 'dart:async' hide AsyncError;
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:fdevs_fitkit/fdevs_fitkit.dart' show Either;
export '../../core/core.dart' show DAPIEndpoints, DAppSPrefsKeys;
export 'package:flutter/foundation.dart' show mapEquals;
export 'package:collection/collection.dart';
export '../../services/services.dart';
export '../model/model.dart';

// Repository Export
export 'user_repo/_user_repo.dart';
export 'items_repo/_items_repo.dart';
export 'ingredient_repo/_ingredient_repo.dart';
export 'party_repo/_party_repo.dart';
export 'tax_repo/_tax_repo.dart';
export 'income_repo/_income_repo.dart';
export 'expense_repo/_expense_repo.dart';
export 'table_repo/_table_repo.dart';
export 'sale_repo/_sale_repo.dart';
export 'purchase_repo/_purchase_repo.dart';
export 'common_repo/_common_repo.dart';
export 'business_payment_method/_business_payment_method_repo.dart';
export 'due_repo/_due_repo.dart';
export 'staff_repo/_staff_repo.dart';
export 'coupon_repo/_coupon_repo.dart';
export 'hrm_repo/hrm_repo.dart';
export 'kitchen_repo/_kitchen_repo.dart';

abstract class BaseRepository {
  final Ref ref;
  final HTTPDioClient repoClient;
  final GlobalEventManager gEventListener;

  late final dioClient = repoClient.restClient;

  BaseRepository(
    this.ref, {
    bool putAuthHeader = false,
  }) : gEventListener = GlobalEventManager.I,
       repoClient = ref.read(httpDioClientProvider) {
    if (putAuthHeader) {
      dioClient.options.headers.addAll(
        repoClient.getAuthHeader,
      );
    }
  }
}

abstract class BaseApiEvent {
  const BaseApiEvent();
}
