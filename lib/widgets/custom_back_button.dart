import 'package:flutter/material.dart';
import 'package:haogpt/generated/app_localizations.dart';

import '../core/theme/howai_theme.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const CustomBackButton({
    Key? key,
    this.onPressed,
    this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: color ?? context.howaiColors.textPrimary,
        size: size,
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      tooltip: AppLocalizations.of(context)?.back ?? 'Back',
      splashRadius: 20,
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.onBack,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: foregroundColor ?? context.howaiColors.textPrimary,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? context.howaiColors.canvas,
      foregroundColor: foregroundColor ?? context.howaiColors.textPrimary,
      elevation: elevation,
      leading: showBackButton
          ? CustomBackButton(
              onPressed: onBack,
              color: foregroundColor ?? context.howaiColors.textPrimary,
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
