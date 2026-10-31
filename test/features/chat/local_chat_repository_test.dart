import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/chat/data/local_chat_repository.dart';
import 'package:dali_alsham/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seeds the demo conversation once per place', () async {
    final repository = LocalChatRepository();

    final first = await repository.getMessages(
      placeId: 'node/1',
      placeName: 'Nawfara Cafe',
      locale: 'en',
    );
    final messages = (first as Success<List<ChatMessage>>).value;
    expect(messages, hasLength(4));
    expect(messages.first.text, contains('Nawfara Cafe'));

    // A later read must not re-seed, even with different inputs.
    final again = await repository.getMessages(
      placeId: 'node/1',
      placeName: 'Ignored',
      locale: 'ar',
    );
    expect((again as Success<List<ChatMessage>>).value, hasLength(4));
  });

  test('arabic locale seeds an arabic conversation', () async {
    final repository = LocalChatRepository();

    final result = await repository.getMessages(
      placeId: 'node/2',
      placeName: 'مقهى النوفرة',
      locale: 'ar',
    );

    final messages = (result as Success<List<ChatMessage>>).value;
    expect(messages.first.text, contains('مفتوح'));
    expect(messages.first.text, contains('مقهى النوفرة'));
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
    expect(messages, hasLength(5));
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

    expect((other as Success<List<ChatMessage>>).value, hasLength(4));
  });
}
