import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../data/model/model.dart' show PaginatedListModel;

export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

mixin PaginatedControllerMixin<T> {
  final PagingController<int, T> pagingController = PagingController<int, T>(
    firstPageKey: 1,
  );
  Future<PaginatedListModel<T>> fetchData(int page);
  void onPageError(Object error) {}
  void getRawData(PaginatedListModel<T> data) {}

  void initPaging() {
    pagingController.addPageRequestListener(_fetchPage);
  }

  @mustCallSuper
  void initRefreshListener() {}

  @protected
  Future<void> _fetchPage(int pageKey) async {
    try {
      final response = await Future.microtask(() => fetchData(pageKey));

      final data = response.data;
      if (data == null) {
        throw Exception('No data found in the response.');
      }
      getRawData(response);

      final isLastPage = data.currentPage == data.lastPage;
      if (isLastPage) {
        pagingController.appendLastPage(data.data ?? []);
      } else {
        pagingController.appendPage(
          data.data ?? [],
          (data.currentPage ?? 0) + 1,
        );
      }
    } catch (error) {
      onPageError(error);
      pagingController.error = error;
    }
  }

  @mustCallSuper
  void pageDispose() {
    pagingController.dispose();
  }
}
