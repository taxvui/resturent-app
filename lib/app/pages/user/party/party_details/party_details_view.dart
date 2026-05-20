import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/core.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../common/widgets/widgets.dart';

@RoutePage()
class PartyDetailsView extends ConsumerStatefulWidget {
  const PartyDetailsView({
    super.key,
    @PathParam('party_id') required this.partyId,
  });
  final int partyId;

  @override
  ConsumerState<PartyDetailsView> createState() => _PartyDetailsViewState();
}

class _PartyDetailsViewState extends ConsumerState<PartyDetailsView> {
  @override
  Widget build(BuildContext context) {
    var partyDetailsAsync = ref.watch(partyDetailsProvider(widget.partyId));
    var ledgerListAsync = ref.watch(
      partyLedgerListProvider((
        page: 1,
        partyId: widget.partyId,
        partyType: partyDetailsAsync.value?.data?.type ?? '',
        fromDate: null,
        toDate: null,
      )),
    );

    final _theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _theme.colorScheme.primaryContainer,
      appBar: CustomAppBar(
        title: Text(context.t.pages.parties.partiesDetails),
        actions: [
          if (!partyDetailsAsync.hasError)
            Skeletonizer(
              enabled: partyDetailsAsync.isLoading,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ref.can(PMKeys.parties, action: PermissionAction.update))
                    IconButton(
                      onPressed: () async {
                        return await context.router.push<void>(
                          ManagePartyRoute(
                            editModel: partyDetailsAsync.value?.data,
                          ),
                        );
                      },
                      icon: const Icon(FeatherIcons.edit2),
                    ),
                  if (ref.can(PMKeys.parties, action: PermissionAction.delete))
                    IconButton(
                      onPressed: () async {
                        return await _handleDelete(
                          context,
                          () => ref.read(partyRepoProvider).deleteParty(widget.partyId),
                        );
                      },
                      icon: const Icon(FeatherIcons.trash2),
                    ),
                ],
              ),
            ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => Future.sync(() {
          partyDetailsAsync = ref.refresh(partyDetailsProvider(widget.partyId));
          ledgerListAsync = ref.refresh(
            partyLedgerListProvider((
              page: 1,
              partyId: widget.partyId,
              partyType: partyDetailsAsync.value?.data?.type ?? '',
              fromDate: null,
              toDate: null,
            )),
          );
        }),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info
              partyDetailsAsync
                  .when(
                    skipLoadingOnRefresh: false,
                    data: (data) {
                      return _buildPartyInfo(context, data.data!);
                    },
                    error: (error, stackTrace) {
                      return EmptyWidget(
                        replaceDefault: false,
                        emptyBuilder: (context) {
                          return RetryButtons.scrollView(
                            error,
                            onRetry: () => ref.refresh(
                              partyDetailsProvider(widget.partyId),
                            ),
                          );
                        },
                      );
                    },
                    loading: () {
                      return Skeletonizer(
                        child: _buildPartyInfo(context, Party()),
                      );
                    },
                  )
                  .fMarginAll(16),

              // Ledger List
              if (ref.can(PMKeys.transactions))
                ledgerListAsync.when(
                  skipLoadingOnRefresh: false,
                  data: (data) {
                    return _buildLedgerList(
                      context,
                      party: partyDetailsAsync.asData!.value.data!,
                      data: [...?data.data?.data],
                    );
                  },
                  error: (error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                  loading: () {
                    return Skeletonizer(
                      child: _buildLedgerList(
                        context,
                        party: const Party(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartyInfo(BuildContext context, Party data) {
    final _theme = Theme.of(context);

    final _sectionHeaderStyle = _theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Image
        Center(
          child: SizedBox.square(
            dimension: 100,
            child: UserAvatarPicker(image: data.image),
          ),
        ),
        const SizedBox.square(dimension: 16),

        // Personal Info
        Text('${context.t.pages.parties.personalInfo}:', style: _sectionHeaderStyle),
        const SizedBox.square(dimension: 8),
        ...{
          context.t.common.name: data.name ?? "N/A",
          context.t.common.phoneNumber: data.phone ?? "N/A",
          context.t.common.address: data.address ?? "N/A",
          context.t.common.type: data.type ?? "N/A",
        }.entries.map((info) {
          return KeyValueRow(
            title: info.key,
            titleFlex: 6,
            description: info.value,
            descriptionFlex: 8,
          );
        }),

        // Delivery Addresss
        if (data.type == 'customer' && data.deliveryAddresses?.isNotEmpty == true) ...[
          const SizedBox.square(dimension: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Delivery Address',
                style: _theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox.square(dimension: 12),

              // Address List
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  ...?data.deliveryAddresses?.map((address) {
                    return CustomerAddressCard(
                      data: CustomerAddressData(
                        name: address.name,
                        phone: address.phone,
                        address: address.address,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLedgerList(
    BuildContext context, {
    required Party party,
    List<PartyLedger> data = const [],
  }) {
    final _theme = Theme.of(context);

    final _sectionHeaderStyle = _theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return Container(
      decoration: BoxDecoration(
        color: _theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadiusDirectional.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t.common.recentTransaction,
                style: _sectionHeaderStyle,
              ),
              TextButton(
                onPressed: () async {
                  return await context.router.push<void>(
                    PartyLedgerDetailsRoute(party: party),
                  );
                },
                style: TextButton.styleFrom(
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
                child: Text(context.t.action.viewLedger),
              ),
            ],
          ).fMarginLTRB(16, 16, 16, 0),

          // Ledger List
          Column(
            spacing: 6,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...data.map(
                (ledger) {
                  final _isCustomer = party.type?.trim().toLowerCase() == 'customer';
                  return TransactionCard(
                    cardData: TransactionCardData(
                      cardType: _isCustomer ? TransactionCardType.saleList() : TransactionCardType.purchaseList(),
                      invoiceNumber: ledger.invoiceNumber ?? "N/A",
                      transactionDate: _isCustomer ? ledger.saleDate : ledger.purchaseDate,
                      paymentType: ledger.paymentType?.name ?? "N/A",
                      primaryValue: ledger.totalAmount ?? 0,
                      secondaryValue: ledger.paidAmount ?? 0,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.exceptions.doYouWantToDeleteThisParty,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(callback),
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
        return;
      }
    }
  }
}
