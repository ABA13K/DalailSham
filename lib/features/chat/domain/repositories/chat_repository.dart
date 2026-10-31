import 'package:dali_alsham/core/error/result.dart';

import '../entities/chat_message.dart';

abstract interface class ChatRepository {
  /// The conversation for a place, oldest first.
  Future<Result<List<ChatMessage>>> getMessages({
    required String placeId,
    required String placeName,
    required String locale,
  });

  /// Adds [text] to the room and returns the stored message.
  Future<Result<ChatMessage>> sendMessage({
    required String placeId,
    required String text,
  });
}
