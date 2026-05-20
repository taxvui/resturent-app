import 'package:dotted_border/dotted_border.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

import '../../core/core.dart';
import '../widgets.dart';

class ImageFormField extends FormField<DynamicFileType> {
  ImageFormField({
    super.key,
    Size? previewSize,
    ImageFieldDecoration? decoration,
    final void Function(DynamicFileType value)? onSelectImage,
    super.validator,
    super.initialValue,
  }) : super(
          builder: (state) {
            return _ImageFormFieldWidget(
              state: state,
              previewSize: previewSize,
              decoration: decoration,
              onSelectImage: onSelectImage,
            );
          },
        );

  @override
  FormFieldState<DynamicFileType> createState() => _ImageFormFieldState();
}

class _ImageFormFieldState extends FormFieldState<DynamicFileType> {}

class _ImageFormFieldWidget extends StatelessWidget {
  const _ImageFormFieldWidget({
    // ignore: unused_element_parameter
    super.key,
    required this.state,
    this.onSelectImage,
    this.decoration,
    this.previewSize,
  });

  final FormFieldState<DynamicFileType> state;
  final void Function(DynamicFileType value)? onSelectImage;
  final ImageFieldDecoration? decoration;
  final Size? previewSize;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _imagePath = state.value?.remote ?? state.value?.local?.path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (decoration?.labelText != null) ...[
          Text.rich(decoration!.labelText!),
          const SizedBox.square(dimension: 10),
        ],
        SizedBox.fromSize(
          size: previewSize,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: Radius.circular(6),
              color: _theme.colorScheme.outline,
              dashPattern: const [2, 3],
              borderPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
            ),
            child: state.value != null
                ? _buildImagePreview(_imagePath!, state.value!.isRemote)
                : _buildPlaceholder(context),
          ),
        ),
        if (state.hasError) ...[
          const SizedBox.square(dimension: 4),
          Text(
            state.errorText!,
            style: _theme.inputDecorationTheme.errorStyle,
          )
        ]
      ],
    );
  }

  Widget _buildImagePreview(String path, bool isRemote) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: isRemote
                ? CustomNetworkImage(url: path, fit: BoxFit.cover)
                : Image.file(File(path), fit: BoxFit.cover),
          ),
          if (state.value != null) ...[
            Positioned(
              top: 0,
              right: 0,
              child: IconButton.filled(
                onPressed: () {
                  onSelectImage?.call(DynamicFileType());
                  state.didChange(null);
                },
                iconSize: 18,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
                icon: const Icon(Icons.close),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final _theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _selectImage(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _selectImage(context),
              color: _theme.colorScheme.secondary,
              icon: const Icon(FeatherIcons.camera),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ),
            if (decoration?.hintText != null)
              Flexible(
                child: Text.rich(
                  decoration!.hintText!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: _theme.inputDecorationTheme.hintStyle,
                ),
              )
          ],
        ),
      ),
    ).fPaddingAll(6);
  }

  Future<void> _selectImage(BuildContext context) async {
    final pickedFile = await showImagePickerDialog(context);
    if (pickedFile != null) {
      final newValue = DynamicFileType(local: pickedFile.firstOrNull);
      onSelectImage?.call(newValue);
      state.didChange(newValue);
    }
  }
}

class ImageFieldDecoration {
  final InlineSpan? labelText;
  final InlineSpan? hintText;
  final InlineSpan? error;

  ImageFieldDecoration({
    this.labelText,
    this.hintText,
    this.error,
  });
}
