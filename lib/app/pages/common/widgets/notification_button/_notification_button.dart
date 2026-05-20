import 'package:auto_route/auto_route.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repository/repository.dart' as repo;
import '../../../../routes/app_routes.gr.dart';

class NotificationButton extends ConsumerWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _notificationAsync = ref.watch(notificationListProvider);

    final _theme = Theme.of(context);

    return _notificationAsync.when(
      skipLoadingOnRefresh: false,
      data: (data) => IconButton(
        onPressed: () async {
          return context.router.push<void>(NotificationListRoute());
        },
        icon: Badge.count(
          count: data.unreadCount,
          isLabelVisible: data.unreadCount > 0,
          maxCount: 9,
          child: const Icon(FeatherIcons.bell),
        ),
      ),
      error: (error, stackTrace) => IconButton(
        onPressed: () => ref.refresh(notificationListProvider),
        icon: Badge(
          label: const Text('!'),
          child: const Icon(Icons.refresh),
        ),
      ),
      loading: () => SizedBox.square(
        dimension: 36,
        child: Center(
          child: CircularProgressIndicator(backgroundColor: _theme.colorScheme.onPrimary),
        ),
      ),
    );
  }
}

final notificationListProvider = FutureProvider.autoDispose<repo.NotificationListModel>(
  (ref) {
    final _apiEventSubs = repo.GlobalEventManager.I.on<repo.PushNotificationEvent>().listen((_) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSubs.cancel);

    return Future.microtask(() => ref.read(repo.userRepositoryProvider.notifier).getNotificationList(1));
  },
);

extension NotificationModelExt on repo.NotificationListModel {
  int get unreadCount {
    return data?.data?.where((e) => e.readAt == null).length ?? 0;
  }
}
