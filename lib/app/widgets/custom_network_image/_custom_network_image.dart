import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';

import '../../core/core.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.url,
    this.fit,
    this.alignment = Alignment.center,
    this.centerSlice,
    this.color,
    this.colorBlendMode,
    this.excludeFromSemantics = false,
    this.filterQuality = FilterQuality.medium,
    this.frameBuilder,
    this.gaplessPlayback = false,
    this.height,
    this.width,
    this.isAntiAlias = false,
    this.matchTextDirection = false,
    this.repeat = ImageRepeat.noRepeat,
    this.semanticLabel,
  });
  final String? url;
  final BoxFit? fit;
  final Alignment alignment;
  final Rect? centerSlice;
  final Color? color;
  final BlendMode? colorBlendMode;
  final bool excludeFromSemantics;
  final FilterQuality filterQuality;
  final ImageFrameBuilder? frameBuilder;
  final bool gaplessPlayback;
  final double? height;
  final double? width;
  final bool isAntiAlias;
  final bool matchTextDirection;
  final ImageRepeat repeat;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return UniversalImage(
      url ?? DAppImages.emptyImagePlaceholder,
      fit: fit,
      alignment: alignment,
      centerSlice: centerSlice,
      color: color,
      colorBlendMode: colorBlendMode,
      excludeFromSemantics: excludeFromSemantics,
      filterQuality: filterQuality,
      frameBuilder: frameBuilder,
      gaplessPlayback: gaplessPlayback,
      height: height,
      width: width,
      isAntiAlias: isAntiAlias,
      matchTextDirection: matchTextDirection,
      repeat: repeat,
      semanticLabel: semanticLabel,
      placeholder: Image.asset(
        DAppImages.emptyImagePlaceholder,
        fit: BoxFit.cover,
      ),
    );
  }
}
