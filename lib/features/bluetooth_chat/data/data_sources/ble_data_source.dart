import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';

class BleDataSource {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  
  // Remplacer par les UUID définis par tes amis sur l'ESP32
  final Uuid serviceUuid = Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final Uuid charUuid = Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  Stream<ConnectionStateUpdate> connect(String deviceId) {
    return _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 5),
    );
  }

  Future<void> write(String deviceId, List<int> data) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: charUuid,
      deviceId: deviceId,
    );
    await _ble.writeCharacteristicWithResponse(characteristic, value: data);
  }

  Stream<List<int>> subscribe(String deviceId) {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: charUuid,
      deviceId: deviceId,
    );
    return _ble.subscribeToCharacteristic(characteristic);
  }
}