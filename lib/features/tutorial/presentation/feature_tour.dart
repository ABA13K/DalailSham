import 'package:flutter/material.dart';

import '../../../core/widgets/centered_content.dart';
import '../../../l10n/generated/app_localizations.dart';

/// One stop of the guided tour, optionally anchored to a widget on screen.
class TourStep {
  const TourStep({this.targetKey, required this.title, required this.body});

  final GlobalKey? targetKey;
  final String title;
  final String body;
}

/// Dims the screen, spotlights the current target, and explains it.
class FeatureTour extends StatefulWidget {
  const FeatureTour({super.key, required this.steps, required this.onFinished});

  final List<TourStep> steps;
  final VoidCallback onFinished;

  @override
  State<FeatureTour> createState() => _FeatureTourState();
}

class _FeatureTourState extends State<FeatureTour> {
  int _index = 0;
  Rect? _hole;

  @override
  void initState() {
    super.initState();
    _scheduleMeasure();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(_measure);
    });
  }

  void _measure() {
    final box = widget.steps[_index].targetKey?.currentContext
        ?.findRenderObject();
    _hole = box is RenderBox && box.hasSize && !box.size.isEmpty
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
  }

  void _next() {
    if (_index + 1 >= widget.steps.length) {
      widget.onFinished();
      return;
    }
    setState(() {
      _index++;
      _hole = null;
    });
    _scheduleMeasure();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final step = widget.steps[_index];
    final isLast = _index == widget.steps.length - 1;

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _next,
              child: CustomPaint(
                painter: _SpotlightPainter(
                  hole: _hole,
                  overlayColor: Colors.black.withValues(alpha: 0.72),
                  borderColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: CenteredContent(
              maxWidth: 460,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      18,
                      20,
                      12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                step.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '${_index + 1}/${widget.steps.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(step.body, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton(
                              onPressed: widget.onFinished,
                              child: Text(l10n.onboardingSkip),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: _next,
                              child: Text(
                                isLast
                                    ? l10n.tutorialDone
                                    : l10n.onboardingNext,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.hole,
    required this.overlayColor,
    required this.borderColor,
  });

  final Rect? hole;
  final Color overlayColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);

    RRect? spotlight;
    if (hole != null) {
      spotlight = RRect.fromRectAndRadius(
        hole!.inflate(8),
        const Radius.circular(20),
      );
      overlay.addRRect(spotlight);
    }

    canvas.drawPath(overlay, Paint()..color = overlayColor);
    if (spotlight != null) {
      canvas.drawRRect(
        spotlight,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = borderColor,
      );
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      hole != oldDelegate.hole ||
      overlayColor != oldDelegate.overlayColor ||
      borderColor != oldDelegate.borderColor;
}
