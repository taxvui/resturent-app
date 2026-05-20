part of '_kot_list_builder.dart';

class KOTOrderCancelModalSheet extends ConsumerStatefulWidget {
  const KOTOrderCancelModalSheet({super.key, required this.orderID});
  final int orderID;

  @override
  ConsumerState<KOTOrderCancelModalSheet> createState() => _KOTOrderCancelModalSheetState();
}

class _KOTOrderCancelModalSheetState extends ConsumerState<KOTOrderCancelModalSheet> {
  final selectedCancelReasonNotifier = ValueNotifier<int?>(null);
  late final additionalNoteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final orderCancelReasonListAsync = ref.watch(orderCancelReasonListProvider);

    return FormWrapper(
      builder: (formContext) {
        return BottomModalSheetWrapper(
          title: TextSpan(text: context.t.common.cancelKOT),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reason
                      ValueListenableBuilder(
                        valueListenable: selectedCancelReasonNotifier,
                        builder: (_, selectedCancelReason, _) {
                          return AsyncCustomDropdown<int, List<model.OrderCancelReasonModel>>(
                            asyncData: orderCancelReasonListAsync,
                            decoration: InputDecoration(
                              labelText: context.t.common.selectCancelReason,
                              hintText: context.t.common.selectCancelReason,
                            ),
                            value: selectedCancelReason,
                            items: orderCancelReasonListAsync.when(
                              data: (data) {
                                return data
                                    .map(
                                      (reason) => CustomDropdownMenuItem<int>(
                                        value: reason.id,
                                        label: TextSpan(text: reason.reason ?? "N/A"),
                                      ),
                                    )
                                    .toList();
                              },
                              error: (_, _) => [],
                              loading: () => [],
                            ),
                            onChanged: selectedCancelReasonNotifier.set,
                            validator: FormBuilderValidators.required(),
                          );
                        },
                      ),
                      const SizedBox.square(dimension: 20),

                      // Comment
                      TextFormField(
                        controller: additionalNoteController,
                        decoration: InputDecoration(
                          labelText: context.t.common.additionalComment,
                          hintText: context.t.common.enterComment,
                        ),
                      ),
                      const SizedBox.square(dimension: 16),
                    ],
                  ),
                ),

                // Action BUtton
                Row(
                  children: [
                    Expanded(
                      child: SizedBox.fromSize(
                        size: Size.fromHeight(48),
                        child: OutlinedButton(
                          onPressed: Navigator.of(context).pop,
                          style: CustomButtonStyles.destructiveOutline(),
                          child: Text(context.t.action.cancel),
                        ),
                      ),
                    ),
                    const SizedBox.square(dimension: 14),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (FormWrapper.validate(formContext)) {
                            return handleSubmit(context);
                          }
                        },
                        child: Text(context.t.action.apply),
                      ),
                    ),
                  ],
                ),

                // Keyboard Spacer
                SizedBox.square(
                  dimension: MediaQuery.viewInsetsOf(context).bottom,
                ),
              ],
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> handleSubmit(BuildContext context) async {
    try {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref
              .read(saleRepoProvider)
              .manageKOTOrderStatus(
                widget.orderID,
                KotOrderStatus.cancelled.stringValue,
                cancelReasonId: selectedCancelReasonNotifier.value,
                notes: additionalNoteController.text,
              ),
        ),
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        showCustomSnackBar(
          context,
          content: Text(_result),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }
  }
}
