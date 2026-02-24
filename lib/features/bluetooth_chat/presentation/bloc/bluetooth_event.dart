import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothEvent {}

class StartScanEvent extends BluetoothEvent {}

class StopScanEvent extends BluetoothEvent {}

class ConnectToDeviceEvent extends BluetoothEvent {
  final BluetoothDevice device;
  ConnectToDeviceEvent(this.device);
}

class ToggleBluetoothEvent extends BluetoothEvent {
  final bool enable;
  ToggleBluetoothEvent(this.enable);
}