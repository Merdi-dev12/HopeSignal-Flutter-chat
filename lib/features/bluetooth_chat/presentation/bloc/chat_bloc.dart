import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/repositories/ble_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../domain/entities/ble_message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final BleRepository repository;
  BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription? _lastSubscription;

  // UUIDs pour le service de chat (UART)
  static const String serviceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const String characteristicUuid =
      "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  ChatBloc(this.repository) : super(ChatState()) {
    // 1. Initialisation de la connexion texte
    on<InitChatEvent>((event, emit) async {
      try {
        List<BluetoothService> services = await event.device.discoverServices();
        for (var service in services) {
          if (service.uuid.toString().toLowerCase() == serviceUuid) {
            for (var char in service.characteristics) {
              if (char.uuid.toString().toLowerCase() == characteristicUuid) {
                _targetCharacteristic = char;

                // On s'abonne aux messages entrants venant de l'ESP32
                await char.setNotifyValue(true);
                _lastSubscription?.cancel();
                _lastSubscription = char.onValueReceived.listen((value) {
                  // Conversion des bytes reçus en texte
                  final text = utf8.decode(value);
                  add(
                    OnMessageReceivedEvent(
                      BleMessage(
                        id: DateTime.now().toString(),
                        text: text,
                        timestamp: DateTime.now(),
                        isFromMe: false,
                      ),
                    ),
                  );
                });

                emit(state.copyWith(isReady: true));
              }
            }
          }
        }
      } catch (e) {
        emit(state.copyWith(error: "Erreur d'initialisation : $e"));
      }
    });

    // 2. Envoi d'un message texte vers l'ESP32
    on<SendTextMessageEvent>((event, emit) async {
      if (_targetCharacteristic != null && event.text.isNotEmpty) {
        try {
          // Conversion du texte en bytes UTF-8 pour l'ESP32
          await _targetCharacteristic!.write(utf8.encode(event.text));

          final myMsg = BleMessage(
            id: DateTime.now().toString(),
            text: event.text,
            timestamp: DateTime.now(),
            isFromMe: true,
          );

          // Ajout du message à la liste locale
          emit(state.copyWith(messages: [myMsg, ...state.messages]));
        } catch (e) {
          emit(state.copyWith(error: "Échec de l'envoi du texte"));
        }
      }
    });

    // 3. Réception d'un message texte
    on<OnMessageReceivedEvent>((event, emit) {
      emit(state.copyWith(messages: [event.message, ...state.messages]));
    });
  }

  @override
  Future<void> close() {
    _lastSubscription?.cancel();
    return super.close();
  }
}
