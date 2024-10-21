import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

enum BoxBehavior {
  card,
  semCard,
  cardDinamico,
}

class CenterBox extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final BoxBehavior boxBehavior;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  final bool expanded;

  const CenterBox({
    super.key,
    required this.child,
    this.maxWidth,
    this.boxBehavior = BoxBehavior.cardDinamico,
    this.elevation = 0,
    this.margin = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    this.padding = EdgeInsets.zero, this.borderRadius,
  }) : expanded = false;

  const CenterBox.expanded({
    super.key,
    required this.child,
    this.maxWidth,
    this.boxBehavior = BoxBehavior.cardDinamico,
    this.elevation = 0,
    this.margin = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
    this.borderRadius,
  }) : expanded = true;

  BorderRadius get getBorderRadius => borderRadius ?? BorderRadius.circular(18);

  double get defaultMaxWidth => maxWidth ?? (Platform.isWindows ? 800 : 600);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final mostrarCard = boxBehavior == BoxBehavior.card || (boxBehavior == BoxBehavior.cardDinamico && constraints.maxWidth > (defaultMaxWidth));

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: defaultMaxWidth,
              minHeight: expanded ? MediaQuery.sizeOf(context).height - kToolbarHeight - margin.vertical : 0,
              minWidth: min(defaultMaxWidth, constraints.maxWidth),
            ),
            child: mostrarCard
                ? Card(
                    elevation: elevation,
                    margin: margin,
                    shape: RoundedRectangleBorder(borderRadius: getBorderRadius),
                    child: ClipRRect(
                      borderRadius: getBorderRadius,
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: padding,
                          child: child,
                        ),
                      ),
                    ),
                  )
                : child,
          ),
        );
      },
    );
  }
}
