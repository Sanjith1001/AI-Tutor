const nodemailer = require('nodemailer');

// Create transporter
const createTransporter = () => {
  return nodemailer.createTransporter({
    host: process.env.EMAIL_HOST || 'smtp.gmail.com',
    port: process.env.EMAIL_PORT || 587,
    secure: false, // true for 465, false for other ports
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD,
    },
  });
};

// Email templates
const emailTemplates = {
  emailVerification: (data) => ({
    subject: 'Welcome to AI-Tutor - Verify Your Email',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #2563eb; margin: 0;">AI-Tutor</h1>
          <p style="color: #6b7280; margin: 5px 0;">Personalized Learning Platform</p>
        </div>
        
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px; color: white; text-align: center; margin-bottom: 30px;">
          <h2 style="margin: 0 0 15px 0;">Welcome, ${data.firstName}! 🎉</h2>
          <p style="margin: 0; opacity: 0.9;">Thank you for joining AI-Tutor. Let's verify your email to get started.</p>
        </div>
        
        <div style="padding: 20px; background: #f9fafb; border-radius: 8px; margin-bottom: 30px;">
          <h3 style="color: #374151; margin-top: 0;">What's Next?</h3>
          <ul style="color: #6b7280; line-height: 1.6;">
            <li>Verify your email address</li>
            <li>Complete your learning style assessment</li>
            <li>Explore personalized courses</li>
            <li>Start your AI-powered learning journey</li>
          </ul>
        </div>
        
        <div style="text-align: center; margin: 30px 0;">
          <a href="${data.verificationUrl}" 
             style="background: #2563eb; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
            Verify Email Address
          </a>
        </div>
        
        <div style="border-top: 1px solid #e5e7eb; padding-top: 20px; text-align: center; color: #6b7280; font-size: 14px;">
          <p>If you didn't create an account, you can safely ignore this email.</p>
          <p>This verification link will expire in 24 hours.</p>
          <p style="margin-top: 20px;">
            <strong>AI-Tutor Team</strong><br>
            Building the future of personalized education
          </p>
        </div>
      </div>
    `,
    text: `
      Welcome to AI-Tutor, ${data.firstName}!
      
      Thank you for joining our personalized learning platform. To complete your registration, please verify your email address by clicking the link below:
      
      ${data.verificationUrl}
      
      What's next:
      - Verify your email address
      - Complete your learning style assessment
      - Explore personalized courses
      - Start your AI-powered learning journey
      
      If you didn't create an account, you can safely ignore this email.
      This verification link will expire in 24 hours.
      
      Best regards,
      AI-Tutor Team
    `,
  }),

  passwordReset: (data) => ({
    subject: 'AI-Tutor - Password Reset Request',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #2563eb; margin: 0;">AI-Tutor</h1>
          <p style="color: #6b7280; margin: 5px 0;">Personalized Learning Platform</p>
        </div>
        
        <div style="background: #fef3c7; border: 1px solid #f59e0b; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
          <h2 style="color: #92400e; margin: 0 0 10px 0;">🔒 Password Reset Request</h2>
          <p style="color: #92400e; margin: 0;">Hi ${data.firstName}, we received a request to reset your password.</p>
        </div>
        
        <div style="padding: 20px; background: #f9fafb; border-radius: 8px; margin-bottom: 30px;">
          <p style="color: #374151; margin: 0 0 15px 0;">If you requested this password reset, click the button below to create a new password:</p>
          
          <div style="text-align: center; margin: 20px 0;">
            <a href="${data.resetUrl}" 
               style="background: #dc2626; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
              Reset Password
            </a>
          </div>
          
          <p style="color: #6b7280; font-size: 14px; margin: 15px 0 0 0;">
            This link will expire in 10 minutes for security reasons.
          </p>
        </div>
        
        <div style="background: #fef2f2; border: 1px solid #fca5a5; padding: 15px; border-radius: 8px; margin-bottom: 30px;">
          <p style="color: #991b1b; margin: 0; font-size: 14px;">
            <strong>Security Notice:</strong> If you didn't request this password reset, please ignore this email. Your password will remain unchanged.
          </p>
        </div>
        
        <div style="border-top: 1px solid #e5e7eb; padding-top: 20px; text-align: center; color: #6b7280; font-size: 14px;">
          <p>Need help? Contact our support team.</p>
          <p style="margin-top: 20px;">
            <strong>AI-Tutor Team</strong><br>
            Keeping your account secure
          </p>
        </div>
      </div>
    `,
    text: `
      AI-Tutor - Password Reset Request
      
      Hi ${data.firstName},
      
      We received a request to reset your password. If you requested this password reset, click the link below to create a new password:
      
      ${data.resetUrl}
      
      This link will expire in 10 minutes for security reasons.
      
      If you didn't request this password reset, please ignore this email. Your password will remain unchanged.
      
      Need help? Contact our support team.
      
      Best regards,
      AI-Tutor Team
    `,
  }),

  welcomeComplete: (data) => ({
    subject: 'Welcome to AI-Tutor - Your Learning Journey Begins!',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #2563eb; margin: 0;">AI-Tutor</h1>
          <p style="color: #6b7280; margin: 5px 0;">Personalized Learning Platform</p>
        </div>
        
        <div style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 30px; border-radius: 10px; color: white; text-align: center; margin-bottom: 30px;">
          <h2 style="margin: 0 0 15px 0;">🎉 Welcome Aboard, ${data.firstName}!</h2>
          <p style="margin: 0; opacity: 0.9;">Your email is verified and your account is ready. Let's start learning!</p>
        </div>
        
        <div style="padding: 20px; background: #f0f9ff; border-radius: 8px; margin-bottom: 30px;">
          <h3 style="color: #1e40af; margin-top: 0;">🚀 Get Started</h3>
          <ul style="color: #374151; line-height: 1.8;">
            <li><strong>Take the VARK Assessment</strong> - Discover your learning style</li>
            <li><strong>Browse Courses</strong> - Find topics that interest you</li>
            <li><strong>Set Learning Goals</strong> - Define what you want to achieve</li>
            <li><strong>Start Learning</strong> - Begin your personalized journey</li>
          </ul>
        </div>
        
        <div style="text-align: center; margin: 30px 0;">
          <a href="${data.dashboardUrl}" 
             style="background: #2563eb; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
            Go to Dashboard
          </a>
        </div>
        
        <div style="border-top: 1px solid #e5e7eb; padding-top: 20px; text-align: center; color: #6b7280; font-size: 14px;">
          <p>Questions? We're here to help! Contact support anytime.</p>
          <p style="margin-top: 20px;">
            <strong>AI-Tutor Team</strong><br>
            Empowering your learning journey
          </p>
        </div>
      </div>
    `,
    text: `
      Welcome to AI-Tutor, ${data.firstName}!
      
      Your email is verified and your account is ready. Let's start learning!
      
      Get Started:
      - Take the VARK Assessment - Discover your learning style
      - Browse Courses - Find topics that interest you
      - Set Learning Goals - Define what you want to achieve
      - Start Learning - Begin your personalized journey
      
      Go to your dashboard: ${data.dashboardUrl}
      
      Questions? We're here to help! Contact support anytime.
      
      Best regards,
      AI-Tutor Team
    `,
  }),
};

// Send email function
const sendEmail = async ({ to, subject, template, data, html, text }) => {
  try {
    const transporter = createTransporter();

    let emailContent = {};

    if (template && emailTemplates[template]) {
      emailContent = emailTemplates[template](data);
    } else {
      emailContent = {
        subject: subject || 'AI-Tutor Notification',
        html: html || '',
        text: text || '',
      };
    }

    const mailOptions = {
      from: {
        name: 'AI-Tutor',
        address: process.env.EMAIL_USER,
      },
      to,
      subject: emailContent.subject,
      html: emailContent.html,
      text: emailContent.text,
    };

    const result = await transporter.sendMail(mailOptions);
    console.log('Email sent successfully:', result.messageId);
    return result;
  } catch (error) {
    console.error('Email sending failed:', error);
    throw error;
  }
};

// Verify email configuration
const verifyEmailConfig = async () => {
  try {
    const transporter = createTransporter();
    await transporter.verify();
    console.log('✅ Email configuration verified');
    return true;
  } catch (error) {
    console.error('❌ Email configuration failed:', error.message);
    return false;
  }
};

module.exports = {
  sendEmail,
  verifyEmailConfig,
  emailTemplates,
};