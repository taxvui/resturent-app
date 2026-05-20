part of '_coupon_list.dart';

class CouponCardWidget extends StatelessWidget {
  const CouponCardWidget({
    super.key,
    this.seedColor = const Color(0xff00932C),
    required this.data,
    this.actionButton,
  });

  final CouponCardData data;
  final Color seedColor;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CustomPaint(
        painter: CouponCardShape(
          seedColor: seedColor.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            // Discount Amount
            SizedBox(
              width: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.isPercentage ? '${data.discount ?? 0}%' : (data.discount ?? 0).compactCurrency(),
                    style: _theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: seedColor,
                    ),
                  ),
                  Text(
                    'Discount',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _theme.textTheme.bodyMedium?.copyWith(
                      color: _theme.paragraphColor,
                    ),
                  ),
                ],
              ),
            ),

            // Coupon Info
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      data.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox.square(dimension: 2),

                    // Description
                    if (data.subtitle != null) ...[
                      Text(
                        data.subtitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          color: _theme.paragraphColor,
                        ),
                      ),
                      const SizedBox.square(dimension: 10),
                    ],
                    // Date
                    Text(
                      _dateLabel,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: data.isExpired ? DAppColors.kError : _theme.paragraphColor,
                      ),
                    ),
                    const SizedBox.square(dimension: 4),

                    // Code & Action
                    Row(
                      children: [
                        // Code
                        Expanded(
                          child: Text(
                            'Code: ${data.code ?? "N/A"}',
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Action Button
                        ?actionButton,
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String get _dateLabel {
    String formatter(DateTime dt) => dt.getFormatedString(pattern: 'dd MMMM yyyy');
    if (!data.isStarted) {
      return 'Starts: ${data.startDate != null ? formatter(data.startDate!) : "N/A"}';
    }
    if (data.isOnGoing) {
      return 'Till: ${data.endDate != null ? formatter(data.endDate!) : "N/A"}';
    }
    return 'Expired: ${data.endDate != null ? formatter(data.endDate!) : "N/A"}';
  }
}

class CouponCardShape extends CustomPainter {
  const CouponCardShape({required this.seedColor});
  final Color seedColor;
  @override
  void paint(Canvas canvas, Size size) {
    Path path0 = Path();
    path0.moveTo(size.width * 0.2287738, 0);
    path0.cubicTo(
      size.width * 0.2323976,
      size.height * 0.04496842,
      size.width * 0.2452147,
      size.height * 0.07820642,
      size.width * 0.2604712,
      size.height * 0.07820642,
    );
    path0.cubicTo(
      size.width * 0.2757277,
      size.height * 0.07820642,
      size.width * 0.2885445,
      size.height * 0.04496842,
      size.width * 0.2921675,
      0,
    );
    path0.lineTo(size.width, 0);
    path0.lineTo(size.width, size.height);
    path0.lineTo(size.width * 0.2890445, size.height);
    path0.cubicTo(
      size.width * 0.2834476,
      size.height * 0.9681417,
      size.width * 0.2727539,
      size.height * 0.9465917,
      size.width * 0.2604712,
      size.height * 0.9465917,
    );
    path0.cubicTo(
      size.width * 0.2481893,
      size.height * 0.9465917,
      size.width * 0.2374945,
      size.height * 0.9681417,
      size.width * 0.2318979,
      size.height,
    );
    path0.lineTo(0, size.height);
    path0.lineTo(0, 0);
    path0.lineTo(size.width * 0.2287738, 0);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.9252333);
    path0.lineTo(size.width * 0.2591623, size.height * 0.9419167);
    path0.lineTo(size.width * 0.2630890, size.height * 0.9419167);
    path0.lineTo(size.width * 0.2630890, size.height * 0.9252333);
    path0.lineTo(size.width * 0.2591623, size.height * 0.9252333);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.8918667);
    path0.lineTo(size.width * 0.2591623, size.height * 0.9085500);
    path0.lineTo(size.width * 0.2630890, size.height * 0.9085500);
    path0.lineTo(size.width * 0.2630890, size.height * 0.8918667);
    path0.lineTo(size.width * 0.2591623, size.height * 0.8918667);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.8585083);
    path0.lineTo(size.width * 0.2591623, size.height * 0.8751833);
    path0.lineTo(size.width * 0.2630890, size.height * 0.8751833);
    path0.lineTo(size.width * 0.2630890, size.height * 0.8585083);
    path0.lineTo(size.width * 0.2591623, size.height * 0.8585083);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.8251467);
    path0.lineTo(size.width * 0.2591623, size.height * 0.8418250);
    path0.lineTo(size.width * 0.2630890, size.height * 0.8418250);
    path0.lineTo(size.width * 0.2630890, size.height * 0.8251467);
    path0.lineTo(size.width * 0.2591623, size.height * 0.8251467);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.7917808);
    path0.lineTo(size.width * 0.2591623, size.height * 0.8084633);
    path0.lineTo(size.width * 0.2630890, size.height * 0.8084633);
    path0.lineTo(size.width * 0.2630890, size.height * 0.7917808);
    path0.lineTo(size.width * 0.2591623, size.height * 0.7917808);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.7584150);
    path0.lineTo(size.width * 0.2591623, size.height * 0.7750975);
    path0.lineTo(size.width * 0.2630890, size.height * 0.7750975);
    path0.lineTo(size.width * 0.2630890, size.height * 0.7584150);
    path0.lineTo(size.width * 0.2591623, size.height * 0.7584150);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.7250492);
    path0.lineTo(size.width * 0.2591623, size.height * 0.7417317);
    path0.lineTo(size.width * 0.2630890, size.height * 0.7417317);
    path0.lineTo(size.width * 0.2630890, size.height * 0.7250492);
    path0.lineTo(size.width * 0.2591623, size.height * 0.7250492);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.6916908);
    path0.lineTo(size.width * 0.2591623, size.height * 0.7083658);
    path0.lineTo(size.width * 0.2630890, size.height * 0.7083658);
    path0.lineTo(size.width * 0.2630890, size.height * 0.6916908);
    path0.lineTo(size.width * 0.2591623, size.height * 0.6916908);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.6583250);
    path0.lineTo(size.width * 0.2591623, size.height * 0.6750083);
    path0.lineTo(size.width * 0.2630890, size.height * 0.6750083);
    path0.lineTo(size.width * 0.2630890, size.height * 0.6583250);
    path0.lineTo(size.width * 0.2591623, size.height * 0.6583250);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.6249592);
    path0.lineTo(size.width * 0.2591623, size.height * 0.6416425);
    path0.lineTo(size.width * 0.2630890, size.height * 0.6416425);
    path0.lineTo(size.width * 0.2630890, size.height * 0.6249592);
    path0.lineTo(size.width * 0.2591623, size.height * 0.6249592);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.5915933);
    path0.lineTo(size.width * 0.2591623, size.height * 0.6082767);
    path0.lineTo(size.width * 0.2630890, size.height * 0.6082767);
    path0.lineTo(size.width * 0.2630890, size.height * 0.5915933);
    path0.lineTo(size.width * 0.2591623, size.height * 0.5915933);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.5582275);
    path0.lineTo(size.width * 0.2591623, size.height * 0.5749108);
    path0.lineTo(size.width * 0.2630890, size.height * 0.5749108);
    path0.lineTo(size.width * 0.2630890, size.height * 0.5582275);
    path0.lineTo(size.width * 0.2591623, size.height * 0.5582275);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.5248700);
    path0.lineTo(size.width * 0.2591623, size.height * 0.5415525);
    path0.lineTo(size.width * 0.2630890, size.height * 0.5415525);
    path0.lineTo(size.width * 0.2630890, size.height * 0.5248700);
    path0.lineTo(size.width * 0.2591623, size.height * 0.5248700);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.4915042);
    path0.lineTo(size.width * 0.2591623, size.height * 0.5081867);
    path0.lineTo(size.width * 0.2630890, size.height * 0.5081867);
    path0.lineTo(size.width * 0.2630890, size.height * 0.4915042);
    path0.lineTo(size.width * 0.2591623, size.height * 0.4915042);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.4581383);
    path0.lineTo(size.width * 0.2591623, size.height * 0.4748208);
    path0.lineTo(size.width * 0.2630890, size.height * 0.4748208);
    path0.lineTo(size.width * 0.2630890, size.height * 0.4581383);
    path0.lineTo(size.width * 0.2591623, size.height * 0.4581383);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.4247725);
    path0.lineTo(size.width * 0.2591623, size.height * 0.4414550);
    path0.lineTo(size.width * 0.2630890, size.height * 0.4414550);
    path0.lineTo(size.width * 0.2630890, size.height * 0.4247725);
    path0.lineTo(size.width * 0.2591623, size.height * 0.4247725);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.3914142);
    path0.lineTo(size.width * 0.2591623, size.height * 0.4080975);
    path0.lineTo(size.width * 0.2630890, size.height * 0.4080975);
    path0.lineTo(size.width * 0.2630890, size.height * 0.3914142);
    path0.lineTo(size.width * 0.2591623, size.height * 0.3914142);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.3580483);
    path0.lineTo(size.width * 0.2591623, size.height * 0.3747317);
    path0.lineTo(size.width * 0.2630890, size.height * 0.3747317);
    path0.lineTo(size.width * 0.2630890, size.height * 0.3580483);
    path0.lineTo(size.width * 0.2591623, size.height * 0.3580483);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.3246825);
    path0.lineTo(size.width * 0.2591623, size.height * 0.3413658);
    path0.lineTo(size.width * 0.2630890, size.height * 0.3413658);
    path0.lineTo(size.width * 0.2630890, size.height * 0.3246825);
    path0.lineTo(size.width * 0.2591623, size.height * 0.3246825);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.2913167);
    path0.lineTo(size.width * 0.2591623, size.height * 0.3080000);
    path0.lineTo(size.width * 0.2630890, size.height * 0.3080000);
    path0.lineTo(size.width * 0.2630890, size.height * 0.2913167);
    path0.lineTo(size.width * 0.2591623, size.height * 0.2913167);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.2579592);
    path0.lineTo(size.width * 0.2591623, size.height * 0.2746417);
    path0.lineTo(size.width * 0.2630890, size.height * 0.2746417);
    path0.lineTo(size.width * 0.2630890, size.height * 0.2579592);
    path0.lineTo(size.width * 0.2591623, size.height * 0.2579592);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.2245933);
    path0.lineTo(size.width * 0.2591623, size.height * 0.2412758);
    path0.lineTo(size.width * 0.2630890, size.height * 0.2412758);
    path0.lineTo(size.width * 0.2630890, size.height * 0.2245933);
    path0.lineTo(size.width * 0.2591623, size.height * 0.2245933);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.1912275);
    path0.lineTo(size.width * 0.2591623, size.height * 0.2079100);
    path0.lineTo(size.width * 0.2630890, size.height * 0.2079100);
    path0.lineTo(size.width * 0.2630890, size.height * 0.1912275);
    path0.lineTo(size.width * 0.2591623, size.height * 0.1912275);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.1578617);
    path0.lineTo(size.width * 0.2591623, size.height * 0.1745442);
    path0.lineTo(size.width * 0.2630890, size.height * 0.1745442);
    path0.lineTo(size.width * 0.2630890, size.height * 0.1578617);
    path0.lineTo(size.width * 0.2591623, size.height * 0.1578617);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.1245033);
    path0.lineTo(size.width * 0.2591623, size.height * 0.1411783);
    path0.lineTo(size.width * 0.2630890, size.height * 0.1411783);
    path0.lineTo(size.width * 0.2630890, size.height * 0.1245033);
    path0.lineTo(size.width * 0.2591623, size.height * 0.1245033);
    path0.close();
    path0.moveTo(size.width * 0.2591623, size.height * 0.09113750);
    path0.lineTo(size.width * 0.2591623, size.height * 0.1078208);
    path0.lineTo(size.width * 0.2630890, size.height * 0.1078208);
    path0.lineTo(size.width * 0.2630890, size.height * 0.09113750);
    path0.lineTo(size.width * 0.2591623, size.height * 0.09113750);
    path0.close();

    Paint paint0fill = Paint()..style = PaintingStyle.fill;
    paint0fill.color = seedColor;
    canvas.drawPath(path0, paint0fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CouponCardData {
  final String? title;
  final String? subtitle;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? code;
  final num? discount;
  final bool isPercentage;

  bool get isStarted {
    final now = DateTime.now();
    return startDate != null && !startDate!.isAfter(now);
  }

  bool get isOnGoing {
    final now = DateTime.now();
    return startDate != null && endDate != null && !startDate!.isAfter(now) && !endDate!.isBefore(now);
  }

  bool get isExpired {
    final now = DateTime.now();
    return endDate != null && endDate!.isBefore(now);
  }

  const CouponCardData({
    this.title,
    this.subtitle,
    this.startDate,
    this.endDate,
    this.code,
    this.discount,
    this.isPercentage = false,
  });
}
