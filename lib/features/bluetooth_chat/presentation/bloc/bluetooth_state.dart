import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothBlocState {}

class BluetoothInitial extends BluetoothBlocState {}

class ScanningState extends BluetoothBlocState {
  final List<ScanResult> results;
  ScanningState(this.results);
}

class ConnectingState extends BluetoothBlocState {
  final BluetoothDevice device;
  ConnectingState(this.device);
}

class ConnectedState extends BluetoothBlocState {
  final BluetoothDevice device;
  ConnectedState(this.device);
}

class BluetoothErrorState extends BluetoothBlocState {
  final String message;
  BluetoothErrorState(this.message);
}
