import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/service_profile_cubit.dart';
import 'service_profile_shared.dart';

/// The service's own pictures, side by side, opening full-screen on tap.
class ServiceGalleryStrip extends StatelessWidget {
  const ServiceGalleryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ServiceProfileCubit, ServiceProfileState>(
      buildWhen: (previous, current) =>
          previous.galleryStatus != current.galleryStatus ||
          previous.images != current.images,
      builder: (context, state) => switch (state.galleryStatus) {
        ServiceGalleryStatus.initial ||
        ServiceGalleryStatus.loading => SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, _) =>
                const ShimmerBox(width: 160, height: 120, borderRadius: 16),
          ),
        ),
        ServiceGalleryStatus.failure => ServiceSectionMessage(
          icon: Icons.broken_image_outlined,
          message: l10n.galleryError,
          action: FilledButton.tonalIcon(
            onPressed: () => context.read<ServiceProfileCubit>().retryImages(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ),
        ServiceGalleryStatus.ready => state.images.isEmpty
            ? ServiceSectionMessage(
                icon: Icons.photo_library_outlined,
                message: l10n.imagesEmpty,
              )
            : SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) => _GalleryThumb(
                    url: state.images[index],
                    index: index,
                    images: state.images,
                  ),
                ),
              ),
      },
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    required this.url,
    required this.index,
    required this.images,
  });

  final String url;
  final int index;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('service-photo-$index'),
      onTap: () => showServiceGalleryViewer(
        context,
        images: images,
        initialIndex: index,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 160,
          height: 120,
          child: ServicePhoto(url: url, icon: Icons.photo_rounded),
        ),
      ),
    );
  }
}

/// Full-screen reader for the set: swipe between pictures, pinch to zoom.
Future<void> showServiceGalleryViewer(
  BuildContext context, {
  required List<String> images,
  int initialIndex = 0,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (dialogContext) => _GalleryViewer(
      images: images,
      initialIndex: initialIndex,
    ),
  );
}

class _GalleryViewer extends StatefulWidget {
  const _GalleryViewer({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) => InteractiveViewer(
                maxScale: 4,
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      key: const ValueKey('service-gallery-close'),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.galleryPosition(_index + 1, widget.images.length),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}