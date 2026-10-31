import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/chat/data/demo_chat.dart';
import 'package:dali_alsham/features/chat/domain/entities/chat_message.dart';
import 'package:dali_alsham/features/chat/domain/repositories/chat_repository.dart';

/// On-device chat rooms with seeded demo conversations, until the backend
/// ships chat endpoints.
class LocalChatRepository implements ChatRepository {
  final _rooms = <String, List<ChatMessage>>{};
  int _nextLocalId = 1;

  @override
  Future<Result<List<ChatMessage>>> getMessages({
    required String placeId,
    required String placeName,
    required String locale,
  }) async {
    final room = _rooms.putIfAbsent(
      placeId,
      () => demoChatMessages(placeName: placeName, locale: locale),
    );
    return Success(List<ChatMessage>.unmodifiable(room));
  }

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String placeId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: 'local/$_nextLocalId',
      author: '',
      text: text,
      createdAt: DateTime.now(),
      isMine: true,
    );
    _nextLocalId++;
    (_rooms[placeId] ??= []).add(message);
    return Success(message);
  }
}
