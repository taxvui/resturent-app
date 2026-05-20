import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../../widgets/widgets.dart';

class BluetoothDeviceDialog extends StatelessWidget {
  const BluetoothDeviceDialog({
    super.key,
    required this.devices,
    this.onSelect,
  });
  final List<BluetoothInfo> devices;
  final ValueChanged<BluetoothInfo>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: devices.isNotEmpty
              ? MediaQuery.sizeOf(context).height * 0.35
              : 150,
          maxHeight: devices.isNotEmpty
              ? MediaQuery.sizeOf(context).height * 0.65
              : 150,
        ),
        child: BottomModalSheetWrapper(
          title: TextSpan(text: 'Select Device'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Available Devices
              if (devices.isEmpty) ...[
                Flexible(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Devices Found.\nPlease Connect Your Device',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              ] else ...[
                Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: devices.length,
                    itemBuilder: (_, index) {
                      final _device = devices[index];
                      return ListTile(
                        title: Text(_device.name),
                        subtitle: Text(_device.macAdress),
                        onTap: () => onSelect?.call(_device),
                      );
                    },
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
