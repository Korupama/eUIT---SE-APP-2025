library auto_size_text;

import 'package:flutter/material.dart';

/// Minimal fallback implementation of AutoSizeText supporting single-line shrink.
/// This is a lightweight substitute when the package cannot be resolved.
class AutoSizeText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final int maxLines;
  final double minFontSize;
  final TextOverflow overflow;
  final double stepGranularity;

  const AutoSizeText(
    this.data, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.minFontSize = 8,
    this.overflow = TextOverflow.ellipsis,
    this.stepGranularity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseStyle = style ?? DefaultTextStyle.of(context).style;
        double currentSize = baseStyle.fontSize ?? 14;
        final double minSize = minFontSize;
        final double step = stepGranularity.clamp(0.1, 4.0);

        // Measure and shrink until fits width or reaches minSize.
        while (currentSize > minSize) {
          final tp = TextPainter(
            text: TextSpan(text: data, style: baseStyle.copyWith(fontSize: currentSize)),
            maxLines: maxLines,
            textDirection: TextDirection.ltr,
            ellipsis: overflow == TextOverflow.ellipsis ? '…' : null,
          )..layout(maxWidth: constraints.maxWidth);
          if (!tp.didExceedMaxLines && tp.width <= constraints.maxWidth) {
            break;
          }
          currentSize = (currentSize - step).clamp(minSize, currentSize);
          if (currentSize == minSize) break;
        }

        return Text(
          data,
            maxLines: maxLines,
            overflow: overflow,
            style: baseStyle.copyWith(fontSize: currentSize),
          );
      },
    );
  }
}

