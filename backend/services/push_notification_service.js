const admin = require('firebase-admin');
const User = require('../models/User');

class PushNotificationService {
  constructor() {
    this.initialized = false;
    this.initializeFirebase();
  }

  initializeFirebase() {
    try {
      // Check if Firebase credentials are available
      const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
      const projectId = process.env.FIREBASE_PROJECT_ID;

      if (!serviceAccountPath || !projectId) {
        console.warn('⚠️  Firebase credentials not configured. Push notifications disabled.');
        console.log('💡 To enable push notifications:');
        console.log('   1. Create a Firebase project');
        console.log('   2. Generate service account key');
        console.log('   3. Set FIREBASE_SERVICE_ACCOUNT_PATH in .env');
        console.log('   4. Set FIREBASE_PROJECT_ID in .env');
        console.log(`   Current values: PROJECT_ID=${projectId}, SERVICE_ACCOUNT_PATH=${serviceAccountPath}`);
        return;
      }

      // Initialize Firebase Admin SDK
      if (serviceAccountPath) {
        const path = require('path');
        const fs = require('fs');
        
        // Resolve the path relative to the project root
        const resolvedPath = path.resolve(process.cwd(), serviceAccountPath);
        
        // Check if file exists
        if (!fs.existsSync(resolvedPath)) {
          throw new Error(`Firebase service account file not found at: ${resolvedPath}`);
        }
        
        const serviceAccount = require(resolvedPath);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
          projectId: projectId
        });
      } else if (projectId) {
        // Use default credentials (for cloud deployment)
        admin.initializeApp({
          projectId: projectId
        });
      }

      this.initialized = true;
      console.log('🔔 Firebase Push Notification Service initialized');
    } catch (error) {
      console.error('❌ Firebase initialization failed:', error.message);
      console.log('💡 Push notifications will be disabled');
    }
  }

  // Send notification to single user
  async sendToUser(userId, notification, data = {}) {
    if (!this.initialized) {
      console.log('📱 Push notification skipped (Firebase not configured)');
      return { success: false, message: 'Firebase not configured' };
    }

    try {
      const user = await User.findById(userId);
      if (!user || !user.fcmToken) {
        return { success: false, message: 'User FCM token not found' };
      }

      const message = {
        token: user.fcmToken,
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl
        },
        data: {
          ...data,
          userId: userId.toString(),
          timestamp: new Date().toISOString()
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#2196F3',
            sound: 'default',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      };

      const response = await admin.messaging().send(message);
      console.log(`🔔 Push notification sent to ${user.email}:`, response);

      return { success: true, messageId: response };
    } catch (error) {
      console.error('Push notification error:', error);
      
      // Handle invalid tokens
      if (error.code === 'messaging/registration-token-not-registered') {
        await User.findByIdAndUpdate(userId, { $unset: { fcmToken: 1 } });
        console.log(`🧹 Removed invalid FCM token for user ${userId}`);
      }

      return { success: false, error: error.message };
    }
  }

  // Send notification to multiple users
  async sendToMultipleUsers(userIds, notification, data = {}) {
    if (!this.initialized) {
      console.log('📱 Bulk push notifications skipped (Firebase not configured)');
      return { success: false, message: 'Firebase not configured' };
    }

    try {
      const users = await User.find({
        _id: { $in: userIds },
        fcmToken: { $exists: true, $ne: null }
      }).select('fcmToken email');

      if (users.length === 0) {
        return { success: false, message: 'No users with FCM tokens found' };
      }

      const tokens = users.map(user => user.fcmToken);
      
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl
        },
        data: {
          ...data,
          timestamp: new Date().toISOString()
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#2196F3',
            sound: 'default'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        },
        tokens: tokens
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      
      console.log(`🔔 Bulk push notifications sent: ${response.successCount}/${tokens.length}`);

      // Handle failed tokens
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(tokens[idx]);
            console.error(`Failed to send to token ${idx}:`, resp.error);
          }
        });

        // Remove invalid tokens
        await User.updateMany(
          { fcmToken: { $in: failedTokens } },
          { $unset: { fcmToken: 1 } }
        );
      }

      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
        responses: response.responses
      };
    } catch (error) {
      console.error('Bulk push notification error:', error);
      return { success: false, error: error.message };
    }
  }

  // Send to topic (all subscribers)
  async sendToTopic(topic, notification, data = {}) {
    if (!this.initialized) {
      console.log('📱 Topic push notification skipped (Firebase not configured)');
      return { success: false, message: 'Firebase not configured' };
    }

    try {
      const message = {
        topic: topic,
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl
        },
        data: {
          ...data,
          topic: topic,
          timestamp: new Date().toISOString()
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#2196F3',
            sound: 'default'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      };

      const response = await admin.messaging().send(message);
      console.log(`🔔 Topic notification sent to '${topic}':`, response);

      return { success: true, messageId: response };
    } catch (error) {
      console.error('Topic push notification error:', error);
      return { success: false, error: error.message };
    }
  }

  // Subscribe user to topic
  async subscribeToTopic(fcmToken, topic) {
    if (!this.initialized) {
      return { success: false, message: 'Firebase not configured' };
    }

    try {
      await admin.messaging().subscribeToTopic([fcmToken], topic);
      console.log(`📱 Subscribed token to topic '${topic}'`);
      return { success: true };
    } catch (error) {
      console.error('Topic subscription error:', error);
      return { success: false, error: error.message };
    }
  }

  // Unsubscribe user from topic
  async unsubscribeFromTopic(fcmToken, topic) {
    if (!this.initialized) {
      return { success: false, message: 'Firebase not configured' };
    }

    try {
      await admin.messaging().unsubscribeFromTopic([fcmToken], topic);
      console.log(`📱 Unsubscribed token from topic '${topic}'`);
      return { success: true };
    } catch (error) {
      console.error('Topic unsubscription error:', error);
      return { success: false, error: error.message };
    }
  }

  // Predefined notification types
  async sendWelcomeNotification(userId) {
    return this.sendToUser(userId, {
      title: '🎉 Welcome to ByteBrain!',
      body: 'Start your AI-powered learning journey today!'
    }, {
      type: 'welcome',
      action: 'open_app'
    });
  }

  async sendCourseEnrollmentNotification(userId, courseName) {
    return this.sendToUser(userId, {
      title: '📚 Course Enrollment Confirmed',
      body: `You're now enrolled in ${courseName}. Start learning!`
    }, {
      type: 'enrollment',
      action: 'open_course'
    });
  }

  async sendModuleCompletionNotification(userId, moduleName, courseName) {
    return this.sendToUser(userId, {
      title: '✅ Module Completed!',
      body: `Great job completing "${moduleName}" in ${courseName}`
    }, {
      type: 'completion',
      action: 'continue_course'
    });
  }

  async sendCertificateNotification(userId, courseName) {
    return this.sendToUser(userId, {
      title: '🏆 Certificate Earned!',
      body: `Congratulations! You've earned a certificate for ${courseName}`
    }, {
      type: 'certificate',
      action: 'view_certificate'
    });
  }

  async sendStudyReminderNotification(userId, courseName) {
    return this.sendToUser(userId, {
      title: '📖 Study Reminder',
      body: `Don't forget to continue your progress in ${courseName}`
    }, {
      type: 'reminder',
      action: 'continue_learning'
    });
  }

  async sendChatMessageNotification(userId, senderName, courseName) {
    return this.sendToUser(userId, {
      title: `💬 New message in ${courseName}`,
      body: `${senderName} sent a message in the course chat`
    }, {
      type: 'chat_message',
      action: 'open_chat'
    });
  }

  async sendStudySessionNotification(userId, hostName, sessionName) {
    return this.sendToUser(userId, {
      title: '📚 Study Session Started',
      body: `${hostName} started "${sessionName}". Join now!`
    }, {
      type: 'study_session',
      action: 'join_session'
    });
  }

  // Broadcast notifications
  async broadcastAnnouncement(title, body, data = {}) {
    return this.sendToTopic('announcements', { title, body }, {
      ...data,
      type: 'announcement'
    });
  }

  async broadcastMaintenanceNotification(message) {
    return this.sendToTopic('maintenance', {
      title: '🔧 Maintenance Notice',
      body: message
    }, {
      type: 'maintenance'
    });
  }

  // Get service status
  getStatus() {
    return {
      initialized: this.initialized,
      available: this.initialized,
      service: 'Firebase Cloud Messaging'
    };
  }
}

module.exports = new PushNotificationService();