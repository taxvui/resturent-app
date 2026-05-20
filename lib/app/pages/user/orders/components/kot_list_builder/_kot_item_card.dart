part of '_kot_list_builder.dart';

class KotTicketCard extends StatelessWidget {
  const KotTicketCard.indexed({
    super.key,
    required this.index,
    required this.data,
    this.onOrderStatusChanged,
    this.onItemStatusChanged,
    this.onCancelled,
    this.onPrint,
    this.showActions = true,
  });
  final int index;
  final model.KOTOrder data;

  final ValueChanged<({int id, KotOrderStatus status})>? onOrderStatusChanged;
  final ValueChanged<({int id, KotItemStatus status})>? onItemStatusChanged;
  final VoidCallback? onCancelled;
  final VoidCallback? onPrint;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.fromBorderSide(Divider.createBorderSide(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice Number
          DefaultTextStyle.merge(
            style: _theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            child: Row(
              children: [
                // KOT Order Id
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${context.t.common.kot}: ',
                      children: [
                        TextSpan(
                          text: data.kotInvoiceNumber ?? "N/A",
                          style: TextStyle(color: _theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),

                // Order Id
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${context.t.common.order}: ',
                      children: [TextSpan(text: data.invoiceNumber ?? "N/A")],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox.square(dimension: 2),

          // Items and Order Date
          DefaultTextStyle.merge(
            style: _theme.textTheme.bodyLarge,
            child: Row(
              children: [
                // Item Count
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${context.t.common.items}: ',
                      children: [TextSpan(text: data.itemCount.commaSeparated())],
                    ),
                  ),
                ),

                // Order Date
                Expanded(
                  child: Text(
                    data.saleDate?.getFormatedString(pattern: 'dd/MM/yyyy hh:mm a') ?? "N/A",
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox.square(dimension: 2),

          // Table & Customer Name
          DefaultTextStyle.merge(
            style: _theme.textTheme.bodyLarge,
            child: Row(
              children: [
                // Table
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${context.t.common.table}: ',
                      children: [TextSpan(text: data.kotTable?.name ?? "N/A")],
                    ),
                  ),
                ),

                // Customer
                Flexible(
                  flex: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.person_outline_rounded, size: 18),
                      const SizedBox.square(dimension: 2),
                      Flexible(
                        flex: 0,
                        child: Text(
                          data.party?.name ?? "Guest",
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Online Indicator
          if (data.isOnlineOrder) ...[
            Row(
              children: [
                Container(
                  constraints: BoxConstraints.tight(Size.square(8)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox.square(dimension: 4),

                Expanded(
                  child: Text(
                    context.t.common.online,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _theme.paragraphColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox.square(dimension: 8),

          // Items
          KotItemBuilder(
            initiallyExpanded: index == 0,
            onStatusChanged: data.orderStatus == KotOrderStatus.cancelled ? null : onItemStatusChanged,
            items: [...?data.details],
          ),
          const SizedBox.square(dimension: 10),

          // Cancel Reason
          if (data.orderStatus == KotOrderStatus.cancelled) ...[
            Text(
              context.t.common.cancelledReason,
              style: _theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox.square(dimension: 6),
            Text(
              data.cancelReason ?? "N/A",
              style: _theme.textTheme.bodyLarge,
            ),
          ],

          // Action Button
          if (showActions) ...[
            Row(
              spacing: 14,
              children: [
                Expanded(
                  child: SizedBox.fromSize(
                    size: Size.fromHeight(40),
                    child: data.orderStatus == KotOrderStatus.cancelled
                        ? null
                        : OutlinedButton(
                            onPressed: onCancelled,
                            style: CustomButtonStyles.destructiveOutline(),
                            child: Text(context.t.action.cancel),
                          ),
                  ),
                ),
                Expanded(
                  child: SizedBox.fromSize(
                    size: Size.fromHeight(40),
                    child: data.orderStatus == KotOrderStatus.cancelled
                        ? null
                        : ElevatedButton(
                            onPressed: _handleStatusButton(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            child: Text(data.orderStatus.buttonLabel(context)),
                          ),
                  ),
                ),

                SizedBox.fromSize(
                  size: Size.square(40),
                  child: OutlinedButton(
                    onPressed: onPrint,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: const Color(0xff6155F5),
                      side: Divider.createBorderSide(
                        context,
                        color: const Color(0xff6155F5),
                      ),
                    ),
                    child: const Icon(Icons.print_outlined),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void Function()? _handleStatusButton() {
    if (onOrderStatusChanged == null) return null;

    return () {
      final _status = switch (data.orderStatus) {
        KotOrderStatus.pending => KotOrderStatus.preparing,
        KotOrderStatus.preparing => KotOrderStatus.ready,
        KotOrderStatus.ready => KotOrderStatus.served,
        KotOrderStatus.served => KotOrderStatus.served,
        _ => null,
      };

      if (_status != null) {
        return onOrderStatusChanged!((id: data.id!, status: _status));
      }
    };
  }
}

class KotItemBuilder extends StatelessWidget {
  const KotItemBuilder({
    super.key,
    this.initiallyExpanded = false,
    required this.items,
    this.onStatusChanged,
  });

  final bool initiallyExpanded;
  final List<model.KOTOrderItem> items;
  final ValueChanged<({int id, KotItemStatus status})>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffEFEFF5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ExpansionWidget(
        initiallyExpanded: initiallyExpanded,
        titleBuilder: (aV, eV, iE, tF) {
          return InkWell(
            onTap: () => tF(animated: true),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffF8F8F8),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(6),
                  bottom: iE ? Radius.zero : Radius.circular(6),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t.form.items.itemName.label,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    iE ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: _theme.paragraphColor,
                  ),
                ],
              ),
            ),
          );
        },
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            final _item = items[index];
            final _isLastItem = index == items.length - 1;

            final _label1 = [
              ?ItemFoodTypeEnum.maybeFromString(_item.product?.foodType)?.label(context),
              ..._item.variations.map((e) => e.name),
            ];
            final _label2 = _item.saleItemOptions?.fold<Map<String, List<String>>>({}, (map, ev) {
              if (ev.name == null || ev.modifierGroupOption?.name == null) return map;
              (map[ev.name!] ??= []).add(ev.modifierGroupOption!.name!);
              return map;
            });

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(bottom: _isLastItem ? BorderSide.none : Divider.createBorderSide(context)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${(_item.quantities ?? 0).commaSeparated()}x ${_item.product?.productName ?? "N/A"}'),
                        if (_label1.isNotEmpty) ...[
                          Text(
                            _label1.whereType<String>().join(' - '),
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              color: _theme.paragraphColor,
                            ),
                          ),
                        ],

                        if (_label2 != null && _label2.isNotEmpty) ...[
                          ..._label2.entries.map((option) {
                            return Text(
                              "${option.key}: ${option.value.join(', ')}",
                              style: _theme.textTheme.bodyMedium?.copyWith(
                                color: _theme.paragraphColor,
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  if (onStatusChanged != null) ...[
                    OutlinedButton.icon(
                      onPressed: _handleStatusButton(_item),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity,
                        ),
                        side: Divider.createBorderSide(context, color: _item.status.buttonColor),
                        disabledForegroundColor: _item.status.buttonColor,
                        foregroundColor: _item.status.buttonColor,
                        textStyle: _theme.textTheme.bodySmall,
                        iconSize: 16,
                      ),
                      label: Text(_item.status.buttonLabel(context)),
                      icon: _item.status == KotItemStatus.start ? const Icon(Icons.check) : null,
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  void Function()? _handleStatusButton(model.KOTOrderItem data) {
    if (data.status == KotItemStatus.ready) return null;

    return () {
      final _newStatus = switch (data.status) {
        KotItemStatus.pending => KotItemStatus.start,
        KotItemStatus.start => KotItemStatus.ready,
        KotItemStatus.ready => KotItemStatus.ready,
      };
      return onStatusChanged?.call((id: data.id!, status: _newStatus));
    };
  }
}
