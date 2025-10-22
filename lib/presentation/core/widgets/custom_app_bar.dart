import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHomePage;
  final bool isMobile;
  final double? mobileTitleSize;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSync;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isHomePage = false,
    this.isMobile = false,
    this.mobileTitleSize,
    this.onBackPressed,
    this.onSync,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      centerTitle: true,
      leading: isHomePage
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => context.pop(),
            ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isMobile ? (mobileTitleSize ?? 18) : 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (onSync != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: onSync,
          ),
      ],
    );
  }
}
