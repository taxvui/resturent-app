part of 'sign_in_view.dart';

class SignInViewNotifier extends ChangeNotifier {
  SignInViewNotifier(this.ref) : _repo = ref.read(userRepositoryProvider.notifier);

  final Ref ref;
  final UserRepository _repo;

  //-------------------------Form Field Props-------------------------//
  late final emailController = TextEditingController();
  late final passwordController = TextEditingController();
  bool obscurePassword = true;
  void toggleObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  bool rememberMe = true;
  void toggleRememberMe([bool? value]) {
    rememberMe = value ?? !rememberMe;
    notifyListeners();
  }
  //-------------------------Form Field Props-------------------------//

  Future<Either<String?, String?>> handleSignIn() async {
    final _result = await Future.microtask(
      () => _repo.signIn(
        email: emailController.text,
        password: passwordController.text,
      ),
    );

    if (_result.isSuccess) {
      if (rememberMe) await handleRememberMe(false);

      return Either.success('Signed in successfully');
    }

    return Either.failure(_result.left);
  }

  Future<bool> handleRememberMe([bool recover = true]) async {
    final _prefs = _repo.httpClient.prefs;

    if (recover) {
      emailController.text = _prefs.getString(DAppSPrefsKeys.userEmail) ?? '';
      passwordController.text = _prefs.getString(DAppSPrefsKeys.userPassword) ?? '';
      return true;
    }
    final _savedEmail = await _prefs.setString(
      DAppSPrefsKeys.userEmail,
      emailController.text,
    );
    final _savedPassword = await _prefs.setString(
      DAppSPrefsKeys.userPassword,
      passwordController.text,
    );

    return _savedEmail && _savedPassword;
  }
}

final signinProvider = ChangeNotifierProvider.autoDispose(
  (ref) => SignInViewNotifier(ref),
);
