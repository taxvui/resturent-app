part of '../../manage_user_profile.dart';

@RoutePage()
class SetupProfileView extends ConsumerStatefulWidget {
  const SetupProfileView({super.key});

  @override
  ConsumerState<SetupProfileView> createState() => _SetupProfileViewState();
}

class _SetupProfileViewState extends ConsumerState<SetupProfileView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(manageUserProfileProvider).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageUserProfileProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            centerTitle: true,
            title: Text(context.t.common.customizeProfile),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Image
                Text(
                  // Logo or Image,
                  context.t.common.imageOrLogo,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox.square(dimension: 12),
                Center(
                  child: SizedBox.square(
                    dimension: 100,
                    child: UserAvatarPicker(
                      image: controller.avatarImage,
                      onPickImage: controller.handleAvatarImage,
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 24),

                // Form Fields
                const BusinessProfileFormFields(fromSetupProfile: true),
              ],
            ),
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              if (FormWrapper.validate(formContext)) {
                return await _handleFormSubmit(context);
              }
            },
            child: Text(context.t.action.kContinue),
          ).fMarginSymmetric(horizontal: 16, vertical: 12),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    try {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: ref.read(manageUserProfileProvider).handleUpdateProfile,
      );

      final currProv = ref.read(appLocaleServiceProvider);
      currProv.saveLocale(
        currProv.activeLocale.copyWith(
          currencyName: _result.businessCurrency?.name,
          currencyCode: _result.businessCurrency?.code,
          currencySymbol: _result.businessCurrency?.symbol,
        ),
      );

      GlobalEventManager.I.fire<UserAuthEvent>(UserAuthEvent.signedIn);

      if (context.mounted) {
        context.router.replaceAll([
          CongratulationRoute(
            nextRoute: const MuteHomeRoute(),
            replaceAll: true,
          ),
        ]);
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
        return;
      }
    }
  }
}
