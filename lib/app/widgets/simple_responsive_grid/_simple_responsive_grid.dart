import 'package:flutter/material.dart';

class SimpleResponsiveGridRow extends StatelessWidget {
  final List<SimpleResponsiveGridCol> children;

  final int rowSegments;

  final double verticalSpacing;
  final double horizontalSpacing;
  final CrossAxisAlignment crossAxisAlignment;

  const SimpleResponsiveGridRow({
    super.key,
    required this.children,
    this.rowSegments = 12,
    this.verticalSpacing = 16,
    this.horizontalSpacing = 16,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : assert(rowSegments > 0);

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    var currentRow = <Widget>[];
    var accumulated = 0;

    for (var col in children) {
      if (accumulated + col.flex > rowSegments) {
        if (accumulated < rowSegments) {
          currentRow.add(Spacer(flex: rowSegments - accumulated));
        }
        rows.add(Row(
          crossAxisAlignment: crossAxisAlignment,
          spacing: horizontalSpacing,
          children: currentRow,
        ));
        currentRow = [];
        accumulated = 0;
      }
      currentRow.add(col);
      accumulated += col.flex;
    }

    if (currentRow.isNotEmpty) {
      if (accumulated < rowSegments) {
        currentRow.add(Spacer(flex: rowSegments - accumulated));
      }
      rows.add(Row(
        crossAxisAlignment: crossAxisAlignment,
        spacing: horizontalSpacing,
        children: currentRow,
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      spacing: verticalSpacing,
      children: rows,
    );
  }
}

class SimpleResponsiveGridCol extends StatelessWidget {
  const SimpleResponsiveGridCol({
    super.key,
    required this.flex,
    required this.child,
  }) : assert(flex > 0);

  final int flex;
  final Widget child;

  @override
  Widget build(BuildContext context) => Expanded(flex: flex, child: child);
}
