part of 'hrm_repo.dart';

class HolidayRepository extends BaseRepository {
  HolidayRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Holiday List-----------------------//
  Future<HolidayListModel> getHolidayList({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.holidays(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return HolidayListModel.fromJson(
        _response.data,
        (holiday) => HolidayModel.fromJson(holiday),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get holiday list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Holiday List-----------------------//

  //-----------------------Manage Holiday-----------------------//
  Future<HolidayModel> manageHoliday(HolidayModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.holidays(data.id),
        data: _formData,
      );

      final _data = HolidayModel.fromJson(_response.data['data']);

      gEventListener.fire<HolidayModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Holiday-----------------------//

  //--------------------Delete Holiday--------------------//
  Future<String> deleteHoliday(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.holidays(id),
      );

      gEventListener.fire<HolidayModel>(HolidayModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Holiday--------------------//
}

final holidayRepoProvider = Provider.autoDispose<HolidayRepository>(
  HolidayRepository.new,
);
