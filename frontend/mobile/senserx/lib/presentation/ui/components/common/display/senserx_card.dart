import 'package:flutter/material.dart';

class SenseRxCard extends StatelessWidget {
  List<Widget> children;
  CrossAxisAlignment? crossAxisAlignment;
  MainAxisSize? mainAxisSize;
  MainAxisAlignment? mainAxisAlignment;
  EdgeInsets? margin;
  EdgeInsets? padding;

  SenseRxCard({
    super.key,
    required this.children,
    this.mainAxisSize,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8,
        margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white.withOpacity(0.90),
        child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: Column(
                mainAxisSize: mainAxisSize ?? MainAxisSize.min,
                mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
                crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
                children: children)));
  }
}
