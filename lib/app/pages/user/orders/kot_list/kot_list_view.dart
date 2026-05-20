import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../components/components.dart';

@RoutePage()
class KotListView extends StatefulWidget {
  const KotListView({super.key, this.scaffoldKey});
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<KotListView> createState() => _KotListViewState();
}

class _KotListViewState extends State<KotListView> {
  //------------------------State Vars------------------------//
  late final searchController = TextEditingController();
  late final selectedFilterNotifier = ValueNotifier<Map<String, dynamic>>({
    "date_filter": DropdownDateFilter.daily,
    "search": "",
    "kitchen_id": null,
  });
  //------------------------State Vars------------------------//

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // Sync search text changes to filter notifier
    searchController.addListener(() {
      selectedFilterNotifier.set({
        ...selectedFilterNotifier.value,
        "search": searchController.text,
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    selectedFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: Text(context.t.common.allKOT),
        actions: [
          ValueListenableBuilder(
            valueListenable: selectedFilterNotifier,
            builder: (_, filters, child) {
              return DropdownDateFilter(
                value: filters["date_filter"] as DateFilterDropdownItem?,
                onChanged: (value) {
                  return selectedFilterNotifier.set({
                    ...filters,
                    "date_filter": value,
                  });
                },
              ).fMarginSymmetric(horizontal: 8, vertical: 10);
            },
          ),

          const NotificationButton(),
          const SizedBox.square(dimension: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 8),
            child: ValueListenableBuilder(
              valueListenable: selectedFilterNotifier,
              builder: (_, filters, _) {
                // Calculate filter count (only kitchen filter)
                final _filterCount = filters['kitchen_id'] != null ? 1 : 0;

                return CustomSearchField(
                  controller: searchController,
                  decoration: CustomSearchFieldDecoration(
                    hintText: context.t.common.search,
                  ),
                  appliedFilterCount: _filterCount,
                  onTapFilter: () async {
                    return showFilterModalSheet<String, dynamic>(
                      context: context,
                      selectedFilters: {...selectedFilterNotifier.value},
                      filters: [
                        FilterModalData.custom(
                          key: 'kitchen_id',
                          builder: (context, {initialValue, required onChanged}) {
                            return Consumer(
                              builder: (_, ref, _) {
                                final kitchenListAsync = ref.watch(kitchenDropdownProvider);

                                return AsyncCustomDropdown<int, KitchenListModel>(
                                  asyncData: kitchenListAsync,
                                  decoration: InputDecoration(
                                    labelText: context.t.common.kitchen(n: 1),
                                  ),
                                  value: initialValue,
                                  items: kitchenListAsync.when(
                                    data: (data) {
                                      return [
                                        CustomDropdownMenuItem(
                                          value: null,
                                          label: TextSpan(text: 'All Kitchen'),
                                        ),
                                        ...?data.data?.data?.map((kitchen) {
                                          return CustomDropdownMenuItem(
                                            value: kitchen.id,
                                            label: TextSpan(text: kitchen.name ?? "N/A"),
                                          );
                                        }),
                                      ];
                                    },
                                    error: (_, _) => [],
                                    loading: () => [],
                                  ),
                                  onChanged: onChanged,
                                );
                              },
                            );
                          },
                        ),
                      ],
                      onSave: (v) {
                        return selectedFilterNotifier.set({
                          ...selectedFilterNotifier.value,
                          "kitchen_id": v['kitchen_id'],
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          // KOT List
          Expanded(
            child: KotListBuilder(
              filterNotifier: selectedFilterNotifier,
            ),
          ),
        ],
      ),
    ).unfocusPrimary();
  }
}
