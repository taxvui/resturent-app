import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

part '_coupon_card.dart';

class CouponListWidget extends ConsumerStatefulWidget {
  const CouponListWidget({
    super.key,
    this.filter = 'available',
    this.padding = const EdgeInsets.all(16),
    this.cardActionBuilder,
  });

  /// [filter] accepts two values: `upcoming` `available` or `expired`
  final String filter;
  final EdgeInsetsGeometry padding;
  final Widget Function(BuildContext context, CouponModel data)? cardActionBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CouponListWidgetState();
}

class _CouponListWidgetState extends ConsumerState<CouponListWidget> with PaginatedControllerMixin<CouponModel> {
  late final _seedColors = const [
    Color(0xff00932C),
    Color(0xffFC7F19),
    Color(0xff008DD3),
    Color(0xffEE1023),
    Color(0xffAA07EE),
    Color(0xff03968E),
    Color(0xff1022E3),
  ];

  @override
  void initState() {
    initPaging();
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    _apiEventSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () => Future.sync(pagingController.refresh),
      child: PagedListView<int, CouponModel>.separated(
        padding: widget.padding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<CouponModel>(
          itemBuilder: (c, coupon, i) {
            final _data = CouponCardData(
              title: coupon.name,
              subtitle: coupon.description,
              startDate: coupon.startDate,
              endDate: coupon.endDate,
              code: coupon.code,
              discount: coupon.discount,
              isPercentage: coupon.isPercentage,
            );

            return CouponCardWidget(
              seedColor: _seedColors[i % _seedColors.length],
              data: _data,
              actionButton: widget.cardActionBuilder?.call(context, coupon),
            );
          },
          noItemsFoundIndicatorBuilder: (context) {
            return EmptyWidget(
              replaceDefault: false,
              emptyBuilder: (context) {
                return RetryButtons.scrollView(
                  'No Coupons found!\n Please try adding a coupon.',
                  onRetry: pagingController.refresh,
                );
              },
            );
          },
        ),
        separatorBuilder: (_, _) {
          return const SizedBox.square(dimension: 4);
        },
      ),
    );
  }

  @override
  Future<PaginatedListModel<CouponModel>> fetchData(int page) {
    return Future.microtask(
      () => ref
          .read(couponRepoProvider)
          .getCoupons(
            page: page,
            status: widget.filter,
          ),
    );
  }

  late EventSub<CouponAE> _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<CouponAE>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}

Future<CouponModel?> showCouponListModal(BuildContext context) async {
  return showModalBottomSheet<CouponModel>(
    context: context,
    builder: (modalContext) {
      return BottomModalSheetWrapper(
        title: const TextSpan(text: 'Item Details'),
        child: CouponListWidget(
          cardActionBuilder: (context, data) {
            final _theme = Theme.of(context);
            return InkWell(
              onTap: () => Navigator.of(modalContext).pop(data),
              borderRadius: BorderRadius.circular(48),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  color: _theme.colorScheme.primary,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: Text(
                  'Apply',
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: _theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
