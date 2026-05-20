part of 'item_cart_widget.dart';

class ItemCartModel {
  final int itemId;
  final int cartQuantity;
  final PItem item;
  final List<PItemVariation> variations;
  final Map<int, List<ModifierOption>>? modifierOptions;
  final String? instrctions;

  ItemCartModel({
    this.cartQuantity = 0,
    required this.item,
    this.variations = const [],
    this.modifierOptions,
    this.instrctions,
  }) : itemId = item.id!;

  num get totalPrice {
    final _itemType = ItemTypeEnum.fromString(item.priceType);

    final basePrice = _itemType.isVariation
        ? variations.fold<num>(0, (p, eV) => p + (eV.price ?? 0))
        : (item.salesPrice ?? 0);

    final optionsSum = modifierOptions?.values.fold<num>(
      0,
      (sumGroup, options) {
        final groupSum = options.fold<num>(
          0,
          (sumOpt, opt) => sumOpt + (opt.price ?? 0),
        );
        return sumGroup + groupSum;
      },
    );

    return (basePrice + (optionsSum ?? 0)) * cartQuantity;
  }

  ItemCartModel copyWith({
    int? cartQuantity,
    num? totalPrice,
    PItem? item,
    List<PItemVariation>? variations,
    Map<int, List<ModifierOption>>? modifierOptions,
    String? instrctions,
  }) {
    return ItemCartModel(
      cartQuantity: cartQuantity ?? this.cartQuantity,
      item: item ?? this.item,
      variations: variations ?? this.variations,
      modifierOptions: modifierOptions ?? this.modifierOptions,
      instrctions: instrctions ?? this.instrctions,
    );
  }

  @override
  String toString() {
    return '''
      ItemCartModel(
      itemId: $itemId,
      cartQuantity: $cartQuantity,
      item: ${item.toString()},
      variations: ${variations.toString()},
      modifierOptions: ${modifierOptions.toString()},
      instrctions: $instrctions,
    )
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ItemCartModel &&
            runtimeType == other.runtimeType &&
            itemId == other.itemId &&
            cartQuantity == other.cartQuantity;
  }

  @override
  int get hashCode => Object.hash(itemId, cartQuantity);
}

typedef CartAmountOverview = ({num totalAmount, int totalQuantity});
