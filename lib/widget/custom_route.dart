// ignore_for_file: prefer_const_constructors, override_on_non_overriding_member

import 'package:flutter/cupertino.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  CustomPageRoute({
    required this.child,
  }) : super(
            transitionDuration: Duration(milliseconds: 200),
            pageBuilder: (context, animation, secondaryAnimation) => child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(-1,0), end: Offset.zero)
          .animate(animation),
      child: child,
    );
  }
}
