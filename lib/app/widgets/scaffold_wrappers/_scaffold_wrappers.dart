import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../i18n/strings.g.dart';
import '../widgets.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.key,
    super.actions,
    super.actionsIconTheme,
    super.automaticallyImplyLeading,
    super.bottomOpacity,
    super.centerTitle,
    super.clipBehavior,
    super.elevation,
    super.excludeHeaderSemantics,
    super.flexibleSpace,
    super.forceMaterialTransparency,
    super.foregroundColor,
    super.iconTheme,
    super.leadingWidth,
    super.notificationPredicate,
    super.primary,
    super.scrolledUnderElevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.systemOverlayStyle,
    super.title,
    super.titleSpacing = 0,
    super.titleTextStyle,
    super.toolbarHeight,
    super.toolbarOpacity,
    super.toolbarTextStyle,
    super.backgroundColor,
    Widget? leading,
    ShapeBorder? shape,
    super.bottom,
    GlobalKey<ScaffoldState>? scaffoldKey,
  }) : super(
         leading:
             leading ??
             (automaticallyImplyLeading == false
                 ? null
                 : scaffoldKey?.currentState?.hasDrawer == true
                 ? IconButton(
                     onPressed: scaffoldKey?.currentState?.openDrawer,
                     icon: const Icon(Icons.menu),
                     tooltip: 'Open navigation menu',
                   )
                 : const AutoLeadingButton()),
       );
}

class BottomNavWrapper extends StatelessWidget {
  const BottomNavWrapper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.zero,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color:
                _theme.dividerTheme.color ??
                _theme.colorScheme.outline.withValues(
                  alpha: 0.25,
                ),
          ),
        ),
      ),
      child: child,
    );
  }
}

class FormWrapper extends StatelessWidget {
  const FormWrapper({
    super.key,
    required this.builder,
    this.canPop,
    this.onPopInvokedWithResult,
    this.useDefaultInvoker = false,
    this.defaultInvokerCallback,
    this.title,
    this.description,
  }) : /* 
        assert(
          !useDefaultInvoker || title != null,
          '`title must be passed to use default invoker`',
        ),
        */
       assert(
         useDefaultInvoker || defaultInvokerCallback == null,
         '`defaultInvokerCallback must be null when useDefaultInvoker is false`',
       );
  // ignore: library_private_types_in_public_api
  final _FormWrapperBuilder builder;

  final bool? canPop;
  final void Function(bool didPop, Object? result)? onPopInvokedWithResult;
  final bool useDefaultInvoker;
  final VoidCallback? defaultInvokerCallback;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Form(
      canPop: useDefaultInvoker ? false : canPop,
      onPopInvokedWithResult: !useDefaultInvoker
          ? onPopInvokedWithResult
          : (dp, rt) => defaultInvoker(context, didPop: dp, result: rt),
      child: Builder(
        builder: (formContext) => builder(formContext),
      ),
    );
  }

  void defaultInvoker(
    BuildContext context, {
    required bool didPop,
    Object? result,
  }) async {
    if (didPop) return;

    final _result = await showDialog<bool>(
      context: context,
      builder: (popContext) {
        return InfoDialog.confirmation(
          title: title ?? context.t.prompt.unsavedWarning.title,
          description: description ?? context.t.prompt.unsavedWarning.message,
          onDecide: Navigator.of(popContext).pop,
        );
      },
    );

    if (_result == true && context.mounted) {
      defaultInvokerCallback?.call();
      return context.router.pop(result);
    }
  }

  static bool validate(BuildContext formContext, {bool unfocusPrimary = true}) {
    if (unfocusPrimary) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    return Form.maybeOf(formContext)?.validate() == true;
  }
}

typedef _FormWrapperBuilder = Widget Function(BuildContext formContext);
