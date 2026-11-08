import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_story.dart';
import '../../domain/entities/vendor_story_edit.dart';
import '../../domain/repositories/story_file_picker.dart';
import '../../domain/repositories/vendor_story_repository.dart';
import '../cubit/vendor_story_cubit.dart';

/// `POST /vendor/stories` — one call, whose `type` decides whether a picture, a
/// clip or a poll rides with it.
class VendorStoryFormPage extends StatefulWidget {
  const VendorStoryFormPage({super.key});

  @override
  State<VendorStoryFormPage> createState() => _VendorStoryFormPageState();
}

/// One choice the vendor is offering in a poll.
class _OptionRow {
  _OptionRow()
    : arabic = TextEditingController(),
      english = TextEditingController();

  final TextEditingController arabic;
  final TextEditingController english;

  void dispose() {
    arabic.dispose();
    english.dispose();
  }
}

class _VendorStoryFormPageState extends State<VendorStoryFormPage> {
  static const _textCeiling = 255;
  static const _minOptions = 2;
  static const _maxOptions = 5;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// The page owns the write it is making, so the cubit lives here rather than
  /// in a shared list page that could hand it a story the vendor never left.
  late final VendorStoryCubit _cubit = VendorStoryCubit(
    getIt<VendorStoryRepository>(),
  );

  VendorStoryType _type = VendorStoryType.image;
  final TextEditingController _captionAr = TextEditingController();
  final TextEditingController _captionEn = TextEditingController();
  final TextEditingController _questionAr = TextEditingController();
  final TextEditingController _questionEn = TextEditingController();

  /// A poll starts with the fewest choices the endpoint accepts.
  final List<_OptionRow> _options = [_OptionRow(), _OptionRow()];

  /// The picture or clip chosen on the device. Nothing uploads until the story
  /// is posted, so it rides with the write.
  AvatarFile? _file;

  @override
  void dispose() {
    _cubit.close();
    _captionAr.dispose();
    _captionEn.dispose();
    _questionAr.dispose();
    _questionEn.dispose();
    for (final option in _options) {
      option.dispose();
    }
    super.dispose();
  }

  void _choose(VendorStoryType type) {
    if (type == _type) return;
    // A clip is not a picture, and neither is a question, so the file chosen
    // for the type the vendor left cannot ride with the new one.
    final keepsFile = type.fileField == _type.fileField;
    setState(() {
      _type = type;
      if (!keepsFile) _file = null;
    });
  }

  Future<void> _pickFile() async {
    final picker = getIt<StoryFilePicker>();
    final file = switch (_type) {
      VendorStoryType.image => await picker.pickImage(),
      VendorStoryType.video => await picker.pickVideo(),
      VendorStoryType.poll => null,
    };
    if (file == null || !mounted) return;
    setState(() => _file = file);
  }

  void _addOption() {
    if (_options.length >= _maxOptions) return;
    setState(() => _options.add(_OptionRow()));
  }

  void _removeOption(int index) {
    if (_options.length <= _minOptions) return;
    setState(() => _options.removeAt(index).dispose());
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    void notify(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final fileField = _type.fileField;
    if (fileField != null && _file == null) {
      notify(
        fileField == 'image'
            ? l10n.storyPhotoRequired
            : l10n.storyVideoRequired,
      );
      return;
    }

    VendorStoryPollEdit? poll;
    if (_type == VendorStoryType.poll) {
      // A row the vendor left blank is not a choice, so it does not travel.
      final options = [
        for (final row in _options)
          if (row.arabic.text.trim().isNotEmpty)
            VendorStoryOptionEdit(
              optionAr: row.arabic.text.trim(),
              optionEn: _blank(row.english.text),
            ),
      ];
      if (options.length < _minOptions) {
        notify(l10n.storyOptionsTooFew);
        return;
      }
      poll = VendorStoryPollEdit(
        questionAr: _questionAr.text.trim(),
        questionEn: _blank(_questionEn.text),
        options: options,
      );
    }

    final message = await _cubit.post(
      edit: VendorStoryEdit(
        type: _type,
        captionAr: _blank(_captionAr.text),
        captionEn: _blank(_captionEn.text),
        poll: poll,
      ),
      file: _file,
      locale: locale,
    );
    if (message != null) {
      notify(message);
      return;
    }
    notify(l10n.storySaved);
    if (!mounted) return;
    GoRouter.of(context).pop();
  }

  static String? _blank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String? checkOptional(String? value) =>
        (value?.length ?? 0) > _textCeiling ? l10n.tooLong : null;

    String? checkQuestion(String? value) {
      final required =
          value == null || value.trim().isEmpty ? l10n.fieldRequired : null;
      if (required != null) return required;
      return value!.length > _textCeiling ? l10n.tooLong : null;
    }

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.vendorStoriesTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CenteredContent(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.storyTypeTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in VendorStoryType.values)
                        ChoiceChip(
                          key: ValueKey('story-type-${type.wire}'),
                          label: Text(_typeLabel(l10n, type)),
                          avatar: Icon(_typeIcon(type)),
                          selected: _type == type,
                          onSelected: (_) => _choose(type),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_type != VendorStoryType.poll) ...[
                    _Media(
                      type: _type,
                      file: _file,
                      onPick: _pickFile,
                    ),
                    const SizedBox(height: 16),
                  ],
                  AuthTextField(
                    key: const ValueKey('story-caption-ar'),
                    controller: _captionAr,
                    label: l10n.storyCaptionArabicLabel,
                    maxLines: 3,
                    validator: checkOptional,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    key: const ValueKey('story-caption-en'),
                    controller: _captionEn,
                    label: l10n.storyCaptionEnglishLabel,
                    maxLines: 3,
                    validator: checkOptional,
                  ),
                  if (_type == VendorStoryType.poll) ...[
                    const SizedBox(height: 20),
                    AuthTextField(
                      key: const ValueKey('story-question-ar'),
                      controller: _questionAr,
                      label: l10n.storyQuestionArabicLabel,
                      validator: checkQuestion,
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      key: const ValueKey('story-question-en'),
                      controller: _questionEn,
                      label: l10n.storyQuestionEnglishLabel,
                      validator: checkOptional,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.storyOptionsLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    for (var index = 0; index < _options.length; index++)
                      _option(l10n, index),
                    if (_options.length < _maxOptions) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          key: const ValueKey('story-option-add'),
                          onPressed: _addOption,
                          icon: const Icon(Icons.add_circle_rounded),
                          label: Text(l10n.storyAddOption),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                  BlocBuilder<VendorStoryCubit, VendorStoryState>(
                    builder: (context, state) => FilledButton(
                      key: const ValueKey('story-save'),
                      onPressed: state.isBusy ? null : _submit,
                      child: state.isBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.storyPublish),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.storyWaitsForApproval,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A choice and the button that removes it, which only appears once there
  /// are more choices than the endpoint needs.
  Widget _option(AppLocalizations l10n, int index) {
    final theme = Theme.of(context);
    final row = _options[index];

    String? checkLength(String? value) =>
        (value?.length ?? 0) > _textCeiling ? l10n.tooLong : null;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.storyOptionLabel(index + 1),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                AuthTextField(
                  key: ValueKey('story-option-ar-$index'),
                  controller: row.arabic,
                  label: l10n.storyCaptionArabicLabel,
                  validator: checkLength,
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  key: ValueKey('story-option-en-$index'),
                  controller: row.english,
                  label: l10n.storyCaptionEnglishLabel,
                  validator: checkLength,
                ),
              ],
            ),
          ),
          if (_options.length > _minOptions)
            IconButton(
              key: ValueKey('story-option-remove-$index'),
              tooltip: l10n.storyRemoveOption,
              icon: const Icon(Icons.remove_circle_outline_rounded),
              onPressed: () => _removeOption(index),
            ),
        ],
      ),
    );
  }

  static String _typeLabel(
    AppLocalizations l10n,
    VendorStoryType type,
  ) => switch (type) {
    VendorStoryType.image => l10n.storyTypeImage,
    VendorStoryType.video => l10n.storyTypeVideo,
    VendorStoryType.poll => l10n.storyTypePoll,
  };

  static IconData _typeIcon(VendorStoryType type) => switch (type) {
    VendorStoryType.image => Icons.image_rounded,
    VendorStoryType.video => Icons.movie_creation_rounded,
    VendorStoryType.poll => Icons.poll_rounded,
  };
}

/// The picture or clip chosen for the story, and the button that opens the
/// gallery for it.
class _Media extends StatelessWidget {
  const _Media({
    required this.type,
    required this.file,
    required this.onPick,
  });

  final VendorStoryType type;
  final AvatarFile? file;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isVideo = type == VendorStoryType.video;

    Widget placeholder() => ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Icon(
        isVideo ? Icons.smart_display_rounded : Icons.add_a_photo_rounded,
        size: 48,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );

    Widget preview = switch ((type, file)) {
      (VendorStoryType.poll, _) => placeholder(),
      (_, null) => placeholder(),
      (VendorStoryType.video, final AvatarFile clip) => _Clip(
        fileName: clip.fileName,
      ),
      (VendorStoryType.image, final AvatarFile picture) => Image.memory(
        picture.bytes,
        fit: BoxFit.cover,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: preview,
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const ValueKey('story-pick-file'),
            onPressed: onPick,
            icon: Icon(
              isVideo
                  ? Icons.movie_creation_rounded
                  : Icons.image_rounded,
            ),
            label: Text(isVideo ? l10n.storyPickVideo : l10n.storyPickPhoto),
          ),
        ),
      ],
    );
  }
}

/// A clip has no frame the app can draw, so the chosen file is named instead.
class _Clip extends StatelessWidget {
  const _Clip({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_rounded,
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
