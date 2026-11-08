import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/chat/domain/entities/chat_message.dart';
import 'package:dali_alsham/features/chat/domain/repositories/chat_repository.dart';

/// On-device chat rooms, empty until the backend ships chat endpoints. Only
/// what the user actually writes is kept; nothing is invented on their behalf.
class LocalChatRepository implements ChatRepository {
  final _rooms = <String, List<ChatMessage>>{};
  int _nextLocalId = 1;

  @override
  Future<Result<List<ChatMessage>>> getMessages({
    required String placeId,
    required String placeName,
    required String locale,
  }) async {
    final room = _rooms.putIfAbsent(placeId, () => []);
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
