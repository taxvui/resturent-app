import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';

class PlanCardWidget extends StatelessWidget {
  const PlanCardWidget({
    super.key,
    required this.cardData,
    required this.onPressedAction,
  });
  final PlanCardData cardData;
  final VoidCallback? onPressedAction;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        minWidth: double.maxFinite,
        // minHeight: 550,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(6),
        border: cardData.isMostPopular
            ? null
            : Border.all(
                color: _theme.colorScheme.secondary.withValues(
                  alpha: 0.275,
                ),
              ),
        gradient: _bgGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            constraints: BoxConstraints.tightFor(
              width: double.maxFinite,
              height: 140,
            ),
            decoration: BoxDecoration(
              gradient: _headerGradient,
              border: Border(
                bottom: BorderSide(
                  color: cardData.isMostPopular ? Colors.white : _theme.colorScheme.secondary.withValues(alpha: 0.275),
                ),
              ),
            ),
            child: Stack(
              children: [
                // Most Popular Banner
                if (cardData.isMostPopular) ...[
                  PositionedDirectional(
                    top: 12,
                    end: 0,
                    child: CustomPaint(
                      painter: _MostPopularBanner(),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(24, 4, 16, 4),
                        child: Text(
                          context.t.pages.subscriptionPlan.extra.mostPopular,
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _fgColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      40,
                      20,
                      0,
                    ),
                    child: Row(
                      children: [
                        // Icon
                        /// [Skeleton.shade] is being used to allow `Skeletonizer` show the loading effect on svg
                        Skeleton.shade(
                          child: SizedBox.square(
                            dimension: 64,
                            child: cardData.iconPath != null
                                ? UniversalImage(cardData.iconPath)
                                : Container(
                                    constraints: BoxConstraints.expand(),
                                    padding: const EdgeInsets.all(14),
                                    decoration: _iconDecoration,
                                    child: UniversalImage(cardData.cardType.image.svgPath),
                                  ),
                          ),
                        ),
                        const SizedBox.square(dimension: 16),

                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Plan Name
                              Text(
                                cardData.planName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: _fgColor,
                                  letterSpacing: -0.575,
                                ),
                              ),

                              // Pricing
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                spacing: 10,
                                children: [
                                  // Current Price
                                  Text(
                                    cardData.currentPrice.compactCurrency(
                                      decimalDigits: 2,
                                      customCurrency: cardData.symbol,
                                    ),
                                    style: _theme.textTheme.headlineSmall?.copyWith(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w600,
                                      color: _fgColor,
                                    ),
                                  ),

                                  // Billing Frequency & Previous Price
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        // Previous Price
                                        if (cardData.hasDiscount) ...[
                                          TextSpan(
                                            text: "${cardData.price.quickCurrency()}\n",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.lineThrough,
                                              decorationThickness: 1.5,
                                            ),
                                          ),
                                        ],

                                        // Billing Frequency
                                        TextSpan(
                                          text: '/${cardData.billingFrequency}',
                                          style: TextStyle(
                                            color: cardData.isMostPopular ? null : _theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      color: _fgColor,
                                      fontWeight: FontWeight.w500,
                                      decorationColor: _fgColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Features
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                ...cardData.features.entries.map(
                  (feature) {
                    return Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Builder(
                              builder: (_) {
                                final _icon = (feature.value ? DAppSvgIcons.octagonCheck : DAppSvgIcons.closeCircle);

                                /// [Skeleton.shade] is being used to allow `Skeletonizer` show the loading effect on svg
                                return Skeleton.shade(
                                  child: UniversalImage(
                                    _icon.svgPath,
                                    colorFilter: !feature.value
                                        ? null
                                        : ColorFilter.mode(
                                            cardData.isMostPopular ? _fgColor : _icon.baseColor!,
                                            BlendMode.srcIn,
                                          ),
                                  ),
                                );
                              },
                            ).fMarginOnly(right: 10),
                          ),
                          TextSpan(
                            text: feature.key,
                            style: _theme.textTheme.bodyLarge?.copyWith(
                              color: _fgColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Action Button
          ElevatedButton(
            onPressed: onPressedAction,
            style: _actionButtonStyle,
            child: Text(context.t.action.buyNow),
          ).fMarginLTRB(20, 4, 20, 20),
        ],
      ),
    );
  }

  Color get _fgColor {
    if (cardData.isMostPopular) return Colors.white;
    return Colors.black;
  }

  Color? get _bgColor {
    if (cardData.isMostPopular) return null;
    return Colors.white;
  }

  Gradient? get _bgGradient {
    if (!cardData.isMostPopular) return null;

    return LinearGradient(
      begin: AlignmentDirectional.topEnd,
      end: AlignmentDirectional.bottomStart,
      colors: [
        Color(0xFFFF8A80),
        Color(0xFFD500F9),
        Color(0xFF6A1B9A),
      ],
    );
  }

  Gradient? get _headerGradient {
    if (cardData.isMostPopular) return null;

    return LinearGradient(
      begin: AlignmentDirectional.topCenter,
      end: AlignmentDirectional.bottomCenter,
      stops: [0.5, 5],
      colors: [
        Colors.white.withValues(alpha: 0.15),
        (cardData.cardType.image.baseColor ?? Colors.white).withValues(
          alpha: 0.15,
        ),
      ],
    );
  }

  Decoration get _iconDecoration {
    final _baseDecoration = BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          cardData.cardType.image.baseColor ?? Colors.white,
          cardData.cardType.image.baseColor ?? Colors.white,
        ],
      ),
    );

    if (cardData.isMostPopular) {
      return _baseDecoration.copyWith(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        gradient: RadialGradient(colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.3)]),
      );
    }
    return _baseDecoration;
  }

  ButtonStyle? get _actionButtonStyle {
    if (cardData.isMostPopular) {
      return ElevatedButton.styleFrom(
        backgroundColor: _fgColor,
        foregroundColor: Colors.black,
      );
    }

    if (cardData.isAdvance) {
      return ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff007AFF),
      );
    }

    return null;
  }
}

class PlanCardData {
  final int planId;
  final String? iconPath;
  final String planName;
  final num price;
  final num? discountPrice;
  final String billingFrequency;
  final Map<String, bool> features;
  final PlanCardType cardType;
  final String? symbol;

  const PlanCardData({
    required this.planId,
    this.iconPath,
    required this.planName,
    required this.price,
    this.discountPrice,
    this.billingFrequency = 'per month',
    required this.features,
    required this.cardType,
    this.symbol,
  });

  PlanCardData copyWith({
    int? planId,
    String? iconPath,
    String? planName,
    num? price,
    num? discountPrice,
    String? billingFrequency,
    Map<String, bool>? features,
    PlanCardType? cardType,
    String? symbol,
  }) {
    return PlanCardData(
      planId: planId ?? this.planId,
      iconPath: iconPath ?? this.iconPath,
      planName: planName ?? this.planName,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      billingFrequency: billingFrequency ?? this.billingFrequency,
      features: features ?? this.features,
      cardType: cardType ?? this.cardType,
      symbol: symbol ?? this.symbol,
    );
  }

  num get currentPrice {
    if (discountPrice != null && discountPrice! > 0) {
      return discountPrice!;
    }

    return price;
  }

  bool get hasDiscount {
    return discountPrice != null && discountPrice! > 0;
  }

  bool get isBasic => cardType == PlanCardType.basic;
  bool get isMostPopular => cardType == PlanCardType.mostPopular;
  bool get isAdvance => cardType == PlanCardType.advance;
}

enum PlanCardType {
  basic(image: DAppSvgIcons.basicStar),
  mostPopular(image: DAppSvgIcons.clover),
  advance(image: DAppSvgIcons.petals);

  final SvgImageHolder image;

  const PlanCardType({required this.image});
}

class _MostPopularBanner extends CustomPainter {
  // ignore: unused_element_parameter
  _MostPopularBanner({this.color = const Color(0xff34C759)});

  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    Path path0 = Path();
    path0.moveTo(size.width * 0.1079949, size.height * 0.03633529);
    path0.cubicTo(
      size.width * 0.1107153,
      size.height * 0.01359912,
      size.width * 0.1152270,
      0,
      size.width * 0.1200504,
      0,
    );
    path0.lineTo(size.width * 1.058394, 0);
    path0.cubicTo(
      size.width * 1.066460,
      0,
      size.width * 1.072993,
      size.height * 0.03730962,
      size.width * 1.072993,
      size.height * 0.08333333,
    );
    path0.lineTo(size.width * 1.072993, size.height * 0.9166667);
    path0.cubicTo(
      size.width * 1.072993,
      size.height * 0.9626917,
      size.width * 1.066460,
      size.height,
      size.width * 1.058394,
      size.height,
    );
    path0.lineTo(size.width * 0.02034905, size.height);
    path0.cubicTo(
      size.width * 0.008615182,
      size.height,
      size.width * 0.001676117,
      size.height * 0.9249792,
      size.width * 0.008293796,
      size.height * 0.8696667,
    );
    path0.lineTo(size.width * 0.1079949, size.height * 0.03633529);
    path0.close();

    Paint paint0fill = Paint()..style = PaintingStyle.fill;
    paint0fill.color = color;
    canvas.drawPath(path0, paint0fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
