import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/app_routes.gr.dart';
import '../../widgets/widgets.dart';
import '../services.dart';

class GlobalOverlayService {
  static GlobalOverlayService? _instance;
  GlobalOverlayService._(this.ref, this.context);
  final Ref ref;
  final BuildContext context;

  factory GlobalOverlayService.init(Ref ref, BuildContext context) {
    final _i = _instance ??= GlobalOverlayService._(
      ref,
      context,
    )
      .._registerAuthListener()
      .._registerConnectionChecker();

    return _i;
  }

  void _registerAuthListener() {
    ref.read(httpDioClientProvider).restClient.interceptors.add(
      AuthListener(onRevoke: () async {
        if (context.router.currentPath.startsWith('/auth/')) return;

        final _result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (popContext) {
            return PopScope(
              canPop: false,
              child: InfoDialog.info(
                title: 'Session expired',
                description: 'Your session has expired. Please sign in again',
                buttonText: 'Sign In',
                iconType: InfoDialogIconType.splashError,
                onPressed: () {
                  Navigator.of(popContext).pop();
                  context.router.replaceAll([
                    const PageRouteInfo(
                      'auth',
                      initialChildren: [SignInRoute()],
                    )
                  ]);
                },
              ),
            );
          },
        );
        debugPrint(_result.toString());
      }),
    );
  }

  late final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _streamSubscription;
  Future<void> _registerConnectionChecker() async {
    await _checkAndShowDialog(await _connectivity.checkConnectivity());
    _streamSubscription = _connectivity.onConnectivityChanged.listen(
      _checkAndShowDialog,
    );
  }

  Future<void> _checkAndShowDialog(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.none)) {
      await _showNoInternetDialog();
    } else {
      _closeOverlay();
    }
  }

  Future<void> _showNoInternetDialog() async {
    _closeOverlay();

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (popContext) {
        return PopScope(
          canPop: false,
          child: NoInternetDialog(
            onTryAgain: () async {
              _closeOverlay();
              final result = await _connectivity.checkConnectivity();
              await _checkAndShowDialog(result);
            },
          ),
        );
      },
    );
  }

  void _closeOverlay() {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void dispose() {
    _streamSubscription.cancel();
  }
}

final globalOverlayService = Provider.autoDispose(
  (ref) => GlobalOverlayService.init(
    ref,
    GlobalContextHolder.context,
  ),
);

abstract class GlobalContextHolder {
  static BuildContext? _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static BuildContext get context {
    if (_context == null) {
      throw Exception(
        "Global context is not set. Please set it before accessing.",
      );
    }
    return _context!;
  }
}
