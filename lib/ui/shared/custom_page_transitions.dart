import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fade transition page - smooth fade in/out
/// Dùng cho: login, home transitions
class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [FadeTransitionPage]
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation.drive(_curveTween),
            child: child,
          ),
        );

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeInOut);
}

/// Slide up transition page - slides from bottom
/// Dùng cho: signup, add screens (modal-like)
class SlideUpTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [SlideUpTransitionPage]
  SlideUpTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
          transitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(0.0, 1.0), // Start from bottom
                end: Offset.zero, // End at normal position
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          ),
        );
}

// Note: NoTransitionPage đã có sẵn trong go_router package
// Dùng trực tiếp: NoTransitionPage<void>(key: state.pageKey, child: ...)

