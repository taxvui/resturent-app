import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../../core/core.dart';
import '../../../data/model/model.dart' as model;
import '../../../data/repository/repository.dart' as repo;
import '../../../widgets/widgets.dart';

@RoutePage()
class NotificationListView extends ConsumerStatefulWidget {
  const NotificationListView({super.key});

  @override
  ConsumerState<NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends ConsumerState<NotificationListView>
    with PaginatedControllerMixin<model.NotificationModel> {
  @override
  void initState() {
    initPaging();
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    _apiEventSubs?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Notification'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'mark-all-as-read',
                  child: Text(context.t.common.markAllAsRead),
                ),
              ];
            },
            onSelected: (value) async {
              if (value == 'mark-all-as-read') {
                return handleMarkAllAsRead(context);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(pagingController.refresh),
        child: PagedListView.separated(
          padding: const EdgeInsets.all(16),
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<model.NotificationModel>(
            itemBuilder: (_, item, _) {
              return NotificationTile(
                data: item,
              );
            },
          ),
          separatorBuilder: (_, _) => const Divider(),
        ),
      ),
    );
  }

  Future<void> handleMarkAllAsRead(BuildContext context) async {
    try {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: ref.read(repo.userRepositoryProvider.notifier).markAllNotificaitonAsRead,
      );

      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(_result),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }
  }

  bool _readFirst = true;
  @override
  Future<model.NotificationListModel> fetchData(int page) {
    return Future.microtask(() async {
      if (_readFirst) {
        _readFirst = false;
        try {
          await ref.read(repo.userRepositoryProvider.notifier).markAllNotificaitonAsRead();
        } catch (_) {}
      }
      return ref.read(repo.userRepositoryProvider.notifier).getNotificationList(page);
    });
  }

  repo.EventSub<repo.PushNotificationEvent>? _apiEventSubs;
  @override
  void initRefreshListener() {
    _apiEventSubs = repo.GlobalEventManager.I.on<repo.PushNotificationEvent>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.data,
    this.onTap,
  });
  final model.NotificationModel data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      isThreeLine: false,
      titleAlignment: ListTileTitleAlignment.top,
      visualDensity: const VisualDensity(
        horizontal: -2,
        vertical: -4,
      ),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.tight(const Size.square(36)),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: _theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
        child: Icon(
          FeatherIcons.bell,
          size: 20,
          color: _theme.colorScheme.primary,
        ),
      ),
      title: Text(
        data.title ?? "N/A",
        style: _theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.createdAt?.getFormatedString(pattern: 'dd MMM yyyy hh:mm a') ?? "N/A",
            style: _theme.textTheme.bodySmall?.copyWith(
              color: _theme.colorScheme.secondary,
            ),
          ),
          if (data.message != null) ...[
            const SizedBox.square(dimension: 8),
            Text(
              data.message ?? "N/A",
              style: _theme.textTheme.bodyMedium?.copyWith(
                color: _theme.colorScheme.secondary,
              ),
            ),
          ],
        ],
      ),
      trailing: data.readAt != null
          ? null
          : Container(
              constraints: BoxConstraints.tight(const Size.square(8)),
              decoration: BoxDecoration(
                color: _theme.colorScheme.primary.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
