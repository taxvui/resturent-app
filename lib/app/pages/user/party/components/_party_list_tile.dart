import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';

class PartyListTile extends StatelessWidget {
  const PartyListTile({
    super.key,
    required this.data,
    this.onTap,
    this.trailing,
  });
  final PartyListTileData data;
  final void Function()? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: SizedBox.square(
        dimension: 48,
        child: UserAvatarPicker(
          showInitialsPlaceholder: true,
          userName: data.partyName,
          showBorder: false,
          backgroundColor: data.partyType.transactionType.color,
          foregroundColor: Colors.white,
          image: data.image,
          fit: BoxFit.fitHeight,
        ),
      ),
      horizontalTitleGap: 12,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 6,
            child: Text(
              data.partyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            flex: 3,
            child: Text(
              data.amount.quickCurrency(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      titleTextStyle: _theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(data.partyType.label(context)),
          Text(
            data.partyType.transactionType.label(context),
            style: TextStyle(
              color: data.partyType.transactionType.color,
            ),
          ),
        ],
      ),
      subtitleTextStyle: _theme.textTheme.bodyMedium?.copyWith(
        color: _theme.colorScheme.secondary,
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    );
  }
}

class PartyListTileData {
  final DynamicFileType? image;
  final String partyName;
  final num amount;
  final PartyType partyType;

  const PartyListTileData({
    this.image,
    required this.partyName,
    required this.amount,
    required this.partyType,
  });
}

enum PartyType {
  customer(transactionType: PartyTransactionType.moneyIn),
  supplier(transactionType: PartyTransactionType.moneyOut);

  String label(BuildContext context) {
    return switch (this) {
      // PartyType.customer => 'Customer',
      PartyType.customer => context.t.pages.parties.customer,
      // PartyType.supplier => 'Supplier',
      PartyType.supplier => context.t.pages.parties.supplier,
    };
  }

  final PartyTransactionType transactionType;
  const PartyType({required this.transactionType});

  static PartyType fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      "customer" => PartyType.customer,
      "supplier" => PartyType.supplier,
      _ => PartyType.customer,
    };
  }
}

enum PartyTransactionType {
  moneyIn(color: DAppColors.kSuccess),
  moneyOut(color: DAppColors.kError);

  String label(BuildContext context) {
    return switch (this) {
      // PartyTransactionType.moneyIn => 'Money In',
      PartyTransactionType.moneyIn => context.t.common.moneyIn,
      // PartyTransactionType.moneyOut => 'Money Out',
      PartyTransactionType.moneyOut => context.t.common.moneyOut,
    };
  }

  final Color? color;
  const PartyTransactionType({this.color});
}
