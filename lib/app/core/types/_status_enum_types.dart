import 'package:flutter/material.dart';

import '../../../i18n/strings.g.dart';
import '../core.dart';

enum TableStatus {
  hold(statusColor: Color(0xff5856D6)),
  empty(statusColor: DAppColors.kSuccess);

  final Color? statusColor;
  const TableStatus({this.statusColor});

  String label(BuildContext context) {
    return switch (this) {
      TableStatus.hold => context.t.enums.tableStatus.running,
      TableStatus.empty => context.t.enums.tableStatus.available,
    };
  }

  bool get isHold => this == TableStatus.hold;
  bool get isEmpty => this == TableStatus.empty;

  static TableStatus fromID(int? id) {
    return switch (id) {
      1 => TableStatus.hold,
      0 || _ => TableStatus.empty,
    };
  }
}

//----------------------Printer Settings----------------------//
enum ThermalPrinterPrintingMethod {
  kDefault,
  image;

  String label(BuildContext context) {
    return switch (this) {
      image => context.t.enums.thermalPrinterPrintingMethod.image,
      kDefault => context.t.enums.thermalPrinterPrintingMethod.kDefault,
    };
  }

  static ThermalPrinterPrintingMethod fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'image' => ThermalPrinterPrintingMethod.image,
      'default' => ThermalPrinterPrintingMethod.kDefault,
      _ => ThermalPrinterPrintingMethod.kDefault,
    };
  }
}

enum ThermalPrinterPaperSize {
  mm803Inch,
  mm582Inch;

  static ThermalPrinterPaperSize? maybeFromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      '3_inch_80_mm' => mm803Inch,
      '2_inch_58_mm' => mm582Inch,
      _ => null,
    };
  }

  static ThermalPrinterPaperSize fromString(String? value) {
    return maybeFromString(value) ?? mm803Inch;
  }

  String get stringValue {
    return switch (this) {
      mm803Inch => '3_inch_80_mm',
      mm582Inch => '2_inch_58_mm',
    };
  }

  String label(BuildContext context) {
    return switch (this) {
      mm582Inch => '2Inch 58mm',
      mm803Inch => '3Inch 80mm',
    };
  }
}
//----------------------Printer Settings----------------------//

//----------------------StaffType----------------------//
abstract class StaffTypeInterface {
  String label(BuildContext context);
  String get stringValue;
}

enum StaffTypeEnum implements StaffTypeInterface {
  manager,
  waiter,
  chefs,
  kitchen,
  cleaner,
  driver,
  deliveryBoy;

  @override
  String label(BuildContext context) {
    return switch (this) {
      manager => context.t.enums.staffTypes.manager,
      waiter => context.t.enums.staffTypes.waiter,
      chefs => context.t.enums.staffTypes.chef,
      kitchen => context.t.common.kitchen(n: 1),
      cleaner => context.t.enums.staffTypes.cleaner,
      driver => context.t.enums.staffTypes.driver,
      deliveryBoy => context.t.enums.staffTypes.deliveryBoy,
    };
  }

  static StaffTypeEnum fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'manager' => StaffTypeEnum.manager,
      'waiter' => StaffTypeEnum.waiter,
      'chef' => StaffTypeEnum.chefs,
      'kitchen' => StaffTypeEnum.kitchen,
      'cleaner' => StaffTypeEnum.cleaner,
      'driver' => StaffTypeEnum.driver,
      'delivery_boy' => StaffTypeEnum.deliveryBoy,
      _ => StaffTypeEnum.waiter,
    };
  }

  @override
  String get stringValue {
    return switch (this) {
      manager => 'manager',
      waiter => 'waiter',
      chefs => 'chef',
      kitchen => 'kitchen',
      cleaner => 'cleaner',
      driver => 'driver',
      deliveryBoy => 'delivery_boy',
    };
  }
}
//----------------------StaffType----------------------//

enum ItemFoodTypeEnum {
  veg,
  nonVeg,
  egg,
  drink,
  others;

  String label(BuildContext context) {
    return switch (this) {
      veg => t.enums.itemFoodTypes.veg,
      nonVeg => t.enums.itemFoodTypes.nonVeg,
      egg => t.enums.itemFoodTypes.egg,
      drink => t.enums.itemFoodTypes.drink,
      others => t.enums.itemFoodTypes.others,
    };
  }

  static ItemFoodTypeEnum fromString(String? value) {
    return maybeFromString(value) ?? ItemFoodTypeEnum.veg;
  }

  static ItemFoodTypeEnum? maybeFromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'veg' => ItemFoodTypeEnum.veg,
      'non_veg' => ItemFoodTypeEnum.nonVeg,
      'egg' => ItemFoodTypeEnum.egg,
      'drink' => ItemFoodTypeEnum.drink,
      'others' => ItemFoodTypeEnum.others,
      _ => null,
    };
  }

  String get stringValue {
    return switch (this) {
      veg => 'veg',
      nonVeg => 'non_veg',
      egg => 'egg',
      drink => 'drink',
      others => 'others',
    };
  }
}

enum ItemTypeEnum {
  single,
  variation;

  bool get isVariation => this == ItemTypeEnum.variation;

  String label(BuildContext context) {
    return switch (this) {
      single => t.enums.itemTypes.single,
      variation => t.enums.itemTypes.variation,
    };
  }

  static ItemTypeEnum fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'single' => ItemTypeEnum.single,
      'variation' => ItemTypeEnum.variation,
      _ => ItemTypeEnum.single,
    };
  }

  String get stringValue {
    return switch (this) {
      single => 'single',
      variation => 'variation',
    };
  }
}

enum UserRole {
  shopOwner,
  staff,
  chef,
  kitchen;

  static UserRole fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'shop-owner' => UserRole.shopOwner,
      'staff' => UserRole.staff,
      'chef' => UserRole.chef,
      'kitchen' => UserRole.kitchen,
      _ => UserRole.shopOwner,
    };
  }

  bool get isShopOwner => this == shopOwner;
  bool get isKitchenOrChef => this == chef || this == kitchen;
}

enum KotOrderStatus {
  pending,
  preparing,
  ready,
  served,
  cancelled;

  static List<KotOrderStatus> get orderListTabs {
    return [
      KotOrderStatus.pending,
      KotOrderStatus.preparing,
      KotOrderStatus.ready,
      KotOrderStatus.cancelled,
    ];
  }

  String label(BuildContext context) {
    return switch (this) {
      KotOrderStatus.pending => context.t.enums.kotOrderStatus.pending,
      KotOrderStatus.preparing => context.t.enums.kotOrderStatus.preparing,
      KotOrderStatus.ready => context.t.enums.kotOrderStatus.ready,
      KotOrderStatus.served => context.t.enums.kotOrderStatus.served,
      KotOrderStatus.cancelled => context.t.enums.kotOrderStatus.cancelled,
    };
  }

  String buttonLabel(BuildContext context) {
    return switch (this) {
      KotOrderStatus.pending => context.t.enums.kotOrderStatus.preparing,
      KotOrderStatus.preparing => context.t.enums.kotOrderStatus.ready,
      KotOrderStatus.ready => context.t.enums.kotOrderStatus.served,
      KotOrderStatus.cancelled => context.t.enums.kotOrderStatus.cancelled,
      _ => '',
    };
  }

  String get stringValue {
    return switch (this) {
      pending => 'pending',
      preparing => 'preparing',
      ready => 'ready',
      served => 'served',
      cancelled => 'cancelled',
    };
  }

  static KotOrderStatus fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'pending' => KotOrderStatus.pending,
      'preparing' => KotOrderStatus.preparing,
      'ready' => KotOrderStatus.ready,
      'served' => KotOrderStatus.served,
      'cancelled' => KotOrderStatus.cancelled,
      _ => KotOrderStatus.pending,
    };
  }

  Color? get statusColor {
    return switch (this) {
      KotOrderStatus.pending => const Color(0xffFC8019),
      KotOrderStatus.preparing => const Color(0xff6155F5),
      KotOrderStatus.ready => const Color(0xff00AC2B),
      KotOrderStatus.cancelled => const Color(0xffFF383C),
      _ => null,
    };
  }
}

enum KotItemStatus {
  pending,
  start,
  ready;

  String get stringValue {
    return switch (this) {
      pending => 'pending',
      start => 'start',
      ready => 'ready',
    };
  }

  static KotItemStatus fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'pending' => KotItemStatus.pending,
      'start' => KotItemStatus.start,
      'ready' => KotItemStatus.ready,
      _ => KotItemStatus.pending,
    };
  }

  Color get buttonColor {
    return switch (this) {
      KotItemStatus.pending => const Color(0xffFC8019),
      KotItemStatus.start => const Color(0xff00932C),
      KotItemStatus.ready => const Color(0xff00932C),
    };
  }

  String buttonLabel(BuildContext context) {
    return switch (this) {
      KotItemStatus.pending => context.t.enums.kotItemStatus.pending,
      KotItemStatus.start => context.t.enums.kotItemStatus.start,
      KotItemStatus.ready => context.t.enums.kotItemStatus.ready,
    };
  }
}
