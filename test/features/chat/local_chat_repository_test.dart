import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/chat/data/local_chat_repository.dart';
import 'package:dali_alsham/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a room starts empty in every locale', () async {
    final repository = LocalChatRepository();

    final english = await repository.getMessages(
      placeId: 'node/1',
      placeName: 'Nawfara Cafe',
      locale: 'en',
    );
    expect((english as Success<List<ChatMessage>>).value, isEmpty);

    final arabic = await repository.getMessages(
      placeId: 'node/2',
      placeName: 'مقهى النوفرة',
      locale: 'ar',
    );
    expect((arabic as Success<List<ChatMessage>>).value, isEmpty);
  });

  test('appends sent messages to the room', () async {
    final repository = LocalChatRepository();
    await repository.getMessages(
      placeId: 'node/9',
      placeName: 'Souq Al Hamidiya',
      locale: 'en',
    );

    final sent = await repository.sendMessage(
      placeId: 'node/9',
      text: 'What time do you close?',
    );
    final message = (sent as Success<ChatMessage>).value;
    expect(message.isMine, isTrue);
    expect(message.text, 'What time do you close?');

    final room = await repository.getMessages(
      placeId: 'node/9',
      placeName: 'Souq Al Hamidiya',
      locale: 'en',
    );
    final messages = (room as Success<List<ChatMessage>>).value;
    expect(messages, hasLength(1));
    expect(messages.last.text, 'What time do you close?');
  });

  test('rooms are isolated per place', () async {
    final repository = LocalChatRepository();
    await repository.getMessages(
      placeId: 'node/a',
      placeName: 'Place A',
      locale: 'en',
    );
    await repository.sendMessage(placeId: 'node/a', text: 'hello');

    final other = await repository.getMessages(
      placeId: 'node/b',
      placeName: 'Place B',
      locale: 'en',
    );

    expect((other as Success<List<ChatMessage>>).value, isEmpty);
  });
}