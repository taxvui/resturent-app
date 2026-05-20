import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../src/templates/templates.dart';

import '../../services.dart' show GlobalContextHolder;
import 'widgets/widgets.dart';

class ThermalPrinterGenerator extends ChangeNotifier {
  final Ref ref;
  ThermalPrinterGenerator(this.ref);

  Future<void> _getPermissions() async {
    final _requiredPermissions = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (_requiredPermissions[Permission.bluetoothConnect]
            ?.isPermanentlyDenied ==
        true) {
      await openAppSettings();
    }
  }

  final _availableDevices = <BluetoothInfo>[];
  bool _isConnected = false;
  Future<void> _getAvailableDevices() async {
    if (await PrintBluetoothThermal.isPermissionBluetoothGranted) {
      _availableDevices
        ..clear()
        ..addAll([...(await PrintBluetoothThermal.pairedBluetooths)]);
      _isConnected = await PrintBluetoothThermal.connectionStatus;
    } else {
      await _getPermissions();
    }
    notifyListeners();
  }

  Future<bool> _connectBluetooth(String macAddr) async {
    final _result = await PrintBluetoothThermal.connect(
      macPrinterAddress: macAddr,
    );

    _isConnected = _result;
    notifyListeners();
    return _result;
  }

  Future<void> _showBluetoothDevices() async {
    return await showDialog<void>(
      context: GlobalContextHolder.context,
      builder: (modalContext) {
        return BluetoothDeviceDialog(
          devices: _availableDevices,
          onSelect: (value) async {
            final _isConnected = await showAsyncLoadingOverlay(
              modalContext,
              asyncFunction: () => _connectBluetooth(value.macAdress),
            );
            if (modalContext.mounted) {
              Navigator.of(modalContext).pop();
              if (_isConnected) {
                showCustomSnackBar(
                  modalContext,
                  content: Text('Successfully  Connected to: ${value.name}'),
                  customSnackBarType: CustomOverlayType.success,
                );
                return;
              }

              showCustomSnackBar(
                modalContext,
                content: Text('Failed to connect to ${value.name}'),
                customSnackBarType: CustomOverlayType.error,
              );
              return;
            }
          },
        );
      },
    );
  }

  Future<bool> printInvoice(ThermalInvoiceTemplateBase template) async {
    if (_isConnected) {
      return await PrintBluetoothThermal.writeBytes(await template.template);
    }

    return await _getAvailableDevices().then(
      (_) => _showBluetoothDevices().then(
        (_) async {
          return await PrintBluetoothThermal.writeBytes(
            await template.template,
          );
        },
      ),
    );
  }
}

final thermalPrinterGeneratorProvider = ChangeNotifierProvider(
  ThermalPrinterGenerator.new,
);
