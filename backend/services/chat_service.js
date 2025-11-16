const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Course = require('../models/Course');

class ChatService {
  constructor() {
    this.io = null;
    this.connectedUsers = new Map(); // userId -> socketId
    this.userSockets = new Map(); // socketId -> userId
    this.courseRooms = new Map(); // courseId -> Set of userIds
  }

  initialize(server) {
    this.io = new Server(server, {
      cors: {
        origin: process.env.FRONTEND_URL || "http://localhost:3000",
        methods: ["GET", "POST"]
      }
    });

    this.io.use(this.authenticateSocket.bind(this));
    this.io.on('connection', this.handleConnection.bind(this));
    
    console.log('🔥 Real-time Chat Service initialized');
  }

  async authenticateSocket(socket, next) {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication error: No token provided'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId).select('firstName lastName email role');
      
      if (!user) {
        return next(new Error('Authentication error: User not found'));
      }

      socket.userId = user._id.toString();
      socket.user = user;
      next();
    } catch (error) {
      next(new Error('Authentication error: Invalid token'));
    }
  }

  handleConnection(socket) {
    const userId = socket.userId;
    const user = socket.user;

    console.log(`👤 User connected: ${user.firstName} ${user.lastName} (${socket.id})`);

    // Store user connection
    this.connectedUsers.set(userId, socket.id);
    this.userSockets.set(socket.id, userId);

    // Join user to their personal room
    socket.join(`user_${userId}`);

    // Emit user online status
    this.broadcastUserStatus(userId, true);

    // Handle joining course rooms
    socket.on('join_course', (data) => this.handleJoinCourse(socket, data));
    socket.on('leave_course', (data) => this.handleLeaveCourse(socket, data));
    
    // Handle chat messages
    socket.on('send_message', (data) => this.handleSendMessage(socket, data));
    socket.on('typing_start', (data) => this.handleTypingStart(socket, data));
    socket.on('typing_stop', (data) => this.handleTypingStop(socket, data));

    // Handle study sessions
    socket.on('start_study_session', (data) => this.handleStartStudySession(socket, data));
    socket.on('join_study_session', (data) => this.handleJoinStudySession(socket, data));

    // Handle disconnection
    socket.on('disconnect', () => this.handleDisconnection(socket));
  }

  async handleJoinCourse(socket, data) {
    try {
      const { courseId } = data;
      const userId = socket.userId;

      // Verify user is enrolled in course
      const course = await Course.findById(courseId);
      if (!course) {
        socket.emit('error', { message: 'Course not found' });
        return;
      }

      const isEnrolled = course.enrolledStudents.some(
        enrollment => enrollment.user.toString() === userId
      );

      if (!isEnrolled && socket.user.role !== 'admin') {
        socket.emit('error', { message: 'Not enrolled in this course' });
        return;
      }

      // Join course room
      socket.join(`course_${courseId}`);
      
      // Track course room membership
      if (!this.courseRooms.has(courseId)) {
        this.courseRooms.set(courseId, new Set());
      }
      this.courseRooms.get(courseId).add(userId);

      // Notify others in the course
      socket.to(`course_${courseId}`).emit('user_joined_course', {
        user: {
          id: userId,
          name: `${socket.user.firstName} ${socket.user.lastName}`,
          role: socket.user.role
        },
        courseId,
        timestamp: new Date()
      });

      // Send course participants to the user
      const participants = Array.from(this.courseRooms.get(courseId))
        .map(uid => {
          const socketId = this.connectedUsers.get(uid);
          if (socketId) {
            const userSocket = this.io.sockets.sockets.get(socketId);
            return userSocket ? {
              id: uid,
              name: `${userSocket.user.firstName} ${userSocket.user.lastName}`,
              role: userSocket.user.role,
              online: true
            } : null;
          }
          return null;
        })
        .filter(Boolean);

      socket.emit('course_joined', {
        courseId,
        participants,
        message: `Joined course chat for ${course.title}`
      });

    } catch (error) {
      console.error('Join course error:', error);
      socket.emit('error', { message: 'Failed to join course chat' });
    }
  }

  handleLeaveCourse(socket, data) {
    const { courseId } = data;
    const userId = socket.userId;

    socket.leave(`course_${courseId}`);
    
    if (this.courseRooms.has(courseId)) {
      this.courseRooms.get(courseId).delete(userId);
    }

    socket.to(`course_${courseId}`).emit('user_left_course', {
      user: {
        id: userId,
        name: `${socket.user.firstName} ${socket.user.lastName}`
      },
      courseId,
      timestamp: new Date()
    });
  }

  async handleSendMessage(socket, data) {
    try {
      const { courseId, message, type = 'text' } = data;
      const userId = socket.userId;
      const user = socket.user;

      // Validate message
      if (!message || message.trim().length === 0) {
        socket.emit('error', { message: 'Message cannot be empty' });
        return;
      }

      if (message.length > 1000) {
        socket.emit('error', { message: 'Message too long (max 1000 characters)' });
        return;
      }

      const messageData = {
        id: `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        courseId,
        user: {
          id: userId,
          name: `${user.firstName} ${user.lastName}`,
          role: user.role
        },
        message: message.trim(),
        type,
        timestamp: new Date(),
        edited: false
      };

      // Broadcast to course room
      this.io.to(`course_${courseId}`).emit('new_message', messageData);

      // TODO: Save message to database for persistence
      // await this.saveMessage(messageData);

    } catch (error) {
      console.error('Send message error:', error);
      socket.emit('error', { message: 'Failed to send message' });
    }
  }

  handleTypingStart(socket, data) {
    const { courseId } = data;
    const userId = socket.userId;
    const user = socket.user;

    socket.to(`course_${courseId}`).emit('user_typing', {
      user: {
        id: userId,
        name: `${user.firstName} ${user.lastName}`
      },
      courseId,
      typing: true
    });
  }

  handleTypingStop(socket, data) {
    const { courseId } = data;
    const userId = socket.userId;
    const user = socket.user;

    socket.to(`course_${courseId}`).emit('user_typing', {
      user: {
        id: userId,
        name: `${user.firstName} ${user.lastName}`
      },
      courseId,
      typing: false
    });
  }

  handleStartStudySession(socket, data) {
    const { courseId, sessionName, description } = data;
    const userId = socket.userId;
    const user = socket.user;

    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const sessionRoom = `study_${sessionId}`;

    // Create study session
    socket.join(sessionRoom);

    const sessionData = {
      id: sessionId,
      courseId,
      name: sessionName || `${user.firstName}'s Study Session`,
      description: description || 'Join me for a study session!',
      host: {
        id: userId,
        name: `${user.firstName} ${user.lastName}`,
        role: user.role
      },
      participants: [{
        id: userId,
        name: `${user.firstName} ${user.lastName}`,
        role: user.role
      }],
      startTime: new Date(),
      active: true
    };

    // Notify course members about new study session
    socket.to(`course_${courseId}`).emit('study_session_created', sessionData);

    socket.emit('study_session_started', sessionData);
  }

  handleJoinStudySession(socket, data) {
    const { sessionId } = data;
    const userId = socket.userId;
    const user = socket.user;

    const sessionRoom = `study_${sessionId}`;
    socket.join(sessionRoom);

    const participantData = {
      id: userId,
      name: `${user.firstName} ${user.lastName}`,
      role: user.role
    };

    // Notify session participants
    socket.to(sessionRoom).emit('participant_joined', {
      participant: participantData,
      sessionId,
      timestamp: new Date()
    });

    socket.emit('study_session_joined', {
      sessionId,
      message: 'Joined study session successfully'
    });
  }

  handleDisconnection(socket) {
    const userId = socket.userId;
    const user = socket.user;

    console.log(`👤 User disconnected: ${user.firstName} ${user.lastName} (${socket.id})`);

    // Remove from tracking
    this.connectedUsers.delete(userId);
    this.userSockets.delete(socket.id);

    // Remove from course rooms
    this.courseRooms.forEach((users, courseId) => {
      if (users.has(userId)) {
        users.delete(userId);
        socket.to(`course_${courseId}`).emit('user_left_course', {
          user: {
            id: userId,
            name: `${user.firstName} ${user.lastName}`
          },
          courseId,
          timestamp: new Date()
        });
      }
    });

    // Broadcast user offline status
    this.broadcastUserStatus(userId, false);
  }

  broadcastUserStatus(userId, isOnline) {
    this.io.emit('user_status_changed', {
      userId,
      online: isOnline,
      timestamp: new Date()
    });
  }

  // Get online users count
  getOnlineUsersCount() {
    return this.connectedUsers.size;
  }

  // Get users in course
  getCourseParticipants(courseId) {
    const participants = this.courseRooms.get(courseId);
    return participants ? Array.from(participants) : [];
  }

  // Send notification to specific user
  sendNotificationToUser(userId, notification) {
    const socketId = this.connectedUsers.get(userId);
    if (socketId) {
      this.io.to(socketId).emit('notification', notification);
    }
  }

  // Broadcast announcement to course
  broadcastToCourse(courseId, event, data) {
    this.io.to(`course_${courseId}`).emit(event, data);
  }
}

module.exports = new ChatService();