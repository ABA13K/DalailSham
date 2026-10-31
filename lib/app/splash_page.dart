import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/domain/onboarding_repository.dart';

/// Animated logo launch screen; hands off to onboarding or home.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onboarding});

  static const duration = Duration(milliseconds: 2200);

  final OnboardingRepository onboarding;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: SplashPage.duration)
        ..addStatusListener(_handleStatus)
        ..forward();

  late final Animation<double> _circleOpacity = Tween<double>(begin: 0, end: 1)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.4, curve: Curves.easeIn),
        ),
      );

  late final Animation<double> _circleScale = Tween<double>(begin: 0.3, end: 1)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
        ),
      );

  late final Animation<double> _circleRotation =
      Tween<double>(begin: -0.25, end: 0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
        ),
      );

  late final Animation<double> _towerOpacity = Tween<double>(begin: 0, end: 1)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.25, 0.6, curve: Curves.easeIn),
        ),
      );

  late final Animation<Offset> _towerSlide =
      Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
        ),
      );

  late final Animation<double> _textOpacity = Tween<double>(begin: 0, end: 1)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.6, 1, curve: Curves.easeIn),
        ),
      );

  late final Animation<Offset> _textSlide =
      Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.6, 1, curve: Curves.easeOutCubic),
        ),
      );

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openNext();
    });
  }

  Future<void> _openNext() async {
    final completed = await widget.onboarding.hasCompleted();
    if (!mounted) return;
    context.go(completed ? '/' : '/onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      key: const ValueKey('splash-logo'),
                      width: 280,
                      height: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 65,
                            child: FadeTransition(
                              opacity: _circleOpacity,
                              child: ScaleTransition(
                                scale: _circleScale,
                                child: RotationTransition(
                                  turns: _circleRotation,
                                  child: Image.asset(
                                    'assets/images/circle.png',
                                    width: 190,
                                    height: 190,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SlideTransition(
                            position: _towerSlide,
                            child: FadeTransition(
                              opacity: _towerOpacity,
                              child: Image.asset(
                                'assets/images/tower.png',
                                width: 240,
                                height: 310,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Image.asset(
                          'assets/images/text.png',
                          width: 340,
                          height: 165,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
