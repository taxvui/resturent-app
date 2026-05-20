import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/model/model.dart';

class MoneyInMoneyOutChart extends StatelessWidget {
  const MoneyInMoneyOutChart({
    super.key,
    this.obscureValue = false,
    required this.chartData,
  });
  final bool obscureValue;

  final DashboardChart chartData;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _mqSize = MediaQuery.sizeOf(context);

    final maxYValue = (chartData.maxValue ?? 50.0).toDouble();

    final _maxWidth = (chartData.moneyIn?.length ?? 0) * 28 < _mqSize.width
        ? _mqSize.width
        : (chartData.moneyIn?.length ?? 0) * 28;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legeneds
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegend(
              _theme,
              label: TextSpan(
                text: '${context.t.common.moneyIn}: ',
                children: [
                  TextSpan(
                    text: getObscureValue(
                      (chartData.totalMoneyIn ?? 0).compactCurrency(),
                    ),
                    style: TextStyle(
                      color: _theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              color: DAppColors.kSuccess,
            ),
            _buildLegend(
              _theme,
              label: TextSpan(
                text: '${context.t.common.moneyOut}: ',
                children: [
                  TextSpan(
                    text: getObscureValue(
                      (chartData.totalMoneyOut ?? 0).compactCurrency(),
                    ),
                    style: TextStyle(
                      color: _theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              color: DAppColors.kWarning,
            ),
          ],
        ),
        const SizedBox.square(dimension: 16),

        // Chart
        Flexible(
          child: Skeleton.shade(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Titles
                SizedBox(
                  width: 40,
                  child: Column(
                    children: List.generate(6, (index) {
                      final value = maxYValue - (index * (maxYValue / 5));
                      return Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            value.compactNumber(),
                            style: _theme.textTheme.bodySmall?.copyWith(
                              color: _theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Chart
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.sizeOf(context).width,
                        maxWidth: _maxWidth.toDouble(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: maxYValue,
                          gridData: FlGridData(
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: _theme.colorScheme.outline.withValues(alpha: 0.25),
                                dashArray: [12, 4],
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: _hideSideLabel,
                            topTitles: _hideSideLabel,
                            leftTitles: _hideSideLabel,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 34,
                                getTitlesWidget: (value, meta) {
                                  if (value != value.toInt()) {
                                    return const SizedBox.shrink();
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      // _titles[value.toInt()] ?? '',
                                      chartData.moneyIn?[value.toInt()].date ?? 'N/A',
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                            ),
                            getTouchedSpotIndicator: (barData, spotIndexes) {
                              return spotIndexes.map((item) {
                                return TouchedSpotIndicatorData(
                                  const FlLine(color: Colors.transparent),
                                  FlDotData(
                                    getDotPainter: (p0, p1, p2, p3) {
                                      return FlDotCirclePainter(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                        strokeColor: p2.color ?? Colors.transparent,
                                      );
                                    },
                                  ),
                                );
                              }).toList();
                            },
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                ...?chartData.moneyOut?.asMap().entries.map(
                                  (entry) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.amount?.toDouble() ?? 0,
                                    );
                                  },
                                ),
                              ],
                              isCurved: true,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              color: DAppColors.kWarning,
                              belowBarData: _buildBelowBarData(DAppColors.kWarning),
                            ),
                            LineChartBarData(
                              spots: [
                                ...?chartData.moneyIn?.asMap().entries.map(
                                  (entry) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.amount?.toDouble() ?? 0,
                                    );
                                  },
                                ),
                              ],
                              isCurved: true,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              color: DAppColors.kSuccess,
                              belowBarData: _buildBelowBarData(
                                DAppColors.kSuccess,
                              ),
                            ),
                          ],
                          clipData: const FlClipData.all(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String getObscureValue<T>(T value) {
    return obscureValue ? value.toString().obscure : value.toString();
  }

  Widget _buildLegend(
    ThemeData theme, {
    required TextSpan label,
    required Color color,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            child: Icon(
              Icons.circle,
              size: 16,
              color: color,
            ).fMarginOnly(right: 4),
          ),
          label,
        ],
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.secondary,
      ),
    );
  }

  final _hideSideLabel = const AxisTitles(
    sideTitles: SideTitles(
      showTitles: false,
    ),
  );

  BarAreaData _buildBelowBarData(Color color) {
    return BarAreaData(
      show: true,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.10),
        ],
      ),
    );
  }
}
