import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/static/static.dart';
import '../../../data/repository/repository.dart';
import '../../../widgets/widgets.dart';

@RoutePage()
class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  Future<void> splash(void Function() callback) async {
    if (await validatePurchaseCode(context)) {
      return await Future.delayed(
        const Duration(milliseconds: 1800),
        callback,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      splash(() async {
        if (context.mounted) {
          return await context.router.replacePath<void>(
            '/mute-home',
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _theme.colorScheme.primary,
      extendBody: true,
      body: Center(
        child: Container(
          clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints.tight(Size.square(200)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(500),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(24),
          child: Image.asset(
            DAppImages.splashLogo,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future<bool> validatePurchaseCode(BuildContext context) async {
    try {
      final _response = await ref
          .read(httpDioClientProvider)
          .restClient
          .get(
            "https://api.envato.com/v3/market/author/sale?code=${AppConfig.purchaseCode}",
            options: DioOptions(headers: {'Authorization': 'Bearer orZoxiU81Ok7kxsE0FvfraaO0vDW5tiz'}),
          );

      if (_response.data?['item']?['id'] == 58370658) {
        return true;
      }
    } catch (_) {}

    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return InfoDialog.info(
            title: 'Invalid Purchase Code',
            description: 'The purchase code you entered is invalid. Please try again.',
            buttonText: 'OK',
            iconType: InfoDialogIconType.splashError,
            onPressed: SystemNavigator.pop,
          );
        },
      );
    }
    return false;
  }
}
