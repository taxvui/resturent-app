import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../../i18n/strings.g.dart';
import '../../../data/repository/repository.dart';
import '../../../widgets/widgets.dart';

@RoutePage()
class CurrencyView extends ConsumerStatefulWidget {
  const CurrencyView({super.key});

  @override
  ConsumerState<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends ConsumerState<CurrencyView> {
  late final ValueNotifier<Currency> selectedLocale;

  @override
  void initState() {
    final _nLocale = ref.read(appLocaleServiceProvider).activeLocale;
    selectedLocale = ValueNotifier(
      Currency(
        code: _nLocale.currencyCode,
        name: _nLocale.currencyName,
        symbol: _nLocale.currencySymbol,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currencyList = ref.watch(currencyListProvider);

    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: Text(context.t.pages.currency.title)),
      body: currencyList.when(
        skipLoadingOnRefresh: false,
        data: (data) {
          return RefreshIndicator.adaptive(
            onRefresh: () => ref.refresh(currencyListProvider.future),
            child: ValueListenableBuilder(
              valueListenable: selectedLocale,
              builder: (_, selected, _) {
                return RadioGroup(
                  groupValue: selected,
                  onChanged: (value) {
                    selectedLocale.value = value!;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
                    itemCount: data.data?.length ?? 0,
                    itemBuilder: (_, index) {
                      final _item = [...?data.data][index];

                      return DecoratedBox(
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            bottom: Divider.createBorderSide(context),
                          ),
                        ),
                        child: RadioListTile<Currency>(
                          value: _item,
                          controlAffinity: ListTileControlAffinity.trailing,
                          title: Text.rich(
                            TextSpan(
                              text: '${_item.name ?? 'N/A'} - ',
                              children: [
                                TextSpan(
                                  text: _item.symbol,
                                  style: TextStyle(fontFamily: 'Noto Sans'),
                                ),
                              ],
                            ),
                            style: _theme.textTheme.bodyLarge,
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
                    separatorBuilder: (_, _) => const SizedBox.square(
                      dimension: 10,
                    ),
                  ),
                );
              },
            ),
          );
        },
        error: (error, stackTrace) {
          return RetryButtons.scrollView(
            error,
            onRetry: () => ref.refresh(currencyListProvider.future),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () async {
          if (ref.canSnackbar(context, PMKeys.currency, action: PermissionAction.update)) {
            final _result = await showAsyncLoadingOverlay(
              context,
              asyncFunction: _saveLocale,
            );

            if (context.mounted) {
              if (_result.isFailure) {
                showCustomSnackBar(
                  context,
                  content: Text(_result.left!),
                  customSnackBarType: CustomOverlayType.error,
                );

                return;
              }

              context.router.maybePop();
            }
          }
        },
        child: Text(context.t.action.save),
      ).fMarginLTRB(24.fW, 12.fH, 24.fW, 16.fH),
    );
  }

  Future<Either<String, String>> _saveLocale() async {
    final currProv = ref.read(appLocaleServiceProvider);
    try {
      // ignore: unused_local_variable
      final _remoteResult = await ref.read(commonRepoProvider).getCurrency(selectedLocale.value.id);

      final _localResult = currProv.saveLocale(
        currProv.activeLocale.copyWith(
          currencyCode: selectedLocale.value.code,
          currencySymbol: selectedLocale.value.symbol,
          currencyName: selectedLocale.value.name,
        ),
      );

      return _localResult;
    } catch (e) {
      return Either.failure(e.toString());
    }
  }
}
