import 'package:flutter/material.dart';

class SlideFromRightRoute extends PageRouteBuilder {
  final Curve curve;
  final Duration duration;
  final Widget page;

  SlideFromRightRoute(
      {this.page,
      this.curve = Curves.easeInOut,
      this.duration = const Duration(microseconds: 300)})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: duration,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: child,
          ),
        );
}

class FadeRoute extends PageRouteBuilder {
  final Curve curve;
  final Duration duration;
  final Widget page;

  FadeRoute(
      {this.page,
      this.curve = Curves.easeInOut,
      this.duration = const Duration(microseconds: 300)})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: duration,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1)
                .chain(CurveTween(curve: curve))
                .animate(animation),
            child: child,
          ),
        );
}
