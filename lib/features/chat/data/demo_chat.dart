import '../domain/entities/chat_message.dart';

/// Seeded conversations so the demo room feels alive before the API exists.
List<ChatMessage> demoChatMessages({
  required String placeName,
  required String locale,
}) {
  final now = DateTime.now();
  if (locale == 'ar') {
    return [
      ChatMessage(
        id: 'demo/1',
        author: 'سارة',
        text: 'هل $placeName مفتوح الليلة؟',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      ChatMessage(
        id: 'demo/2',
        author: 'عمر',
        text: 'نعم، حتى منتصف الليل — الجلوس الخارجي جميل هذا المساء.',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 40)),
      ),
      ChatMessage(
        id: 'demo/3',
        author: placeName,
        text: 'أهلاً بالجميع! اسألونا عن القائمة وأوقات الدوام والحجوزات.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'demo/4',
        author: 'ليلى',
        text: 'شاركونا عروض اليوم من فضلكم.',
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
    ];
  }

  return [
    ChatMessage(
      id: 'demo/1',
      author: 'Sara',
      text: 'Is $placeName open tonight?',
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
    ChatMessage(
      id: 'demo/2',
      author: 'Omar',
      text: 'Yes, until midnight — the outdoor seating is lovely this evening.',
      createdAt: now.subtract(const Duration(hours: 2, minutes: 40)),
    ),
    ChatMessage(
      id: 'demo/3',
      author: placeName,
      text: 'Welcome everyone! Ask us anything about the menu, hours or reservations.',
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    ChatMessage(
      id: 'demo/4',
      author: 'Layla',
      text: "Please share today's offers.",
      createdAt: now.subtract(const Duration(minutes: 45)),
    ),
  ];
}
