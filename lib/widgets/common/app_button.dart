import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool fullWidth;
  final Color? color;
  final bool outlined;

  const AppButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.fullWidth = false,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = outlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? Theme.of(context).primaryColor),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: color,
          );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: child,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: child,
            ),
    );
  }
}
