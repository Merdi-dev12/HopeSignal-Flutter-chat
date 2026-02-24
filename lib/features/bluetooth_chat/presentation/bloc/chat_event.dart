import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/entities/ble_message.dart';

abstract class ChatEvent {}

// Initialise la communication (découverte des services)
class InitChatEvent extends ChatEvent {
  final BluetoothDevice device;
  InitChatEvent(this.device);
}

// Envoi de texte
class SendTextMessageEvent extends ChatEvent {
  final String text;
  SendTextMessageEvent(this.text);
}

// Réception automatique (via notify)
class OnMessageReceivedEvent extends ChatEvent {
  final BleMessage message;
  OnMessageReceivedEvent(this.message);
}
