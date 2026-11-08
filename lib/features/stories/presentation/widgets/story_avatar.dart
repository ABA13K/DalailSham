import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/story.dart';

/// The round mark of the service that posted a story: its picture when it
/// carries one, its first letter otherwise.
class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    super.key,
    required this.service,
    required this.size,
    this.fallbackIcon,
  });

  final StoryService? service;
  final double size;

  /// Drawn instead of a letter for a story that names no service.
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final imageUrl = service?.imageUrl;

    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.brand, AppTheme.brandDeep],
        ),
      ),
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _mark(context),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _mark(context),
              )
            : _mark(context),
      ),
    );
  }

  Widget _mark(BuildContext context) {
    final name = service?.name;
    if (name == null || name.isEmpty) {
      return Center(
        child: Icon(
          fallbackIcon ?? Icons.article_rounded,
          size: size * .45,
          color: Colors.white,
        ),
      );
    }

    return Center(
      child: Text(
        // The first letter, taken as a whole code point so a name that opens
        // with an emoji is not cut in half.
        String.fromCharCode(name.runes.first).toUpperCase(),
        maxLines: 1,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .45,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}
