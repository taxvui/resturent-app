part of 'customer_address_modal.dart';

class CustomerAddressCard extends StatelessWidget {
  const CustomerAddressCard({
    super.key,
    required this.data,
    this.onEdit,
    this.onDelete,
  }) : _showActions = false;

  const CustomerAddressCard.action({
    super.key,
    required this.data,
    this.onEdit,
    this.onDelete,
  }) : _showActions = true;

  final CustomerAddressData data;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  final bool _showActions;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: _theme.colorScheme.secondary.withValues(
            alpha: 0.2,
          ),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(data.name ?? 'N/A'),
            titleTextStyle: _theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            subtitle: Text(data.phone ?? 'N/A'),
            subtitleTextStyle: _theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: _theme.paragraphColor,
            ),
            contentPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
            titleAlignment: ListTileTitleAlignment.top,
            trailing: !_showActions
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: const Icon(HugeIconsStroke.pencilEdit02),
                        color: DAppColors.kSuccess,
                      ),
                      IconButton(
                        onPressed: onDelete,
                        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: const Icon(HugeIconsStroke.delete03),
                        color: DAppColors.kError,
                      ),
                    ],
                  ),
          ),
          if (data.address != null) ...[
            Text(
              data.address ?? '',
              style: _theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: _theme.paragraphColor,
              ),
            ),
          ],
          const SizedBox.square(dimension: 10),
        ],
      ),
    );
  }
}
