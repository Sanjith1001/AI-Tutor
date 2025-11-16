import 'package:flutter/material.dart';

class YouTubeStyleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onMorePressed;
  final bool showLogo;

  const YouTubeStyleAppBar({
    Key? key,
    required this.title,
    this.onSearchPressed,
    this.onMorePressed,
    this.showLogo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.white,
      title: Row(
        children: [
          if (showLogo) ...[
            // YouTube-style logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Videos',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (onSearchPressed != null)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: onSearchPressed,
            tooltip: 'Search videos',
          ),
        if (onMorePressed != null)
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: onMorePressed,
            tooltip: 'More options',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
