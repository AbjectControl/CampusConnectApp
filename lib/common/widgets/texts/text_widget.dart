import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool useOutlineColor;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.useOutlineColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = useOutlineColor ? theme.colorScheme.outline : style?.color;

    return Text(
      text,
      textAlign: textAlign,
      style: style?.copyWith(color: color) ??
          theme.textTheme.bodyMedium?.copyWith(color: color),
    );
  }
}
