import 'package:flutter/material.dart';

import '../../core/core.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.emptyBuilder,
    this.replaceDefault = true,
    this.message,
  });

  /// A builder for customizing the empty state.
  final WidgetBuilder? emptyBuilder;

  /// Whether to replace the default empty state with the [emptyBuilder].
  final bool replaceDefault;

  /// An optional message to display below the empty state image.
  final TextSpan? message;

  @override
  Widget build(BuildContext context) {
    Widget emptyState;
    if (replaceDefault && emptyBuilder != null) {
      emptyState = emptyBuilder!(context);
    } else {
      // Default empty state
      emptyState = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 260),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(DAppImages.emptyPlaceholder),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox.square(dimension: 12),
            Text.rich(
              message!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
            ),
          ],
        ],
      );
    }

    // Add the custom empty state if replacement is disabled
    if (!replaceDefault && emptyBuilder != null) {
      emptyState = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          emptyState,
          emptyBuilder!(context),
        ],
      );
    }

    return Center(child: emptyState);
  }
}
