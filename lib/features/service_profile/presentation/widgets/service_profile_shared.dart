import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// The icon-and-title line that opens every section of a service profile.
class ServiceSectionHeader extends StatelessWidget {
  const ServiceSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Five stars with a half step, so an average of 4.4 reads as 4.4 and not 4.
class ServiceStars extends StatelessWidget {
  const ServiceStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = const Color(0xFFFFB300),
  });

  final double rating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final empty = color.withValues(alpha: 0.28);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            rating >= star - 0.25
                ? Icons.star_rounded
                : rating >= star - 0.75
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: rating >= star - 0.75 ? color : empty,
          ),
      ],
    );
  }
}

/// A remote picture with the brand gradient standing in while it loads and
/// whenever it cannot be reached.
class ServicePhoto extends StatelessWidget {
  const ServicePhoto({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.icon = Icons.storefront_rounded,
  });

  final String? url;
  final BoxFit fit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
      ),
      child: Icon(
        icon,
        size: 28,
        color: scheme.onPrimary.withValues(alpha: 0.8),
      ),
    );
    final imageUrl = url;
    if (imageUrl == null) return placeholder;

    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (_, _, _) => DecoratedBox(
        decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
        child: Icon(Icons.broken_image_rounded, size: 28, color: scheme.outline),
      ),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const ShimmerBox(),
    );
  }
}

/// The line that replaces a section whose data is absent or did not arrive.
class ServiceSectionMessage extends StatelessWidget {
  const ServiceSectionMessage({
    super.key,
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: scheme.outline),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

/// The button that asks for the page after the rows already on screen.
class ServiceLoadMoreButton extends StatelessWidget {
  const ServiceLoadMoreButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.loadMore),
      ),
    );
  }
}