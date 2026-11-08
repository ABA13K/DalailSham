import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

enum ChatStatus { initial, loading, ready, failure }

class ChatState extends Equatable {
  const ChatState({this.status = ChatStatus.initial, this.messages = const []});

  final ChatStatus status;
  final List<ChatMessage> messages;

  ChatState copyWith({ChatStatus? status, List<ChatMessage>? messages}) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
      );

  @override
  List<Object?> get props => [status, messages];
}

/// Holds the conversation of one place's chat room.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatState());

  final ChatRepository _repository;
  String _placeId = '';

  Future<void> load({
    required String placeId,
    required String placeName,
    required String locale,
  }) async {
    _placeId = placeId;
    emit(const ChatState(status: ChatStatus.loading));
    final result = await _repository.getMessages(
      placeId: placeId,
      placeName: placeName,
      locale: locale,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(const ChatState(status: ChatStatus.failure)),
      (messages) =>
          emit(ChatState(status: ChatStatus.ready, messages: messages)),
    );
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final result = await _repository.sendMessage(
      placeId: _placeId,
      text: trimmed,
    );
    if (isClosed) return;
    result.fold(
      (failure) {},
      (message) => emit(state.copyWith(messages: [...state.messages, message])),
    );
  }
}
