import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';

import '../../../../../core/core.dart';

class TaxRatesDataTable extends StatelessWidget {
  const TaxRatesDataTable({super.key, required this.data});
  final TaxRatesTableData data;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return DataTable(
      headingRowColor: WidgetStateProperty.all<Color>(
        _theme.colorScheme.secondary.withValues(alpha: 0.1),
      ),
      border: TableBorder.all(
        borderRadius: BorderRadius.circular(4),
        color: _theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
      headingRowHeight: 40,
      columns: [
        ...data.headers.map(
          (column) => DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Text.rich(
              column,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      rows: [
        ...data.rows.map(
          (row) => DataRow(
            cells: [
              ...row.map(
                (cell) => DataCell(
                  Text.rich(
                    cell,
                    style: _theme.textTheme.bodyMedium?.copyWith(
                      color: _theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static InlineSpan defaultActions({
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return WidgetSpan(
      child: Consumer(
        builder: (_, ref, _) {
          return Row(
            children: [
              IconButton(
                onPressed: ref.canT<VoidCallback?>(
                  PMKeys.vat,
                  action: PermissionAction.update,
                  input: onEdit,
                ),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
                icon: const Icon(IconlyLight.edit),
                color: DAppColors.kSuccess,
              ),
              const SizedBox.square(dimension: 4),
              IconButton(
                onPressed: ref.canT<VoidCallback?>(
                  PMKeys.vat,
                  action: PermissionAction.delete,
                  input: onDelete,
                ),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
                icon: const Icon(IconlyLight.delete),
                color: DAppColors.kError,
              ),
            ],
          );
        },
      ),
    );
  }
}

class TaxRatesTableData {
  final List<InlineSpan> headers;
  final List<List<InlineSpan>> rows;

  const TaxRatesTableData({
    required this.headers,
    required this.rows,
  });
}
