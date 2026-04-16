import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'auth_backend_service.dart';

class ChatService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static String? _currentCourseId;
  static Function(Map<String, dynamic>)? _onMessageReceived;
  static Function(Map<String, dynamic>)? _onUserJoined;
  static Function(Map<String, dynamic>)? _onUserLeft;
  static Function(Map<String, dynamic>)? _onTyping;
  static Function(Map<String, dynamic>)? _onStudySession;

  static Future<String> _resolveSocketUrl() async {
    final envSocket = dotenv.env['SOCKET_URL'];
    if (envSocket != null && envSocket.isNotEmpty) {
      return envSocket;
    }

    final envApi = AuthBackendService.envBaseUrl;
    if (envApi != null) {
      return envApi.replaceFirst(RegExp(r'/api/?$'), '');
    }

    final base = await AuthBackendService.getBaseUrl();
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  // Initialize socket connection
  static Future<bool> connect() async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        print('❌ No auth token available for chat');
        return false;
      }

      print('🔄 Attempting to connect to chat server...');
      final socketUrl = await _resolveSocketUrl();
      print('🌐 Chat socket URL: $socketUrl');

      _socket = IO.io(
          socketUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .enableAutoConnect()
              .setAuth({'token': token})
              .setTimeout(5000) // 5 second timeout
              .build());

      _socket!.onConnect((_) {
        print('🔥 Connected to chat server');
        _isConnected = true;
      });

      _socket!.onDisconnect((_) {
        print('💔 Disconnected from chat server');
        _isConnected = false;
      });

      _socket!.onConnectError((error) {
        print('❌ Chat connection error: $error');
        _isConnected = false;
      });

      // Listen for messages
      _socket!.on('new_message', (data) {
        print('📨 New message: $data');
        if (_onMessageReceived != null) {
          _onMessageReceived!(Map<String, dynamic>.from(data));
        }
      });

      // Listen for user events
      _socket!.on('user_joined_course', (data) {
        print('👋 User joined: $data');
        if (_onUserJoined != null) {
          _onUserJoined!(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('user_left_course', (data) {
        print('👋 User left: $data');
        if (_onUserLeft != null) {
          _onUserLeft!(Map<String, dynamic>.from(data));
        }
      });

      // Listen for typing events
      _socket!.on('user_typing', (data) {
        if (_onTyping != null) {
          _onTyping!(Map<String, dynamic>.from(data));
        }
      });

      // Listen for study sessions
      _socket!.on('study_session_created', (data) {
        print('📚 Study session created: $data');
        if (_onStudySession != null) {
          _onStudySession!(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('participant_joined', (data) {
        print('👥 Participant joined study session: $data');
        if (_onStudySession != null) {
          _onStudySession!(Map<String, dynamic>.from(data));
        }
      });

      // Listen for errors
      _socket!.on('error', (error) {
        print('❌ Chat error: $error');
      });

      _socket!.connect();

      // Wait for connection with timeout
      await Future.delayed(Duration(seconds: 2));

      if (_isConnected) {
        print('✅ Chat connected successfully');
        return true;
      } else {
        print('⚠️ Chat connection timeout - continuing without chat');
        _socket?.disconnect();
        _socket = null;
        return false;
      }
    } catch (e) {
      print('❌ Failed to connect to chat: $e');
      print('💡 Chat features will be disabled. Make sure backend is running.');
      _socket?.disconnect();
      _socket = null;
      return false;
    }
  }

  // Disconnect from chat
  static void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      _currentCourseId = null;
      print('🔌 Disconnected from chat');
    }
  }

  // Join a course chat room
  static void joinCourse(String courseId) {
    if (_socket != null && _isConnected) {
      _currentCourseId = courseId;
      _socket!.emit('join_course', {'courseId': courseId});
      print('🏫 Joining course chat: $courseId');
    }
  }

  // Leave current course chat room
  static void leaveCourse() {
    if (_socket != null && _isConnected && _currentCourseId != null) {
      _socket!.emit('leave_course', {'courseId': _currentCourseId});
      print('🚪 Leaving course chat: $_currentCourseId');
      _currentCourseId = null;
    }
  }

  // Send a message
  static void sendMessage(String message, {String type = 'text'}) {
    if (_socket != null && _isConnected && _currentCourseId != null) {
      _socket!.emit('send_message', {
        'courseId': _currentCourseId,
        'message': message,
        'type': type,
      });
      print('📤 Sending message: $message');
    }
  }

  // Send typing indicator
  static void startTyping() {
    if (_socket != null && _isConnected && _currentCourseId != null) {
      _socket!.emit('typing_start', {'courseId': _currentCourseId});
    }
  }

  static void stopTyping() {
    if (_socket != null && _isConnected && _currentCourseId != null) {
      _socket!.emit('typing_stop', {'courseId': _currentCourseId});
    }
  }

  // Start a study session
  static void startStudySession(String sessionName, {String? description}) {
    if (_socket != null && _isConnected && _currentCourseId != null) {
      _socket!.emit('start_study_session', {
        'courseId': _currentCourseId,
        'sessionName': sessionName,
        'description': description,
      });
      print('📚 Starting study session: $sessionName');
    }
  }

  // Join a study session
  static void joinStudySession(String sessionId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join_study_session', {'sessionId': sessionId});
      print('👥 Joining study session: $sessionId');
    }
  }

  // Set event listeners
  static void setMessageListener(Function(Map<String, dynamic>) callback) {
    _onMessageReceived = callback;
  }

  static void setUserJoinedListener(Function(Map<String, dynamic>) callback) {
    _onUserJoined = callback;
  }

  static void setUserLeftListener(Function(Map<String, dynamic>) callback) {
    _onUserLeft = callback;
  }

  static void setTypingListener(Function(Map<String, dynamic>) callback) {
    _onTyping = callback;
  }

  static void setStudySessionListener(Function(Map<String, dynamic>) callback) {
    _onStudySession = callback;
  }

  // Getters
  static bool get isConnected => _isConnected;
  static String? get currentCourseId => _currentCourseId;
}
