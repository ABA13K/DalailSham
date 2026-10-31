import 'package:equatable/equatable.dart';

/// A single message inside a place chat room.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.isMine = false,
  });

  final String id;
  final String author;
  final String text;
  final DateTime createdAt;
  final bool isMine;

  @override
  List<Object?> get props => [id, author, text, createdAt, isMine];
}
