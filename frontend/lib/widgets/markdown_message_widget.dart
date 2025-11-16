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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main message content
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomLeft:
                  isUser ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight:
                  isUser ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
          _buildSuggestions(),
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
        p: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          height: 1.4,
        ),

        // Headers
        h1: TextStyle(
          color: AppColors.primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        h2: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        h3: TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),

        // Lists
        listBullet: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
        ),

        // Code
        code: TextStyle(
          backgroundColor: Colors.grey.shade100,
          color: AppColors.primary,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),

        // Links
        a: TextStyle(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),

        // Emphasis
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        em: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.black87,
        ),

        // Blockquotes
        blockquote: TextStyle(
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border(
            left: BorderSide(
              color: AppColors.primary,
              width: 4,
            ),
          ),
        ),

        // Tables
        tableHead: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        tableHeadAlign: TextAlign.center,
        tableBorder: TableBorder.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        tableColumnWidth: const FlexColumnWidth(),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: suggestions.take(4).map((suggestion) {
        return GestureDetector(
          onTap: () => onSuggestionTap?.call(suggestion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    suggestion,
                    style: TextStyle(
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
