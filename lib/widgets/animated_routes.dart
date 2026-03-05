import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRoute<T> {
  SlidePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  final Widget child;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
      ),
      child: child,
    );
  }
}

class FadePageRoute<T> extends PageRoute<T> {
  FadePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  final Widget child;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class ScalePageRoute<T> extends PageRoute<T> {
  ScalePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 350),
  });

  final Widget child;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      ),
      child: child,
    );
  }
}
