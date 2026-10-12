import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/index.dart';

class MarkdownMessageWidget extends StatelessWidget {
  final String text;
  final bool isUser;
  final List<String> suggestions;
  final Function(String)? onSuggestionTap;

  const MarkdownMessageWidget({
    super.key,
    required this.text,
    required this.isUser,
    this.suggestions = const [],
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main message content
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : theme.cardColor,
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomLeft:
                  isUser ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight:
                  isUser ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isUser ? _buildUserMessage() : _buildAIMessage(context),
        ),

        // Suggestions for AI messages
        if (!isUser && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSuggestions(context),
        ],
      ],
    );
  }

  Widget _buildUserMessage() {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        height: 1.4,
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white : Colors.black87);
    final codeBgColor = isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100;
    final codeBorderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return MarkdownBody(
      data: text,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
      styleSheet: MarkdownStyleSheet(
        // Paragraph style
        p: TextStyle(
          color: textColor,
          fontSize: 16,
          height: 1.4,
        ),

        // Headers
        h1: const TextStyle(
          color: AppColors.primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        h2: const TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        h3: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),

        // Lists
        listBullet: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
        ),

        // Code
        code: TextStyle(
          backgroundColor: codeBgColor,
          color: AppColors.primary,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: codeBorderColor),
        ),

        // Links
        a: const TextStyle(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),

        // Emphasis
        strong: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        em: TextStyle(
          fontStyle: FontStyle.italic,
          color: textColor,
        ),

        // Blockquotes
        blockquote: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
          border: const Border(
            left: BorderSide(
              color: AppColors.primary,
              width: 4,
            ),
          ),
        ),

        // Tables
        tableHead: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        tableHeadAlign: TextAlign.center,
        tableBorder: TableBorder.all(
          color: codeBorderColor,
          width: 1,
        ),
        tableColumnWidth: const FlexColumnWidth(),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: suggestions.take(4).map((suggestion) {
        return GestureDetector(
          onTap: () => onSuggestionTap?.call(suggestion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(isDark ? 0.4 : 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
