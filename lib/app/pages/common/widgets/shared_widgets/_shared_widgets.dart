import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;

import '../../../../../i18n/strings.g.dart';
import '../../../../widgets/widgets.dart';
import '../../../../data/repository/repository.dart';
import '../widgets.dart';
export '_pdf_generator_providers.dart';
export '_thermal_invoice_providers.dart';

abstract class SharedWidgets {
  //------------------------Sign Out------------------------//
  static Future<void> handleSignOut(
    BuildContext context, {
    List<ProviderBase>? disposeProviders,
  }) async {
    final _confirmation = await showAdaptiveDialog<bool>(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        // title: 'Log out?',
        title: context.t.pages.confirmationDialog.title,
        // description: 'Are you sure to logout?',
        description: context.t.pages.confirmationDialog.message,
        onDecide: (v) => Navigator.of(popContext).pop(v),
        swapAction: true,
        // acceptionText: 'No',
        acceptionText: context.t.pages.confirmationDialog.acceptationText,
        // rejectionText: 'Log Out',
        rejectionText: context.t.pages.confirmationDialog.rejectionText,
      ),
    );

    if (context.mounted && _confirmation == false) {
      final provider = ProviderScope.containerOf(context);

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          provider.read(userRepositoryProvider.notifier).signOut,
        ),
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

        return context.router.replacePath<void>('/auth/sign-in');
      }
    }
  }
  //------------------------Sign Out------------------------//

  //------------------------Scan Barcode------------------------//
  static Future<String?> scanBarcode(BuildContext context) async {
    try {
      final _result = await SimpleBarcodeScanner.scanBarcode(
        context,
        delayMillis: 2000,
        isShowFlashIcon: true,
        child: Text('data'),
      );

      if (_result != null && _result.trim().toLowerCase() != '-1') {
        return _result;
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }

    return null;
  }
  //------------------------Scan Barcode------------------------//

  //-------------------------Warn If Exeed Limit------------------------//
  static void warnIfExeedLimit(
    BuildContext context,
    num maxLimit,
    num currentValue, {
    String message = 'You have reached your limit.',
    void Function()? onExeeded,
  }) {
    if (currentValue > maxLimit) {
      showCustomSnackBar(
        context,
        content: Text(message),
        customSnackBarType: CustomOverlayType.info,
      );
      onExeeded?.call();
      return;
    }
  }
  //-------------------------Warn If Exeed Limit------------------------//

  //------------------------Get Item Details------------------------//
  static Future<PItem?> getItemDetails(
    BuildContext context,
    int id,
  ) async {
    try {
      final _details = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => ProviderScope.containerOf(context).read(itemsRepoProvider).getItemDetails(id),
      );

      if (context.mounted && _details.data != null) {
        return _details.data!;
      }
    } catch (error) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(error.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }
    return null;
  }
  //------------------------Get Item Details------------------------//

  //------------------------Open File------------------------//
  static Future<void> openFile(
    BuildContext context,
    Future<File> Function() getFile,
  ) async {
    try {
      final file = await Future.microtask(getFile);

      // final _result = await OpenFilex.open(file.path);

      final _result = await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );

      if (context.mounted) {
        if (_result.status == ShareResultStatus.unavailable) {
          showCustomSnackBar(
            context,
            content: Text(_result.raw),
            customSnackBarType: CustomOverlayType.error,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }
  }
  //------------------------Open File------------------------//

  //------------------------Print PDF------------------------//
  static Future<void> printPDF(
    BuildContext context,
    Future<File> Function() getPDF,
  ) async {
    try {
      final pdfFile = await Future.microtask(getPDF);
      await Printing.layoutPdf(
        onLayout: (format) async => await Future.sync(pdfFile.readAsBytes),
      );
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }
  }
  //------------------------Print PDF------------------------//

  //------------------------Online Payment------------------------//
  static Future<bool> handleOnlinePayment(
    BuildContext context, {
    required int paymentId,
    num? payableAmount,
  }) async {
    Future<Either<String, String>?> onlinePayment() async {
      return await context.router.pushWidget<Either<String, String>>(
        OnlinePaymentView(
          paymentId: paymentId,
          payableAmount: payableAmount,
          onPayment: context.router.maybePop,
        ),
      );
    }

    while (true) {
      final _paymentResult = await onlinePayment();
      if (context.mounted && _paymentResult != null) {
        if (_paymentResult.isFailure) {
          final didRetry = await context.router.pushWidget<bool>(
            PaymentStatusView(
              onPressed: () => context.router.maybePop(true),
              status: PaymentStatusViewType.fail,
            ),
          );

          if (didRetry == true) continue;

          return false;
        }

        return true;
      }

      return false;
    }
  }
  //------------------------Online Payment------------------------//

  /*
  //------------------------Download Overlay------------------------//
  static Future<void> handleDownloadOverlay(
    BuildContext context,
    String? urlPath,
  ) async {
    if (urlPath == null || urlPath.trim().isEmpty) {
      showCustomSnackBar(
        context,
        // content: const Text('Invalid URL!'),
        content: Text(context.t.exceptions.invalidDownloadUrl),
        customSnackBarType: CustomOverlayType.error,
      );
      return;
    }

    final _result = await showFileDownloadOverlay(
      context,
      urlPath: urlPath,
      saveFile: true,
    );

    if (!context.mounted) return;

    if (_result.isFailure) {
      showCustomSnackBar(
        context,
        content: Text(_result.left!),
        customSnackBarType: CustomOverlayType.error,
      );
      return;
    }

    Future<void> openFile() async {
      try {
        final _openResult = await OpenFile.open(_result.right!.path);
        if (context.mounted && _openResult.type != ResultType.done) {
          showCustomSnackBar(
            context,
            content: Text(_openResult.message),
            customSnackBarType: CustomOverlayType.error,
          );
        }
      } catch (e) {
        if (context.mounted) {
          showCustomSnackBar(
            context,
            // content: Text('Error opening file: $e'),
            content: Text(context.t.exceptions.errorOpeningFile(error: e.toString())),
            customSnackBarType: CustomOverlayType.error,
          );
        }
      }
    }

    showCustomSnackBar(
      context,
      // content: const Text('File downloaded successfully!'),
      content: Text(context.t.common.downloadSuccess),
      action: SnackBarAction(
        // label: 'Open',
        label: context.t.action.open,
        onPressed: openFile,
        backgroundColor: Theme.of(context).colorScheme.onPrimary.withAlpha(50),
      ),
    );
  }
  //------------------------Download Overlay------------------------//

  //-------------Change Property Visibility (Landlord)-------------//
  static Future<void> handleChangePropertyStatus(
    BuildContext context,
    Future<String> Function() callback, {
    bool showFloating = false,
  }) async {
    late final ({bool isError, String message}) _response;

    try {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(callback),
      );
      _response = (isError: false, message: _result);
    } catch (e) {
      _response = (isError: true, message: e.toString());
    }

    if (context.mounted) {
      final _theme = Theme.of(context);
      if (showFloating) {
        showCustomSnackBar(
          context,
          snackBar: CustomSnackBar(
            content: Text(
              _response.message,
              style: _theme.textTheme.bodyLarge?.copyWith(
                color: CustomOverlayType.success.foregroundColor,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _response.isError
                ? CustomOverlayType.error.backgroundColor
                : CustomOverlayType.success.backgroundColor,
            hitTestBehavior: HitTestBehavior.opaque,
          ),
        );
        return;
      }

      showCustomSnackBar(
        context,
        content: Text(_response.message),
        customSnackBarType: _response.isError
            ? CustomOverlayType.error
            : CustomOverlayType.success,
      );
      return;
    }
  }
  //-------------Change Property Visibility (Landlord)-------------//
  */
  //-------------Launch URL-------------//
  static Future<void> handleLaunchURL(BuildContext context, String url) async {
    try {
      final parsedUrl = Uri.tryParse(url);
      if (parsedUrl == null || !parsedUrl.hasScheme) {
        throw FormatException('Invalid URL format');
      }

      final launched = await urllauncher.launchUrl(
        parsedUrl,
        mode: urllauncher.LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        showCustomSnackBar(
          context,
          content: Text('No application found to handle $url'),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    } catch (e, stackTrace) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text('Failed to launch URL: ${e.toString()}'),
          customSnackBarType: CustomOverlayType.error,
        );
      }
      // Consider logging the error for debugging
      debugPrint('URL Launch Error: $e\n$stackTrace');
    }
  }

  //-------------Launch URL-------------//
}
