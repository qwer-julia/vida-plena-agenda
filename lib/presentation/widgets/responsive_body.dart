import 'package:flutter/material.dart';

/// Centraliza o conteúdo com largura máxima e margens que crescem em telas maiores.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.scrollable = true});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth >= 600 ? 32.0 : 16.0;
        final content = Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(padding: EdgeInsets.all(padding), child: child),
          ),
        );
        return SafeArea(
          child: scrollable ? SingleChildScrollView(child: content) : content,
        );
      },
    );
  }
}
