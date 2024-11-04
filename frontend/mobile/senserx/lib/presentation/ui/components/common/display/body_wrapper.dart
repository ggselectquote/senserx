import 'package:flutter/material.dart';

class BodyWrapper extends StatelessWidget {
  final Widget child;
  final double paddingLeft;
  final double paddingRight;

  const BodyWrapper({
    super.key,
    required this.child,
    this.paddingLeft = 25.0,
    this.paddingRight = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(paddingLeft, 0, paddingRight, 0),
      child: child,
    );
  }
}