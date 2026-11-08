import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/entities/story.dart';

/// The name and mark a story type is shown under, shared by the strip and the
/// full-screen viewer.
String storyTypeName(AppLocalizations l10n, StoryType type) => switch (type) {
  StoryType.image => l10n.storyTypeImage,
  StoryType.video => l10n.storyTypeVideo,
  StoryType.poll => l10n.storyTypePoll,
};

IconData storyTypeIcon(StoryType type) => switch (type) {
  StoryType.image => Icons.photo_camera_rounded,
  StoryType.video => Icons.play_arrow_rounded,
  StoryType.poll => Icons.poll_rounded,
};

/// Who posted the story, which is what a card is captioned with. A row with
/// neither a service nor a caption falls back to the type it is.
String storyCaptionFor(Story story, AppLocalizations l10n) =>
    story.service?.name ?? story.caption ?? storyTypeName(l10n, story.type);
