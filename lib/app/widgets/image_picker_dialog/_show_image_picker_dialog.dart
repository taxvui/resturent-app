import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconly/iconly.dart';

import '../../core/core.dart' show DAppColors;

Future<List<File>?> showImagePickerDialog(
  BuildContext context, {
  bool selectMultiple = false,
}) async {
  return await showDialog<List<File>?>(
    context: context,
    builder: (popContext) => _ImagePickerDialog(
      onSelect: (value) async {
        final _picker = ImagePicker();
        try {
          List<XFile>? pickedFiles;

          if (value.isCamera) {
            final pickedFile = await _picker.pickImage(source: value.source);
            pickedFiles = pickedFile != null ? [pickedFile] : null;
          } else {
            if (selectMultiple) {
              pickedFiles = await _picker.pickMultiImage();
            } else {
              final pickedFile = await _picker.pickImage(source: value.source);
              pickedFiles = pickedFile != null ? [pickedFile] : null;
            }
          }

          if (pickedFiles != null && popContext.mounted) {
            final files = pickedFiles.map((x) => File(x.path)).toList();
            Navigator.of(popContext).pop(files);
          }
        } catch (_) {
          if (popContext.mounted) Navigator.of(popContext).pop();
        }
      },
    ),
  );
}

class _ImagePickerDialog extends StatelessWidget {
  const _ImagePickerDialog({
    // ignore: unused_element_parameter
    super.key,
    required this.onSelect,
  });
  final void Function(_ImagePickerType value) onSelect;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Option',
                style: _theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              CloseButton(
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 16),

          // Options
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._ImagePickerType.values.map(
                (type) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => onSelect(type),
                      borderRadius: BorderRadius.circular(6),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: type.color?.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          type.icon,
                          color: type.color,
                        ).fMarginAll(8),
                      ),
                    ),
                    const SizedBox.square(dimension: 4),
                    Text(
                      type.getLabel,
                      style: _theme.textTheme.bodyLarge,
                    ),
                  ],
                ).fMarginSymmetric(horizontal: 12),
              )
            ],
          )
        ],
      ).fMarginLTRB(16, 0, 0, 24),
    );
  }
}

enum _ImagePickerType {
  gallery(
    source: ImageSource.gallery,
    icon: IconlyBold.image,
    color: DAppColors.kPrimary,
  ),
  camera(
    source: ImageSource.camera,
    icon: IconlyBold.camera,
    color: Colors.red,
  );

  final ImageSource source;
  final IconData icon;
  final Color? color;

  String get getLabel {
    return switch (this) {
      _ImagePickerType.gallery => 'Gallery',
      _ImagePickerType.camera => 'Camera',
    };
  }

  bool get isGallery => this == _ImagePickerType.gallery;
  bool get isCamera => this == _ImagePickerType.camera;

  const _ImagePickerType({
    required this.source,
    required this.icon,
    this.color,
  });
}
