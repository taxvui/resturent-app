import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.title,
    this.titleFlex = 1,
    this.titleStyle,
    this.titleMaxLines,
    this.titleOverflow,
    required this.description,
    this.descriptionFlex = 1,
    this.descriptionStyle,
    this.descriptionMaxLines,
    this.descriptionOverflow,
    this.centerSpace = 8,
    this.bottomSpace = 8,
  });

  final String title;
  final int titleFlex;
  final TextStyle? titleStyle;
  final int? titleMaxLines;
  final TextOverflow? titleOverflow;

  final String description;
  final int descriptionFlex;
  final TextStyle? descriptionStyle;
  final int? descriptionMaxLines;
  final TextOverflow? descriptionOverflow;

  final double centerSpace;
  final double bottomSpace;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _titleStyle = titleStyle ??
        _theme.textTheme.bodyLarge?.copyWith(
          color: _theme.colorScheme.onPrimaryContainer,
        );

    final _descriptionStyle = descriptionStyle ??
        _titleStyle?.copyWith(
          color: _theme.colorScheme.secondary,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: titleFlex,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: titleMaxLines,
                  overflow: titleOverflow,
                  style: _titleStyle,
                ),
              ),
              Text(':', style: _titleStyle),
            ],
          ),
        ),
        SizedBox(width: centerSpace),
        Expanded(
          flex: descriptionFlex,
          child: Text(
            description,
            maxLines: descriptionMaxLines,
            overflow: descriptionOverflow,
            style: _descriptionStyle,
          ),
        )
      ],
    ).fMarginOnly(bottom: bottomSpace);
  }
}
