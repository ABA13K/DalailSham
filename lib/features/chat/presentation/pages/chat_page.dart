import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../places/domain/entities/place.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../cubit/chat_cubit.dart';

/// Chat room for a single place: conversation bubbles plus a composer.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final name = place.displayNameFor(locale);

    return BlocProvider(
      create: (_) => ChatCubit(getIt<ChatRepository>())
        ..load(placeId: place.id, placeName: name, locale: locale),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.chatRoomTitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        body: CenteredContent(
          child: Column(
            children: [
              const _ChatDemoNotice(),
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) => switch (state.status) {
                    ChatStatus.initial ||
                    ChatStatus.loading => const _ChatShimmer(),
                    ChatStatus.failure => Center(
                      child: Text(
                        l10n.chatError,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ChatStatus.ready => state.messages.isEmpty
                        ? Center(
                            child: Text(
                              l10n.chatEmpty,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            reverse: true,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: state.messages.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) => _MessageBubble(
                              message:
                                  state.messages[state.messages.length - 1 - index],
                            ),
                          ),
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const SafeArea(child: _ChatComposer()),
      ),
    );
  }
}

class _ChatDemoNotice extends StatelessWidget {
  const _ChatDemoNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.chatDemoNotice,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = message.isMine;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(message.createdAt),
    );

    final foreground = mine ? scheme.onPrimary : scheme.onSurface;
    final muted = mine
        ? scheme.onPrimary.withValues(alpha: 0.7)
        : scheme.onSurfaceVariant;

    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: mine ? scheme.primary : scheme.surfaceContainerHighest,
            borderRadius: mine
                ? const BorderRadiusDirectional.only(
                    topStart: Radius.circular(16),
                    topEnd: Radius.circular(16),
                    bottomStart: Radius.circular(16),
                    bottomEnd: Radius.circular(4),
                  )
                : const BorderRadiusDirectional.only(
                    topStart: Radius.circular(4),
                    topEnd: Radius.circular(16),
                    bottomStart: Radius.circular(16),
                    bottomEnd: Radius.circular(16),
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    message.author,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Text(message.text, style: theme.textTheme.bodyMedium?.copyWith(color: foreground)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  time,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatShimmer extends StatelessWidget {
  const _ChatShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Align(
        alignment: index.isOdd
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: ShimmerBox(width: 200, height: 48, borderRadius: 16),
      ),
    );
  }
}

class _ChatComposer extends StatefulWidget {
  const _ChatComposer();

  @override
  State<_ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<_ChatComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatCubit>().send(text);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('chat-input'),
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: l10n.chatHint,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            key: const ValueKey('chat-send'),
            tooltip: l10n.chatSend,
            onPressed: _controller.text.trim().isEmpty ? null : _send,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
