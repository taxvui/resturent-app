import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AsyncLisViewBuilder<T> extends StatelessWidget {
  const AsyncLisViewBuilder({
    super.key,
    required this.asyncData,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.shrinkWrap = false,
    required this.itemBuilder,
    this.emptyListBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    required this.placeholderItem,
  });

  final AsyncValue<List<T>> asyncData;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final Widget? Function(BuildContext context, T item, int index) itemBuilder;
  final WidgetBuilder? emptyListBuilder;
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final T placeholderItem;

  @override
  Widget build(BuildContext context) {
    return asyncData.when(
      skipLoadingOnRefresh: false,
      data: (data) {
        if (data.isEmpty) {
          return emptyListBuilder?.call(context) ??
              const Center(child: Text('No item found in the list'));
        }
        return buildList(data);
      },
      error: errorBuilder ??
          (error, _) => Center(
                child: Text(error.toString()),
              ),
      loading: loadingBuilder ??
          () {
            return Skeletonizer(
              child: buildList(List.generate(3, (_) => placeholderItem)),
            );
          },
    );
  }

  Widget buildList(List<T> data) {
    return ListView.separated(
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, data[index], index);
      },
      separatorBuilder: (context, index) {
        return const SizedBox.square(dimension: 10);
      },
    );
  }
}
