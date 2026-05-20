import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ReadMore2 extends StatefulWidget {
  const ReadMore2(
    this.data, {
    super.key,
    this.maxCharacters = 100,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.textStyle,
    this.handleStyle,
  });
  final String data;
  final int maxCharacters;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  final TextStyle? textStyle;
  final TextStyle? handleStyle;

  @override
  State<ReadMore2> createState() => _ReadMore2State();
}

class _ReadMore2State extends State<ReadMore2> {
  bool showAll = false;

  late String displayText;

  @override
  void initState() {
    super.initState();
    displayText = widget.data.length > widget.maxCharacters
        ? widget.data.substring(0, widget.maxCharacters)
        : widget.data;
  }

  void toggleReadMore() {
    setState(() {
      showAll = !showAll;
      displayText = showAll
          ? widget.data
          : widget.data.substring(0, widget.maxCharacters);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _handleStyle = widget.handleStyle ??
        TextStyle(
          color: _theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        );

    return Text.rich(
      TextSpan(
        text: displayText,
        children: [
          if (widget.data.length > widget.maxCharacters)
            TextSpan(
              text: showAll ? ' Show Less' : '...Read More',
              style: _handleStyle,
              recognizer: TapGestureRecognizer()..onTap = toggleReadMore,
            ),
        ],
      ),
      style: widget.textStyle,
      maxLines: widget.maxLines,
      textAlign: widget.textAlign,
      overflow: widget.overflow,
    );
  }
}
