part of 'reset_password_view.dart';

class ResetPasswordViewNotifier extends ChangeNotifier {
  ResetPasswordViewNotifier(this.ref)
      : _repo = ref.read(userRepositoryProvider.notifier);
  final Ref ref;
  final UserRepository _repo;

  //-------------------------Form Field Props-------------------------//
  late final passwordController = TextEditingController();
  late final confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  void toggleObscure([bool isConfirm = false]) {
    if (isConfirm) {
      obscureConfirmPassword = !obscureConfirmPassword;
    } else {
      obscurePassword = !obscurePassword;
    }
    notifyListeners();
  }
  //-------------------------Form Field Props-------------------------//

  Future<Either<String?, String?>> handleResetPassword(String email) async {
    final _result = await Future.microtask(
      () => _repo.changePassword(
        email: email,
        password: passwordController.text,
        confirmPass: confirmPasswordController.text,
      ),
    );
    if (_result.isSuccess) {
      return Either.success('Password changed successfully');
    }
    return Either.failure('Failed to save new password, please try again!');
  }
}

final resetPasswordProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ResetPasswordViewNotifier(ref),
);
