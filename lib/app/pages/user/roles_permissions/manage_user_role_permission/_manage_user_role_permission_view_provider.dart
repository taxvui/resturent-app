part of 'manage_user_role_permission_view.dart';

class ManageUserRolePermissionViewNotifier extends ChangeNotifier {
  ManageUserRolePermissionViewNotifier(this.ref) : _repo = ref.read(staffDesignationRepoProvider);
  final Ref ref;
  final StaffDesignationRepository _repo;

  //------------------------------Form Field Props------------------------------//
  StaffModel? selectedStaff;
  void handleSelectStaff(StaffModel? value) {
    selectedStaff = value;
    loginUserController.text = value?.email ?? '';
    notifyListeners();
  }

  late final staffSearchController = TextEditingController();
  late final loginUserController = TextEditingController();
  late final passwordController = TextEditingController();
  bool obscurePassword = true;
  void toggleObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Map<String, Permission?> selectedPermissions = {};
  void handleSelectPermissions(Map<String, Permission?> newVal) {
    selectedPermissions
      ..clear()
      ..addAll(newVal);
    return notifyListeners();
  }
  //------------------------------Form Field Props------------------------------//

  void initEdit(PermittedStaff data, {bool reset = false}) {
    selectedStaff = data.staff;
    staffSearchController.text = selectedStaff?.name ?? '';
    loginUserController.text = data.email ?? '';
    passwordController.text = data.password ?? '';

    selectedPermissions
      ..clear()
      ..addAll({...?data.permissions?.modules});

    return reset ? notifyListeners() : null;
  }

  Future<Either<String, PermittedStaffDetails>> handleManageUserRolePermission([
    PermittedStaff? data,
  ]) async {
    final _data = (data ?? PermittedStaff()).copyWith(
      staffId: selectedStaff?.id,
      email: loginUserController.text,
      password: passwordController.text,
      permissions: PermissionModules.fromJson(
        Map.fromEntries(selectedPermissions.entries.where((entry) {
          final permission = entry.value;
          return [
            permission?.view,
            permission?.create,
            permission?.update,
            permission?.delete,
          ].any((perm) => perm == true);
        }).map((entry) => MapEntry(entry.key, entry.value?.toJson()))),
      ),
    );

    return _repo.managePermittedStaff(_data);
  }
}

final manageUserRolePermissionViewProvider = ChangeNotifierProvider.autoDispose(
  ManageUserRolePermissionViewNotifier.new,
);
