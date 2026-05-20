part of 'sign_up_view.dart';

class SignUpViewNotifier extends ChangeNotifier {
  SignUpViewNotifier(this.ref)
      : _repo = ref.read(userRepositoryProvider.notifier);
  final Ref ref;
  final UserRepository _repo;
  //-------------------------Form Field Props-------------------------//
  late final fullNameController = TextEditingController();
  late final emailController = TextEditingController();
  late final passwordController = TextEditingController();
  bool obscurePassword = true;
  void toggleObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  //-------------------------Form Field Props-------------------------//

  Future<Either<String?, String?>> handleSignUp() async {
    final _result = await _repo.signUp(
      email: emailController.text,
      password: passwordController.text,
      name: fullNameController.text,
    );

    if (_result.isFailure) {
      return Either.failure(_result.left);
    }

    return Either.success('Signed up successfully.');
  }
}

final signupProvider = ChangeNotifierProvider.autoDispose(
  (ref) => SignUpViewNotifier(ref),
);
