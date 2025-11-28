import 'package:cconnect/utils/helpers/system_ui_helper.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final TextStyle? titleStyle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // "only in the case of dark theme the app bar color should change as it is of now"
    // "custom app bar which will have balck text on white back ground" (implied for light mode)

    final Color effectiveBackgroundColor =
        backgroundColor ??
        (isDark
            ? Theme.of(context).appBarTheme.backgroundColor
            : Colors.white) ??
        (isDark ? Colors.black : Colors.white);

    final Color effectiveTextColor = isDark ? Colors.white : Colors.black;

    return AppBar(
      title: Text(
        title,
        style:
            titleStyle?.copyWith(color: effectiveTextColor) ??
            TextStyle(color: effectiveTextColor, fontWeight: FontWeight.bold),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: effectiveBackgroundColor,
      actions: actions,
      iconTheme: IconThemeData(
        color: effectiveTextColor,
      ), // Ensure back button/icons are visible
      systemOverlayStyle: SystemUiHelper.getOverlayStyle(context),
      shape: Border(
        bottom: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
