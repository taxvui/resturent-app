import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../i18n/strings.g.dart';
import '../../../services/services.dart';
import '../../../widgets/widgets.dart';

@RoutePage()
class LanguageView extends ConsumerStatefulWidget {
  const LanguageView({super.key, this.getBack = false});
  final bool getBack;

  @override
  ConsumerState<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends ConsumerState<LanguageView> {
  late final ValueNotifier<CustomAppLocale> selectedLocale;

  @override
  void initState() {
    selectedLocale = ValueNotifier(
      ref.read(appLocaleServiceProvider).activeLocale,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final langProv = ref.watch(appLocaleServiceProvider);

    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.pages.language.appbarTitle),
        centerTitle: !widget.getBack,
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedLocale,
        builder: (_, selected, _) {
          return RadioGroup<CustomAppLocale>(
            groupValue: selected,
            onChanged: (value) => selectedLocale.value = value!,
            child: ListView.builder(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              itemCount: langProv.supportedLocale.length,
              itemBuilder: (context, index) {
                final _item = langProv.supportedLocale[index];

                return DecoratedBox(
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      bottom: Divider.createBorderSide(context),
                    ),
                  ),
                  child: RadioListTile<CustomAppLocale>(
                    value: _item,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Row(
                      children: [
                        SizedBox.square(
                          dimension: 32,
                          child: Flag.fromString(_item.countryCode ?? ''),
                        ),
                        const SizedBox.square(dimension: 12),
                        Flexible(
                          child: Text(
                            _item.languageName,
                            style: _theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    tileColor: _theme.colorScheme.primaryContainer,
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    visualDensity: const VisualDensity(vertical: -2),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () async {
          final _result = await showAsyncLoadingOverlay(
            context,
            asyncFunction: () => langProv.saveLocale(
              langProv.activeLocale.copyWith(
                countryCode: selectedLocale.value.countryCode,
                languageCode: selectedLocale.value.languageCode,
                languageName: selectedLocale.value.languageName,
              ),
            ),
          );

          if (context.mounted) {
            if (_result.isFailure) {
              showCustomSnackBar(
                context,
                content: Text(_result.left!),
                customSnackBarType: CustomOverlayType.error,
              );
            } else {
              if (widget.getBack) {
                context.router.maybePop();
                return;
              }

              return context.router.replacePath<void>('/mute-home');
            }
          }
        },
        child: Text(context.t.action.save),
      ).fMarginLTRB(24, 12, 24, 16),
    );
  }
}
