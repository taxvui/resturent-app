import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';

import '../../core/core.dart';
import '../image_picker_dialog/_show_image_picker_dialog.dart';

class UserAvatarPicker extends StatelessWidget {
  const UserAvatarPicker({
    super.key,
    this.image,
    this.fit,
    this.onPickImage,
    this.showBorder = true,
    this.borderColor,
    this.backgroundColor,
    this.foregroundColor,
    this.showInitialsPlaceholder = false,
    this.userName,
    this.placeholderImage,
  });
  final DynamicFileType? image;
  final BoxFit? fit;
  final void Function(File? value)? onPickImage;
  final bool showBorder;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showInitialsPlaceholder;
  final String? userName;
  final String? placeholderImage;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _baseDecor = BoxDecoration(
      shape: BoxShape.circle,
      border: showBorder
          ? Border.all(
              color: borderColor ?? _theme.colorScheme.primary,
              width: 1.5,
            )
          : null,
    );

    final ImageProvider _image = image?.isLocal == true
        ? FileImage(image!.local!)
        : image?.isRemote == true
            ? NetworkImage(image!.remote!)
            : AssetImage(placeholderImage ?? DAppImages.userPlaceholder);

    if (image?.local == null && image?.remote == null && showInitialsPlaceholder) {
      return DecoratedBox(
        decoration: _baseDecor.copyWith(
          color: backgroundColor ??
              _theme.colorScheme.primary.withValues(
                alpha: 0.25,
              ),
        ),
        child: _buildInitials(),
      );
    }

    return Container(
      decoration: _baseDecor.copyWith(
        image: DecorationImage(image: _image, fit: fit),
      ),
      // alignment: const AlignmentDirectional(1.115, 1.075),
      alignment: AlignmentDirectional(1.30, 1.30),
      child: onPickImage == null
          ? null
          : IconButton(
              onPressed: () async {
                final _result = await showImagePickerDialog(context);
                return onPickImage?.call(_result?.firstOrNull);
              },
              style: IconButton.styleFrom(
                visualDensity: const VisualDensity(horizontal: -2, vertical: -4),
                padding: EdgeInsets.zero,
              ),
              icon: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: _theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  IconlyBold.camera,
                  color: _theme.colorScheme.primary,
                  size: 18,
                ).fMarginAll(5),
              ),
            ),
    );
  }

  Widget _buildInitials() {
    final initials = _generateInitials() ?? 'N/A';
    return Builder(
      builder: (context) {
        final _theme = Theme.of(context);
        return Center(
          child: Text(
            initials.toUpperCase(),
            style: _theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: foregroundColor ?? _theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  String? _generateInitials() {
    if (userName == null || userName!.isEmpty) {
      return null;
    }

    final nameParts = userName!.split(' ').where((part) => part.isNotEmpty).toList();

    if (nameParts.length < 2) {
      return nameParts.first.length < 2 ? nameParts.first : nameParts.first.substring(0, 2);
    }

    return nameParts.take(2).map((part) => part[0]).join();
  }
}
