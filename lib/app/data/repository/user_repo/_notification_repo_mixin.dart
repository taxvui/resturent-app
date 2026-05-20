part of '_user_repo.dart';

mixin NotificaitonRepoMixin on UserRepositoryBase {
  //------------------------Get Notification List------------------------//
  Future<NotificationListModel> getNotificationList(int page) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.notificationList,
        options: DioOptions(headers: httpClient.getAuthHeader),
        queryParameters: {"page": page},
      );

      return NotificationListModel.fromJson(_response.data, NotificationModel.fromJson);
    } on DioException catch (err) {
      throw Exception(err.response?.data['message'] ?? 'Failed to get notification list.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //------------------------Get Notification List------------------------//

  //------------------------Mark All As Read------------------------//
  Future<String> markAllNotificaitonAsRead() async {
    try {
      final _response = await dioClient.post(
        "${DAPIEndpoints.notificationList}/read-all",
        data: {'_method': 'put'},
        options: DioOptions(headers: httpClient.getAuthHeader),
      );

      GlobalEventManager.I.fire<PushNotificationEvent>(PushNotificationEvent());
      return _response.data['message'] ?? 'All notifications marked as read.';
    } on DioException catch (err) {
      throw Exception(err.response?.data['message'] ?? 'Failed to mark all notifications as read.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //------------------------Mark All As Read------------------------//
}
