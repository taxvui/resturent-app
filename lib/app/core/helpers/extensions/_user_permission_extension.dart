import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';

import '../../core.dart' show DAppSvgIcons;
import '../../../data/repository/repository.dart';

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userRepositoryProvider.select((async) => async.value));
});

enum PermissionAction { view, create, update, delete, viewAllData }

enum PMKeys {
  dashboard,
  parties,
  quotations,
  purchases,
  ingreditents,
  units,
  tables,
  areas,
  products,
  categories,
  menus,
  modifierGroups,
  itemModifiers,
  moneyIn,
  moneyOut,
  transactions,
  income,
  incomeCategory,
  expense,
  expenseCategory,
  coupon,
  vat,
  sales,
  kot,
  printingOption,
  currency,
  paymentMethod,
  salesReport,
  salesQuotationReport,
  purchaseReport,
  dueReport,
  dueCollectionReport,
  transactionReport,
  incomeReport,
  expenseReport,
  kotReport,
  planSubscription,
  dueCollection,
  staff,
  userRolePermission,
  department,
  designation,
  shift,
  employee,
  leaveType,
  leave,
  holiday,
  attendance,
  payroll,
  attendanceReport,
  payrollReport,
  leaveReport,
  kitchen,
}

final canModuleProvider = Provider.family<bool, _CanRequest>((ref, req) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  if (user.isShopOwner) return true;

  final permission = user.permissions?.modules[req.moduleKey];
  if (permission == null) return false;

  return switch (req.action) {
    PermissionAction.view => permission.view == true,
    PermissionAction.create => permission.create == true,
    PermissionAction.update => permission.update == true,
    PermissionAction.delete => permission.delete == true,
    PermissionAction.viewAllData => permission.viewAllData == true,
  };
});

class _CanRequest {
  final String moduleKey;
  final PermissionAction action;
  const _CanRequest(this.moduleKey, this.action);
}

extension UserRefX on WidgetRef {
  User? get user => watch(currentUserProvider);

  User? readUser() => read(currentUserProvider);

  bool can(PMKeys moduleKey, {PermissionAction action = PermissionAction.view}) {
    return watch(canModuleProvider(_CanRequest(moduleKey.name, action)));
  }

  bool canAny(List<PMKeys> moduleKeys, {PermissionAction action = PermissionAction.view}) {
    for (final key in moduleKeys) {
      if (can(key, action: action)) return true;
    }
    return false;
  }

  bool canSnackbar(
    BuildContext context,
    PMKeys moduleKey, {
    PermissionAction action = PermissionAction.view,
    String? deniedMessage,
    CustomOverlayType customSnackBarType = CustomOverlayType.info,
  }) {
    final _allowed = can(moduleKey, action: action);

    if (!_allowed) {
      showCustomSnackBar(
        context,
        content: Text(deniedMessage ?? "You don't have permission to ${action.name}."),
        customSnackBarType: customSnackBarType,
      );
    }

    return _allowed;
  }

  T? canT<T>(PMKeys moduleKey, {required T input, PermissionAction action = PermissionAction.view}) {
    return can(moduleKey, action: action) ? input : null;
  }
}

class PermissionGate extends ConsumerWidget {
  const PermissionGate._({
    super.key,
    required this.moduleKeys,
    required this.action,
    required this.child,
    this.fallback,
    required this.matchAny,
  });

  PermissionGate({
    Key? key,
    required PMKeys moduleKey,
    PermissionAction action = PermissionAction.view,
    required Widget child,
    Widget Function(PermissionAction action)? fallback,
  }) : this._(
         key: key,
         moduleKeys: [moduleKey],
         action: action,
         child: child,
         fallback: fallback,
         matchAny: false,
       );

  const PermissionGate.canAny({
    Key? key,
    required List<PMKeys> moduleKeys,
    PermissionAction action = PermissionAction.view,
    required Widget child,
    Widget Function(PermissionAction action)? fallback,
  }) : this._(
         key: key,
         moduleKeys: moduleKeys,
         action: action,
         child: child,
         fallback: fallback,
         matchAny: true,
       );

  final List<PMKeys> moduleKeys;
  final PermissionAction action;
  final Widget child;
  final Widget Function(PermissionAction action)? fallback;
  final bool matchAny;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = matchAny
        ? moduleKeys.any((key) => ref.can(key, action: action))
        : moduleKeys.every((key) => ref.can(key, action: action));

    if (hasPermission) return child;

    return fallback?.call(action) ?? const SizedBox.shrink();
  }

  static Widget Function(PermissionAction action) imageFallback({
    String Function(PermissionAction action)? message,
  }) {
    return (PermissionAction action) {
      return Builder(
        builder: (context) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UniversalImage(
                  DAppSvgIcons.permissionDenied.svgPath,
                  height: 130,
                ),
                const SizedBox.square(dimension: 14),
                Text(
                  message?.call(action) ?? 'Permission Required',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );
    };
  }
}

extension PermissionGateExt on Widget {
  Widget can(
    PMKeys moduleKey, {
    PermissionAction action = PermissionAction.view,
    Widget Function(PermissionAction action)? fallback,
  }) {
    return PermissionGate(
      moduleKey: moduleKey,
      action: action,
      fallback: fallback,
      child: this,
    );
  }
}
