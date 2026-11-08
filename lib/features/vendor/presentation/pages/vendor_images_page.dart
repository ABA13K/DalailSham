import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/repositories/avatar_picker.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/vendor_image.dart';
import '../../domain/repositories/vendor_image_repository.dart';
import '../cubit/vendor_images_cubit.dart';

/// `GET /vendor/images` — the sub-images of the signed-in vendor's service.
///
/// A new picture is stored waiting for an admin, so each tile says which side
/// of that approval it is on. The vendor can add until the endpoint says there
/// is no room left, remove one line, or clear the whole set.
class VendorImagesPage extends StatelessWidget {
  const VendorImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return BlocProvider(
      create: (context) => VendorImagesCubit(
        getIt<VendorImageRepository>(),
        getIt<AvatarPicker>(),
      )..load(locale),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.vendorImagesTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            BlocBuilder<VendorImagesCubit, VendorImagesState>(
              builder: (context, state) => state.gallery.images.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      key: const ValueKey('images-delete-all'),
                      tooltip: l10n.deleteAllImages,
                      icon: const Icon(Icons.delete_sweep_outlined),
                      onPressed: state.isBusy
                          ? null
                          : () => _confirmClear(context, state),
                    ),
            ),
          ],
        ),
        body: CenteredContent(
          child: BlocBuilder<VendorImagesCubit, VendorImagesState>(
            builder: (context, state) => switch (state.status) {
              VendorImagesStatus.initial || VendorImagesStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              VendorImagesStatus.failure => _ImagesMessage(
                message: l10n.placesError,
                action: FilledButton.icon(
                  key: const ValueKey('images-retry'),
                  onPressed: () => context.read<VendorImagesCubit>().load(
                    Localizations.localeOf(context).languageCode,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              VendorImagesStatus.ready => _Gallery(gallery: state),
            },
          ),
        ),
        floatingActionButton: BlocBuilder<VendorImagesCubit, VendorImagesState>(
          builder: (context, state) =>
              state.status == VendorImagesStatus.ready && !state.isBusy
              ? FloatingActionButton.extended(
                  key: const ValueKey('image-add'),
                  onPressed: state.gallery.canAdd
                      ? () => _write(
                          context,
                          () => context.read<VendorImagesCubit>().add(),
                        )
                      : null,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(l10n.addImage),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    VendorImagesState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VendorImagesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteAllImagesQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('images-clear-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAllImages),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final removed = state.gallery.images.length;
    final message = await cubit.clear();
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message ?? l10n.imagesRemovedAll(removed))),
      );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.gallery});

  final VendorImagesState gallery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final images = gallery.gallery.images;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.imagesIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.imagesLimit(images.length, gallery.gallery.maxAllowed),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (images.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _ImagesMessage(message: l10n.imagesEmpty),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 170,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ImageTile(
                  key: ValueKey('image-tile-${images[index].id}'),
                  image: images[index],
                  isBusy: gallery.isBusy,
                ),
                childCount: images.length,
              ),
            ),
          ),
        if (!gallery.gallery.canAdd && images.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Text(
                l10n.imagesLimitReached,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({super.key, required this.image, required this.isBusy});

  final VendorImage image;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(
              color: theme.colorScheme.primaryContainer,
              child: Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          if (!image.isApproved)
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.imagePendingApproval,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: IconButton(
              key: ValueKey('image-delete-${image.id}'),
              tooltip: l10n.deleteImage,
              icon: const Icon(Icons.close_rounded),
              onPressed: isBusy ? null : () => _confirmDelete(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VendorImagesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteImageQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('image-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteImage),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _write(context, () => cubit.remove(id: image.id));
  }
}

/// Runs a write and hands the backend's own sentence to the snack bar when it
/// refuses; a write that worked has already re-read the gallery.
Future<void> _write(
  BuildContext context,
  Future<String?> Function() write,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = await write();
  if (message == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _ImagesMessage extends StatelessWidget {
  const _ImagesMessage({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
