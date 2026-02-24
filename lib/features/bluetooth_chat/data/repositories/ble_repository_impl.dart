import 'dart:convert';
import '../../domain/entities/ble_message.dart';
import '../../domain/repositories/ble_repository.dart';
import './../data_sources/ble_data_source.dart';

class BleRepositoryImpl implements BleRepository {
  final BleDataSource dataSource;
  String? _connectedDeviceId;

  BleRepositoryImpl(this.dataSource);

  @override
  Future<void> connect(String deviceId) async {
    _connectedDeviceId = deviceId;
    dataSource.connect(deviceId).listen((state) {
      print("État connexion: ${state.connectionState}");
    });
  }

  @override
  Future<void> sendMessage(String text) async {
    if (_connectedDeviceId != null) {
      await dataSource.write(_connectedDeviceId!, utf8.encode(text));
    }
  }

  @override
  Stream<List<BleMessage>> get messagesStream {
    // On transforme le flux de bytes venant de l'ESP32 en messages pour l'UI
    return dataSource
        .subscribe(_connectedDeviceId!)
        .map(
          (bytes) => [
            BleMessage(
              id: DateTime.now().toString(),
              text: utf8.decode(bytes),
              timestamp: DateTime.now(),
              isFromMe: false,
            ),
          ],
        );
  }

  @override
  Future<void> disconnect() async {
    _connectedDeviceId = null;
  }
}
