import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/groq_chatbot_service.dart';
import '../widgets/markdown_message_widget.dart';
import '../themes/index.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;
  Map<String, dynamic>? _serverInfo;
  late String _userId; // Persistent user ID for conversation memory

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Generate a persistent user ID for this session
    _userId = 'bytebrain_user_${DateTime.now().millisecondsSinceEpoch}';

    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _initializeChat() async {
    // Check server status
    _serverInfo = await GroqChatbotService.getServerInfo();

    // Add welcome message
    setState(() {
      String welcomeMessage;
      if (_serverInfo?['available'] == true) {
        welcomeMessage =
            'Hello! I\'m Nova, your AI learning companion. I can help you with:\n\n🔢 Mathematics & Problem Solving\n🔬 Science & Research\n💻 Programming & Technology\n📚 Study Strategies & Learning\n📖 Literature & Writing\n🏛️ History & Social Studies\n\nWhat would you like to explore today?';
      } else {
        welcomeMessage =
            'Hello! I\'m Nova, your AI learning companion, but I\'m currently offline. Please make sure the server is running.\n\nTo start the server:\n1. Navigate to Byte_Brain folder\n2. Run: python simple_server.py\n3. Make sure your GROQ_API_KEY is set in .env\n\nThen restart this chat to connect!';
      }

      _messages.add(ChatMessage(
        id: 'welcome',
        text: welcomeMessage,
        isUser: false,
        timestamp: DateTime.now(),
        type: ChatMessageType.text,
      ));
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      type: ChatMessageType.text,
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Send message to Groq chatbot with user ID
      // Use persistent user ID for conversation memory
      final chatbotResponse =
          await GroqChatbotService.sendMessage(message, _userId);

      if (chatbotResponse.success) {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: chatbotResponse.reply,
            isUser: false,
            timestamp: DateTime.now(),
            type: ChatMessageType.text,
            suggestions: chatbotResponse.suggestions,
            isAdvanced: true, // Groq is advanced AI
          ));
          _isTyping = false;
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: chatbotResponse.reply,
            isUser: false,
            timestamp: DateTime.now(),
            type: ChatMessageType.error,
          ));
          _isTyping = false;
        });
      }

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Sorry, I encountered an error connecting to the Python chatbot. Please make sure the server is running.',
          isUser: false,
          timestamp: DateTime.now(),
          type: ChatMessageType.error,
        ));
        _isTyping = false;
      });
    }
  }

  // Removed _getAIResponse method as we now use GroqChatbotService

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nova AI',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _serverInfo?['available'] == true
                      ? 'Nova • Ready'
                      : 'Nova • Offline',
                  style: TextStyle(
                    color: _serverInfo?['available'] == true
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showChatOptions,
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                message.isAdvanced ? Icons.psychology : Icons.smart_toy,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Use markdown widget for better formatting
                  MarkdownMessageWidget(
                    text: message.text,
                    isUser: message.isUser,
                    suggestions: message.suggestions,
                    onSuggestionTap: _sendQuickMessage,
                  ),

                  // Timestamp and AI indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: message.isUser
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                        if (!message.isUser && message.isAdvanced) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.auto_awesome,
                            size: 10,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimationController,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final animationValue =
                            (_typingAnimationController.value + delay) % 1.0;
                        final opacity = (animationValue < 0.5)
                            ? animationValue * 2
                            : (1 - animationValue) * 2;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Opacity(
                            opacity: opacity.clamp(0.3, 1.0),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is typing...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (ActivateIntent intent) => _sendMessage(),
              ),
            },
            child: Row(
              children: [
                // Quick Actions Button
                IconButton(
                  onPressed: _showQuickActions,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),

                // Message Input Field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Ask Nova anything... (Press Enter to send)',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (text) {
                        // Optional: You can add typing indicators here later
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send Button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildQuickActionButton(
                  'Course Recommendations',
                  Icons.school,
                  () => _sendQuickMessage(
                      'Can you recommend some courses for me?'),
                ),
                _buildQuickActionButton(
                  'Study Tips',
                  Icons.lightbulb_outline,
                  () => _sendQuickMessage('Give me some effective study tips'),
                ),
                _buildQuickActionButton(
                  'Quiz Help',
                  Icons.quiz,
                  () => _sendQuickMessage('Help me prepare for a quiz'),
                ),
                _buildQuickActionButton(
                  'Learning Plan',
                  Icons.timeline,
                  () => _sendQuickMessage('Create a learning plan for me'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
      String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.refresh, color: AppColors.primary),
              title: const Text('Clear Chat'),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: AppColors.primary),
              title: const Text('View Conversation Context'),
              onTap: () {
                Navigator.pop(context);
                _showConversationContext();
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: AppColors.primary),
              title: const Text('Copy Last Response'),
              onTap: () {
                Navigator.pop(context);
                _copyLastResponse();
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback, color: AppColors.primary),
              title: const Text('Send Feedback'),
              onTap: () {
                Navigator.pop(context);
                _showFeedbackDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _clearChat() async {
    // Clear local messages
    setState(() {
      _messages.clear();
    });

    // Clear server-side history
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/chat/clear/$_userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Server history cleared successfully');
      }
    } catch (e) {
      print('Could not clear server history: $e');
    }

    _initializeChat();
  }

  void _showConversationContext() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/chat/context/$_userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final contextData = data['data'];

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Conversation Context'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('User ID: ${contextData['user_id']}'),
                    const SizedBox(height: 8),
                    Text('Messages: ${contextData['message_count']}'),
                    const SizedBox(height: 8),
                    Text('Topics Discussed:'),
                    ...List<Widget>.from(
                      (contextData['topics_discussed'] as List).map(
                        (topic) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text('• $topic'),
                        ),
                      ),
                    ),
                    if (contextData['topics_discussed'].isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 4),
                        child: Text('No specific topics identified yet'),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load context: $e')),
      );
    }
  }

  void _copyLastResponse() {
    final lastAIMessage = _messages.reversed.firstWhere(
      (msg) => !msg.isUser,
      orElse: () => ChatMessage(
        id: '',
        text: 'No AI response to copy',
        isUser: false,
        timestamp: DateTime.now(),
        type: ChatMessageType.text,
      ),
    );

    Clipboard.setData(ClipboardData(text: lastAIMessage.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Response copied to clipboard')),
    );
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'How can we improve the AI assistant?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final feedback = controller.text.trim();
              if (feedback.isNotEmpty) {
                try {
                  await http.post(
                    Uri.parse('http://localhost:5000/feedback'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'feedback': feedback,
                      'user_id': _userId,
                      'timestamp': DateTime.now().toIso8601String(),
                    }),
                  );
                } catch (e) {
                  print('Failed to send feedback: $e');
                }
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

// Chat Message Model
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType type;
  final List<String> suggestions;
  final bool isAdvanced;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.type,
    this.suggestions = const [],
    this.isAdvanced = false,
  });
}

enum ChatMessageType {
  text,
  image,
  file,
  error,
  system,
}
