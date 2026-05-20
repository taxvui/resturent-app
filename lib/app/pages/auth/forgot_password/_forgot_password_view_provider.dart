part of 'forgot_password_view.dart';

class ForgotPasswordViewNotifier extends ChangeNotifier {
  ForgotPasswordViewNotifier(this.ref)
      : _repo = ref.read(userRepositoryProvider.notifier);

  final Ref ref;
  final UserRepository _repo;

  //-------------------------Form Field Props-------------------------//
  late final emailController = TextEditingController();
  //-------------------------Form Field Props-------------------------//

  Future<Either<String?, String?>> handleForgotPassword() async {
    return await Future.microtask(
      () => _repo.getResetPasswordOtp(email: emailController.text),
    );
  }
}

final forgotPasswordProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ForgotPasswordViewNotifier(ref),
);
