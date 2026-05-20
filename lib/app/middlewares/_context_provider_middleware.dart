import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/services.dart';

class ContextProviderMiddleware extends AutoRouteGuard {
  const ContextProviderMiddleware(this.ref);
  final WidgetRef ref;
  @override
  void onNavigation(resolver, router) {
    //--------------------Registering Overlay Service--------------------//
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalContextHolder.setContext(router.navigatorKey.currentContext!);
      ref.read(globalOverlayService);
    });
    //--------------------Registering Overlay Service--------------------//
    return resolver.next();
  }
}
