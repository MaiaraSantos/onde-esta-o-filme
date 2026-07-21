import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LogoWidget extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showText;

  const LogoWidget({
    super.key,
    this.iconSize = 32,
    this.fontSize = 20,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/logo.png',
        // Usamos o showText para saber se é a versão grande (sidebar) ou pequena (mobile top bar)
        width: showText ? iconSize * 8.4 : iconSize * 3.675,
        fit: BoxFit.contain,
      ),
    );
  }
}
