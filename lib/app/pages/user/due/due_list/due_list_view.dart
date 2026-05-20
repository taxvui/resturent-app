import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';
import '../../../common/widgets/widgets.dart';

part 'tabs/_due_list_tab.dart';
part 'tabs/_collection_list_tab.dart';
part '_due_list_view_provider.dart';

@RoutePage()
class DueListView extends ConsumerWidget {
  const DueListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _dateFilter = ref.watch(_dateFilterProvider);
    final _dueListTab = ref.watch(_dueListTabProvider);
    final _collectionListTab = ref.watch(_dueCollectionListTabProvider);

    final _theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text(context.t.pages.due.title),
          actions: [
            DropdownDateFilter(
              value: _dateFilter,
              onChanged: (v) {
                ref.read(_dateFilterProvider.notifier).state = v;
              },
            ).fMarginSymmetric(horizontal: 16, vertical: 10),
          ],
        ),
        body: Column(
          children: [
            // TabBar
            ColoredBox(
              color: _theme.colorScheme.primary.withValues(alpha: 0.15),
              child: TabBar(
                tabAlignment: TabAlignment.fill,
                tabs: [
                  ...[
                    ("due_list", context.t.pages.due.title),
                    ("collection_list ", context.t.pages.due.collectionList),
                  ].map((entry) => Tab(text: entry.$2)),
                ],
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  DueListTab(provider: _dueListTab),
                  CollectionListTab(provider: _collectionListTab),
                ],
              ),
            ),
          ],
        ),
      ),
    ).unfocusPrimary();
  }
}

final _dateFilterProvider = StateProvider.autoDispose<DateFilterDropdownItem>(
  (ref) => DropdownDateFilter.daily,
);
