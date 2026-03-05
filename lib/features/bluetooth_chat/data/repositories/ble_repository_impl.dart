import 'dart:convert';
import 'dart:typed_data';
import '../../domain/entities/ble_message.dart';
import '../../domain/repositories/ble_repository.dart'; 
import '../data_sources/bluetooth_classic_data_source.dart';

class BleRepositoryImpl implements BleRepository {
  final BluetoothClassicDataSource dataSource;

  BleRepositoryImpl(this.dataSource);

  @override
  Future<void> connect(String address) async {
    try {
      await dataSource.connect(address);
    } catch (e) {
      throw Exception("Erreur de connexion dans le Repository: $e");
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await dataSource.disconnect();
    } catch (e) {
      throw Exception("Erreur lors de la déconnexion: $e");
    }
  }

  @override
  Future<void> sendMessage(String text) async {
    try {
      // On ajoute \n pour que l'ESP32 sache que le message est complet
      await dataSource.write(utf8.encode("$text\n"));
    } catch (e) {
      throw Exception("Erreur d'envoi du message: $e");
    }
  }

  @override
  Stream<List<BleMessage>> get messagesStream {
    return dataSource.incomingMessages.map((Uint8List bytes) {
      // Conversion des bytes reçus de l'ESP32 en texte UTF-8
      final receivedText = utf8.decode(bytes).trim();

      return [
        BleMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: receivedText,
          timestamp: DateTime.now(),
          isFromMe: false, // Ce qui vient de la dataSource n'est pas de moi
        ),
      ];
    });
  }
}
