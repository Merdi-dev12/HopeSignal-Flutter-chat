import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ble_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../domain/entities/ble_message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final BleRepository repository;
  StreamSubscription? _messageSubscription;

  ChatBloc(this.repository) : super(ChatState()) {
    on<InitChatEvent>((event, emit) {
      _messageSubscription?.cancel();
      _messageSubscription = repository.messagesStream.listen((messages) {
        for (var msg in messages) {
          add(OnMessageReceivedEvent(msg));
        }
      });
      emit(state.copyWith(isReady: true));
    });

    on<SendTextMessageEvent>((event, emit) async {
      if (event.text.isNotEmpty) {
        try {
          await repository.sendMessage(event.text);

          final myMsg = BleMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: event.text,
            timestamp: DateTime.now(),
            isFromMe: true,
          );

          emit(state.copyWith(messages: [myMsg, ...state.messages]));
        } catch (e) {
          emit(state.copyWith(error: "Échec de l'envoi : $e"));
        }
      }
    });

    on<OnMessageReceivedEvent>((event, emit) {
      emit(state.copyWith(messages: [event.message, ...state.messages]));
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
