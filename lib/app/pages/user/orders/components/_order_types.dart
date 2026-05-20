import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_pos/i18n/strings.g.dart';

import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';
import '../manage_order/manage_order_notifier_base.dart';

abstract class OrderTypeWidgetBase extends ConsumerWidget {
  const OrderTypeWidgetBase({super.key, required this.notifier});
  final ManageOrderViewNotifier notifier;

  double get fieldHeight => 45;

  Widget get customerDropdown {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.watch(notifier);
        final _customerListAsync = ref.watch(customerDropdownProvider);

        return SizedBox(
          height: fieldHeight,
          child: AsyncCustomDropdown<int, PartyList>(
            asyncData: _customerListAsync,
            decoration: InputDecoration(
              // hintText: 'Select customer',
              hintText: context.t.form.sales.customer.hint,
              suffixIcon: IconButton.filled(
                onPressed: () async {
                  if (ref.canSnackbar(context, PMKeys.parties, action: PermissionAction.create)) {
                    final _result = await context.router.push<Party?>(
                      ManagePartyRoute(),
                    );
                    if (_result != null && _result.type == 'customer') {
                      controller.handleDropdownChange(
                        MapEntry('customer_id', _result.id),
                      );
                    }
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xffF0F0F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.horizontal(
                      end: const Radius.circular(3),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add),
              ).fMarginSymmetric(horizontal: 0.425, vertical: 1),
            ),
            value: controller.dropdownValues['customer_id'],
            items: _customerListAsync.when(
              data: (data) => [
                ...?data.data?.data?.map((customer) {
                  return CustomDropdownMenuItem<int>(
                    value: customer.id,
                    label: TextSpan(text: customer.name ?? "N/A"),
                  );
                }),
              ],
              error: (e, s) => [],
              loading: () => [],
            ),
            showClearButton: true,
            onChanged: (value) {
              controller.handleDropdownChange(
                MapEntry('delivery_address_id', null),
              );
              return controller.handleDropdownChange(
                MapEntry('customer_id', value),
              );
            },
            onRefresh: () => ref.refresh(customerDropdownProvider),
          ),
        );
      },
    );
  }

  Widget get tableDropdown {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.watch(notifier);
        final _tableListAsync = ref.watch(tableDropdownProvider);

        return SizedBox(
          height: fieldHeight,
          child: AsyncCustomDropdown<int, TableList>(
            asyncData: _tableListAsync,
            decoration: InputDecoration(
              // hintText: 'Select Table',
              hintText: context.t.form.sales.table.hint,
            ),
            value: controller.dropdownValues['table_id'],
            items: _tableListAsync.when(
              data: (data) {
                return [
                  CustomDropdownMenuItem.navigator(
                    label: '#',
                    // navLabel: '+ Add New',
                    navLabel: '+ ${context.t.common.addNew}',
                    onNavTap: () async {
                      if (ref.canSnackbar(context, PMKeys.tables, action: PermissionAction.create)) {
                        return await context.router.push<void>(
                          TableListRoute(),
                        );
                      }
                    },
                  ),
                  ...?data.data?.data?.map((table) {
                    return CustomDropdownMenuItem(
                      value: table.id,
                      label: TextSpan(
                        text: table.name ?? "N/A",
                        children: [
                          if (table.status.isHold)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                margin: const EdgeInsetsDirectional.only(
                                  start: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: table.status.statusColor?.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  table.status.label(context),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: table.status.statusColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ];
              },
              error: (_, _) => [],
              loading: () => [],
            ),
            onChanged: (value) {
              return controller.handleDropdownChange(
                MapEntry('table_id', value),
              );
            },
            onRefresh: () => ref.refresh(tableDropdownProvider),
          ),
        );
      },
    );
  }
}

class DineIn extends OrderTypeWidgetBase {
  const DineIn({super.key, required super.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notifier);
    final waiterListAsync = ref.watch(waiterDropdownProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Waiter Dropdown
            Expanded(
              child: SizedBox(
                height: fieldHeight,
                child: AsyncCustomDropdown<int, StaffList>(
                  asyncData: waiterListAsync,
                  decoration: InputDecoration(
                    // hintText: 'Select Waiter',
                    hintText: context.t.form.sales.waiter.hint,
                  ),
                  value: controller.dropdownValues['waiter_id'],
                  items: waiterListAsync.when(
                    data: (data) => [
                      CustomDropdownMenuItem.navigator(
                        label: '#',
                        // navLabel: '+ Add New',
                        navLabel: '+ ${context.t.common.addNew}',
                        onNavTap: () async {
                          if (ref.canSnackbar(context, PMKeys.staff, action: PermissionAction.create)) {
                            return await context.router.push<void>(
                              StaffListRoute(),
                            );
                          }
                        },
                      ),
                      ...?data.data?.data?.map((waiter) {
                        return CustomDropdownMenuItem(
                          value: waiter.id,
                          label: TextSpan(text: waiter.name ?? "N/A"),
                        );
                      }),
                    ],
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: (value) {
                    return controller.handleDropdownChange(
                      MapEntry('waiter_id', value),
                    );
                  },
                  onRefresh: () => ref.refresh(waiterDropdownProvider),
                ),
              ),
            ),
            const SizedBox.square(dimension: 10),

            // Table Dropdown
            Expanded(child: tableDropdown),
          ],
        ),
        const SizedBox.square(dimension: 10),

        // Customer Dropdown
        SizedBox(
          height: fieldHeight,
          child: customerDropdown,
        ),
      ],
    );
  }
}

class PickUp extends OrderTypeWidgetBase {
  const PickUp({super.key, required super.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class Delivery extends OrderTypeWidgetBase {
  const Delivery({super.key, required super.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notifier);
    final partyAddresses = ref.watch(
      partyAddressesProvider(controller.dropdownValues['customer_id']),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Customer Dropdown
        Row(
          children: [
            Flexible(
              flex: 4,
              child: SizedBox(
                height: fieldHeight,
                child: NumberFormField(
                  controller: controller.deliveryChargeController,
                  decoration: InputDecoration(
                    // hintText: 'Charge Ex: \$10',
                    hintText: context.t.form.sales.deliveryCharge.hint2,
                  ),
                ),
              ),
            ),
            const SizedBox.square(dimension: 10),
            Expanded(flex: 6, child: customerDropdown),
          ],
        ),
        const SizedBox.square(dimension: 10),

        // Address Dropdown
        SizedBox(
          height: fieldHeight,
          child: AsyncCustomDropdown<int, List<DeliveryAddress>>(
            asyncData: partyAddresses,
            decoration: InputDecoration(
              // hintText: 'Select address',
              hintText: context.t.form.address.hint,
              suffixIcon: IconButton.filled(
                onPressed: () async {
                  if (ref.canSnackbar(context, PMKeys.parties, action: PermissionAction.create) ||
                      ref.canSnackbar(context, PMKeys.parties, action: PermissionAction.update)) {
                    return _handleAddNewAddress(context, ref);
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xffF0F0F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.horizontal(
                      end: const Radius.circular(3),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add),
              ).fMarginSymmetric(horizontal: 0.425, vertical: 1),
            ),
            value: controller.dropdownValues['delivery_address_id'],
            items: partyAddresses.when(
              data: (data) {
                return [
                  ...data.map((deliveryAddress) {
                    return CustomDropdownMenuItem(
                      value: deliveryAddress.id,
                      label: TextSpan(
                        text: deliveryAddress.address ?? "N/A",
                      ),
                    );
                  }),
                ];
              },
              error: (_, _) => [],
              loading: () => [],
            ),
            showClearButton: true,
            onChanged: (value) {
              return controller.handleDropdownChange(
                MapEntry('delivery_address_id', value),
              );
            },
            onRefresh: () => ref.invalidate(partyAddressesProvider),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddNewAddress(BuildContext context, WidgetRef ref) async {
    final _partyId = ref.read(notifier).dropdownValues['customer_id'] as int?;

    if (_partyId == null) {
      showCustomSnackBar(
        context,
        // content: const Text('Please select a customer first.'),
        content: Text(context.t.exceptions.pleaseSelectACustomerFirst),
        customSnackBarType: CustomOverlayType.info,
      );
      return;
    }

    return showManageCustomerAddressModal(
      context,
      onSave: (context, data) async {
        final _result = await showAsyncLoadingOverlay(
          context,
          asyncFunction: () => ref
              .read(partyRepoProvider)
              .createCustomerDeliveryAddress(
                DeliveryAddress(
                  name: data.name,
                  phone: data.phone,
                  partyId: _partyId,
                  address: data.address,
                ),
              ),
        );

        if (context.mounted) {
          Navigator.of(context).pop();

          if (_result.isFailure) {
            showCustomSnackBar(
              context,
              content: Text(_result.left!),
              customSnackBarType: CustomOverlayType.error,
            );
            return;
          }

          showCustomSnackBar(
            context,
            content: const Text('Address added successfully.'),
            customSnackBarType: CustomOverlayType.success,
          );

          ref
              .read(notifier)
              .handleDropdownChange(
                MapEntry(
                  'delivery_address_id',
                  _result.right?.id,
                ),
              );
        }
      },
    );
  }
}

final partyAddressesProvider = FutureProvider.autoDispose.family<List<DeliveryAddress>, int?>((ref, customerId) async {
  final dropdownAsync = await ref.watch(customerDropdownProvider.future);
  final party = dropdownAsync.data?.data?.firstWhereOrNull((e) => e.id == customerId);

  return party?.deliveryAddresses ?? <DeliveryAddress>[];
});

class Reservation extends OrderTypeWidgetBase {
  const Reservation({super.key, required super.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Table Dropdown
        tableDropdown,
        const SizedBox.square(dimension: 10),

        // Customer Dropdown
        customerDropdown,
      ],
    );
  }
}

class OrderQuotation extends OrderTypeWidgetBase {
  const OrderQuotation({super.key, required super.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return customerDropdown;
  }
}

enum OrderTypeEnum {
  dineIn,
  pickUp,
  delivery,
  reservation,
  orderQuotation;

  String label(BuildContext context) {
    return switch (this) {
      // dineIn => 'Dine In',
      dineIn => context.t.enums.orderTypes.dineIn,
      // pickUp => 'Pick Up',
      pickUp => context.t.enums.orderTypes.pickUp,
      // delivery => 'Delivery',
      delivery => context.t.enums.orderTypes.delivery,
      // reservation => 'Reservation',
      reservation => context.t.enums.orderTypes.reservation,
      // orderQuotation => 'Order Quotation',
      orderQuotation => context.t.enums.orderTypes.quotation,
    };
  }

  static OrderTypeEnum? maybeFromString(String? value) {
    return switch (value) {
      'dine_in' => dineIn,
      'pick_up' => pickUp,
      'delivery' => delivery,
      'reservation' => reservation,
      'order_quotation' => orderQuotation,
      _ => null,
    };
  }

  static OrderTypeEnum fromString(String? value) {
    return maybeFromString(value) ?? dineIn;
  }

  String get stringValue {
    return switch (this) {
      dineIn => 'dine_in',
      pickUp => 'pick_up',
      delivery => 'delivery',
      reservation => 'reservation',
      orderQuotation => 'order_quotation',
    };
  }

  OrderTypeWidgetBase childBuilder(ManageOrderViewNotifier notifier) {
    return switch (this) {
      dineIn => DineIn(notifier: notifier),
      pickUp => PickUp(notifier: notifier),
      delivery => Delivery(notifier: notifier),
      reservation => Reservation(notifier: notifier),
      orderQuotation => OrderQuotation(notifier: notifier),
    };
  }
}
