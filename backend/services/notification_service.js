const nodemailer = require('nodemailer');
const User = require('../models/User');

class NotificationService {
  constructor() {
    this.emailTransporter = null;
    this.initializeEmailService();
  }

  // Initialize email service
  async initializeEmailService() {
    try {
      if (process.env.EMAIL_HOST && process.env.EMAIL_USER && process.env.EMAIL_PASSWORD) {
        this.emailTransporter = nodemailer.createTransport({
          host: process.env.EMAIL_HOST,
          port: parseInt(process.env.EMAIL_PORT) || 587,
          secure: false,
          auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASSWORD
          }
        });

        // Verify connection
        await this.emailTransporter.verify();
        console.log('✅ Email service initialized successfully');
      } else {
        console.warn('⚠️  Email configuration not found. Email notifications will be disabled.');
      }
    } catch (error) {
      console.warn('⚠️  Email service disabled:', error.message);
      console.log('💡 Email notifications will not be sent (this is optional)');
      this.emailTransporter = null;
    }
  }

  // Send welcome email
  async sendWelcomeEmail(user) {
    if (!this.emailTransporter) {
      console.log('Email service not available - Welcome email not sent');
      return { success: false, message: 'Email service not configured' };
    }

    try {
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: 'Welcome to ByteBrain - Your AI Learning Journey Begins!',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center; color: white;">
              <h1 style="margin: 0; font-size: 28px;">Welcome to ByteBrain! 🧠</h1>
              <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Your AI-powered learning adventure starts now</p>
            </div>
            
            <div style="padding: 40px; background: #f8f9fa;">
              <h2 style="color: #333; margin-bottom: 20px;">Hi ${user.firstName}! 👋</h2>
              
              <p style="color: #666; line-height: 1.6; margin-bottom: 20px;">
                We're thrilled to have you join our community of learners! ByteBrain is designed to provide you with personalized, AI-powered learning experiences that adapt to your unique learning style.
              </p>
              
              <div style="background: white; padding: 30px; border-radius: 10px; margin: 30px 0; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                <h3 style="color: #667eea; margin-bottom: 20px;">🚀 Get Started in 3 Easy Steps:</h3>
                
                <div style="margin-bottom: 20px;">
                  <div style="display: inline-block; background: #667eea; color: white; width: 30px; height: 30px; border-radius: 50%; text-align: center; line-height: 30px; margin-right: 15px; font-weight: bold;">1</div>
                  <strong>Take the VARK Learning Style Assessment</strong>
                  <p style="margin: 5px 0 0 45px; color: #666;">Discover your unique learning style to get personalized course recommendations.</p>
                </div>
                
                <div style="margin-bottom: 20px;">
                  <div style="display: inline-block; background: #667eea; color: white; width: 30px; height: 30px; border-radius: 50%; text-align: center; line-height: 30px; margin-right: 15px; font-weight: bold;">2</div>
                  <strong>Browse Our Course Library</strong>
                  <p style="margin: 5px 0 0 45px; color: #666;">Explore courses in programming, data science, business, and more.</p>
                </div>
                
                <div style="margin-bottom: 20px;">
                  <div style="display: inline-block; background: #667eea; color: white; width: 30px; height: 30px; border-radius: 50%; text-align: center; line-height: 30px; margin-right: 15px; font-weight: bold;">3</div>
                  <strong>Start Learning with AI</strong>
                  <p style="margin: 5px 0 0 45px; color: #666;">Generate personalized content and track your progress as you learn.</p>
                </div>
              </div>
              
              <div style="text-align: center; margin: 30px 0;">
                <a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}" style="background: #667eea; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;">Start Learning Now</a>
              </div>
              
              <div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 30px 0;">
                <h4 style="color: #1976d2; margin-bottom: 10px;">💡 Pro Tip:</h4>
                <p style="color: #666; margin: 0;">Complete the VARK assessment first to unlock personalized course recommendations tailored specifically to your learning style!</p>
              </div>
              
              <p style="color: #666; line-height: 1.6;">
                If you have any questions or need help getting started, don't hesitate to reach out to our support team. We're here to help you succeed!
              </p>
              
              <p style="color: #666; margin-top: 30px;">
                Happy learning!<br>
                <strong>The ByteBrain Team</strong>
              </p>
            </div>
            
            <div style="background: #333; color: white; padding: 20px; text-align: center; font-size: 14px;">
              <p style="margin: 0;">© 2024 ByteBrain. All rights reserved.</p>
              <p style="margin: 10px 0 0 0; opacity: 0.7;">You received this email because you signed up for ByteBrain.</p>
            </div>
          </div>
        `
      };

      await this.emailTransporter.sendMail(mailOptions);
      console.log(`Welcome email sent to ${user.email}`);
      
      return { success: true, message: 'Welcome email sent successfully' };
    } catch (error) {
      console.error('Send welcome email error:', error);
      return { success: false, message: 'Failed to send welcome email' };
    }
  }

  // Send course enrollment confirmation
  async sendEnrollmentConfirmation(user, course) {
    if (!this.emailTransporter) {
      console.log('Email service not available - Enrollment confirmation not sent');
      return { success: false, message: 'Email service not configured' };
    }

    try {
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: `Enrollment Confirmed: ${course.title}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); padding: 40px; text-align: center; color: white;">
              <h1 style="margin: 0; font-size: 28px;">Enrollment Confirmed! 🎉</h1>
              <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">You're now enrolled in ${course.title}</p>
            </div>
            
            <div style="padding: 40px; background: #f8f9fa;">
              <h2 style="color: #333; margin-bottom: 20px;">Congratulations, ${user.firstName}!</h2>
              
              <p style="color: #666; line-height: 1.6; margin-bottom: 30px;">
                You've successfully enrolled in <strong>${course.title}</strong>. Get ready to embark on an exciting learning journey!
              </p>
              
              <div style="background: white; padding: 30px; border-radius: 10px; margin: 30px 0; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                <h3 style="color: #4CAF50; margin-bottom: 20px;">📚 Course Details:</h3>
                <ul style="color: #666; line-height: 1.8; padding-left: 20px;">
                  <li><strong>Course:</strong> ${course.title}</li>
                  <li><strong>Category:</strong> ${course.category}</li>
                  <li><strong>Difficulty:</strong> ${course.difficulty}</li>
                  <li><strong>Modules:</strong> ${course.totalModules}</li>
                  <li><strong>Duration:</strong> ${course.formattedDuration}</li>
                </ul>
              </div>
              
              <div style="text-align: center; margin: 30px 0;">
                <a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}/courses/${course._id}" style="background: #4CAF50; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;">Start Learning</a>
              </div>
              
              <div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 30px 0; border-left: 4px solid #ffc107;">
                <h4 style="color: #856404; margin-bottom: 10px;">📈 Track Your Progress:</h4>
                <p style="color: #856404; margin: 0;">Don't forget to mark modules as complete as you progress through the course. This helps us provide better recommendations and track your learning journey!</p>
              </div>
              
              <p style="color: #666; line-height: 1.6;">
                Need help or have questions? Our support team is always ready to assist you on your learning journey.
              </p>
              
              <p style="color: #666; margin-top: 30px;">
                Happy learning!<br>
                <strong>The ByteBrain Team</strong>
              </p>
            </div>
            
            <div style="background: #333; color: white; padding: 20px; text-align: center; font-size: 14px;">
              <p style="margin: 0;">© 2024 ByteBrain. All rights reserved.</p>
            </div>
          </div>
        `
      };

      await this.emailTransporter.sendMail(mailOptions);
      console.log(`Enrollment confirmation sent to ${user.email} for course: ${course.title}`);
      
      return { success: true, message: 'Enrollment confirmation sent successfully' };
    } catch (error) {
      console.error('Send enrollment confirmation error:', error);
      return { success: false, message: 'Failed to send enrollment confirmation' };
    }
  }

  // Send course completion certificate
  async sendCertificateEmail(user, course) {
    if (!this.emailTransporter) {
      console.log('Email service not available - Certificate email not sent');
      return { success: false, message: 'Email service not configured' };
    }

    try {
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: `🏆 Certificate Earned: ${course.title}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%); padding: 40px; text-align: center; color: #333;">
              <h1 style="margin: 0; font-size: 28px;">🏆 Congratulations!</h1>
              <p style="margin: 10px 0 0 0; font-size: 16px;">You've earned a certificate!</p>
            </div>
            
            <div style="padding: 40px; background: #f8f9fa;">
              <h2 style="color: #333; margin-bottom: 20px;">Amazing Achievement, ${user.firstName}! 🎉</h2>
              
              <p style="color: #666; line-height: 1.6; margin-bottom: 30px;">
                You've successfully completed <strong>${course.title}</strong> and earned your certificate! This is a significant milestone in your learning journey.
              </p>
              
              <div style="background: white; padding: 30px; border-radius: 10px; margin: 30px 0; box-shadow: 0 2px 10px rgba(0,0,0,0.1); text-align: center;">
                <div style="background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%); padding: 30px; border-radius: 10px; margin-bottom: 20px;">
                  <h3 style="color: #333; margin: 0; font-size: 24px;">🏆 Certificate of Completion</h3>
                  <p style="color: #333; margin: 10px 0; font-size: 18px; font-weight: bold;">${course.title}</p>
                  <p style="color: #333; margin: 0;">Awarded to ${user.firstName} ${user.lastName}</p>
                </div>
                
                <p style="color: #666; margin-bottom: 20px;">
                  This certificate validates your successful completion of all course modules and demonstrates your commitment to continuous learning.
                </p>
                
                <a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}/certificates/${course._id}" style="background: #FFD700; color: #333; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;">Download Certificate</a>
              </div>
              
              <div style="background: #e8f5e8; padding: 20px; border-radius: 10px; margin: 30px 0;">
                <h4 style="color: #2e7d32; margin-bottom: 10px;">🚀 What's Next?</h4>
                <ul style="color: #2e7d32; margin: 0; padding-left: 20px;">
                  <li>Share your achievement on social media</li>
                  <li>Add this certificate to your LinkedIn profile</li>
                  <li>Explore advanced courses in ${course.category}</li>
                  <li>Apply your new skills to real-world projects</li>
                </ul>
              </div>
              
              <p style="color: #666; line-height: 1.6;">
                Keep up the excellent work! Your dedication to learning is inspiring, and we can't wait to see what you'll achieve next.
              </p>
              
              <p style="color: #666; margin-top: 30px;">
                Congratulations once again!<br>
                <strong>The ByteBrain Team</strong>
              </p>
            </div>
            
            <div style="background: #333; color: white; padding: 20px; text-align: center; font-size: 14px;">
              <p style="margin: 0;">© 2024 ByteBrain. All rights reserved.</p>
            </div>
          </div>
        `
      };

      await this.emailTransporter.sendMail(mailOptions);
      console.log(`Certificate email sent to ${user.email} for course: ${course.title}`);
      
      return { success: true, message: 'Certificate email sent successfully' };
    } catch (error) {
      console.error('Send certificate email error:', error);
      return { success: false, message: 'Failed to send certificate email' };
    }
  }

  // Send password reset email
  async sendPasswordResetEmail(user, resetToken) {
    if (!this.emailTransporter) {
      console.log('Email service not available - Password reset email not sent');
      return { success: false, message: 'Email service not configured' };
    }

    try {
      const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;
      
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: 'Reset Your ByteBrain Password',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%); padding: 40px; text-align: center; color: white;">
              <h1 style="margin: 0; font-size: 28px;">🔐 Password Reset</h1>
              <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Reset your ByteBrain password</p>
            </div>
            
            <div style="padding: 40px; background: #f8f9fa;">
              <h2 style="color: #333; margin-bottom: 20px;">Hi ${user.firstName},</h2>
              
              <p style="color: #666; line-height: 1.6; margin-bottom: 30px;">
                We received a request to reset your ByteBrain password. If you didn't make this request, you can safely ignore this email.
              </p>
              
              <div style="background: white; padding: 30px; border-radius: 10px; margin: 30px 0; box-shadow: 0 2px 10px rgba(0,0,0,0.1); text-align: center;">
                <p style="color: #666; margin-bottom: 20px;">Click the button below to reset your password:</p>
                <a href="${resetUrl}" style="background: #f44336; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;">Reset Password</a>
              </div>
              
              <div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 30px 0; border-left: 4px solid #ffc107;">
                <h4 style="color: #856404; margin-bottom: 10px;">⚠️ Important:</h4>
                <ul style="color: #856404; margin: 0; padding-left: 20px;">
                  <li>This link will expire in 1 hour for security reasons</li>
                  <li>If you didn't request this reset, please ignore this email</li>
                  <li>Never share this link with anyone</li>
                </ul>
              </div>
              
              <p style="color: #666; line-height: 1.6; font-size: 14px;">
                If the button doesn't work, you can copy and paste this link into your browser:<br>
                <a href="${resetUrl}" style="color: #f44336; word-break: break-all;">${resetUrl}</a>
              </p>
              
              <p style="color: #666; margin-top: 30px;">
                Best regards,<br>
                <strong>The ByteBrain Team</strong>
              </p>
            </div>
            
            <div style="background: #333; color: white; padding: 20px; text-align: center; font-size: 14px;">
              <p style="margin: 0;">© 2024 ByteBrain. All rights reserved.</p>
            </div>
          </div>
        `
      };

      await this.emailTransporter.sendMail(mailOptions);
      console.log(`Password reset email sent to ${user.email}`);
      
      return { success: true, message: 'Password reset email sent successfully' };
    } catch (error) {
      console.error('Send password reset email error:', error);
      return { success: false, message: 'Failed to send password reset email' };
    }
  }

  // Send bulk notification to users
  async sendBulkNotification(userIds, subject, message, type = 'general') {
    if (!this.emailTransporter) {
      console.log('Email service not available - Bulk notification not sent');
      return { success: false, message: 'Email service not configured' };
    }

    try {
      const users = await User.find({ _id: { $in: userIds } }).select('email firstName lastName');
      const results = [];

      for (const user of users) {
        try {
          const mailOptions = {
            from: process.env.EMAIL_USER,
            to: user.email,
            subject: subject,
            html: `
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center; color: white;">
                  <h1 style="margin: 0; font-size: 28px;">ByteBrain Notification</h1>
                </div>
                
                <div style="padding: 40px; background: #f8f9fa;">
                  <h2 style="color: #333; margin-bottom: 20px;">Hi ${user.firstName},</h2>
                  
                  <div style="background: white; padding: 30px; border-radius: 10px; margin: 30px 0; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    ${message}
                  </div>
                  
                  <p style="color: #666; margin-top: 30px;">
                    Best regards,<br>
                    <strong>The ByteBrain Team</strong>
                  </p>
                </div>
                
                <div style="background: #333; color: white; padding: 20px; text-align: center; font-size: 14px;">
                  <p style="margin: 0;">© 2024 ByteBrain. All rights reserved.</p>
                </div>
              </div>
            `
          };

          await this.emailTransporter.sendMail(mailOptions);
          results.push({ email: user.email, status: 'sent' });
        } catch (error) {
          console.error(`Failed to send email to ${user.email}:`, error);
          results.push({ email: user.email, status: 'failed', error: error.message });
        }
      }

      const successCount = results.filter(r => r.status === 'sent').length;
      const failureCount = results.filter(r => r.status === 'failed').length;

      return {
        success: true,
        message: `Bulk notification completed: ${successCount} sent, ${failureCount} failed`,
        results
      };
    } catch (error) {
      console.error('Send bulk notification error:', error);
      return { success: false, message: 'Failed to send bulk notification' };
    }
  }

  // Get notification preferences for user
  async getNotificationPreferences(userId) {
    try {
      const user = await User.findById(userId).select('notificationPreferences');
      
      return {
        success: true,
        data: user?.notificationPreferences || {
          email: true,
          courseUpdates: true,
          achievements: true,
          reminders: true,
          marketing: false
        }
      };
    } catch (error) {
      console.error('Get notification preferences error:', error);
      return { success: false, message: 'Failed to get notification preferences' };
    }
  }

  // Update notification preferences
  async updateNotificationPreferences(userId, preferences) {
    try {
      const user = await User.findByIdAndUpdate(
        userId,
        { notificationPreferences: preferences },
        { new: true }
      ).select('notificationPreferences');

      return {
        success: true,
        message: 'Notification preferences updated successfully',
        data: user.notificationPreferences
      };
    } catch (error) {
      console.error('Update notification preferences error:', error);
      return { success: false, message: 'Failed to update notification preferences' };
    }
  }
}

module.exports = new NotificationService();