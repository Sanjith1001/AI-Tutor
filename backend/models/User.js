const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please provide a valid email'],
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters'],
    select: false, // Don't include password in queries by default
  },
  firstName: {
    type: String,
    required: [true, 'First name is required'],
    trim: true,
    maxlength: [50, 'First name cannot exceed 50 characters'],
  },
  lastName: {
    type: String,
    required: [true, 'Last name is required'],
    trim: true,
    maxlength: [50, 'Last name cannot exceed 50 characters'],
  },
  role: {
    type: String,
    enum: ['student', 'teacher', 'admin'],
    default: 'student',
  },
  isEmailVerified: {
    type: Boolean,
    default: false,
  },
  emailVerificationToken: {
    type: String,
    select: false,
  },
  passwordResetToken: {
    type: String,
    select: false,
  },
  passwordResetExpires: {
    type: Date,
    select: false,
  },
  lastLogin: {
    type: Date,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  // VARK Learning Style Preferences
  learningStyle: {
    visual: {
      type: Number,
      min: [0, 'Visual percentage must be between 0 and 100'],
      max: [100, 'Visual percentage must be between 0 and 100'],
      default: 25,
    },
    auditory: {
      type: Number,
      min: [0, 'Auditory percentage must be between 0 and 100'],
      max: [100, 'Auditory percentage must be between 0 and 100'],
      default: 25,
    },
    reading: {
      type: Number,
      min: [0, 'Reading percentage must be between 0 and 100'],
      max: [100, 'Reading percentage must be between 0 and 100'],
      default: 25,
    },
    kinesthetic: {
      type: Number,
      min: [0, 'Kinesthetic percentage must be between 0 and 100'],
      max: [100, 'Kinesthetic percentage must be between 0 and 100'],
      default: 25,
    },
  },
  // User Preferences
  preferences: {
    theme: {
      type: String,
      enum: ['light', 'dark', 'auto'],
      default: 'light',
    },
    language: {
      type: String,
      default: 'en',
    },
    notifications: {
      email: {
        type: Boolean,
        default: true,
      },
      push: {
        type: Boolean,
        default: true,
      },
      reminders: {
        type: Boolean,
        default: true,
      },
    },
    difficulty: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      default: 'intermediate',
    },
  },
  // Profile Information
  avatar: {
    type: String,
    default: null,
  },
  bio: {
    type: String,
    maxlength: [500, 'Bio cannot exceed 500 characters'],
  },
  dateOfBirth: {
    type: Date,
  },
  country: {
    type: String,
    maxlength: [100, 'Country cannot exceed 100 characters'],
  },
  timezone: {
    type: String,
    default: 'UTC',
  },
  // Analytics and Tracking
  loginCount: {
    type: Number,
    default: 0,
  },
  coursesEnrolled: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Course',
  }],
  coursesCompleted: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Course',
  }],
  totalLearningTime: {
    type: Number, // in minutes
    default: 0,
  },
}, {
  timestamps: true,
  toJSON: { 
    virtuals: true,
    transform: function(doc, ret) {
      delete ret.password;
      delete ret.emailVerificationToken;
      delete ret.passwordResetToken;
      delete ret.passwordResetExpires;
      delete ret.__v;
      return ret;
    }
  },
  toObject: { virtuals: true },
});

// Indexes for better performance
userSchema.index({ email: 1 });
userSchema.index({ role: 1 });
userSchema.index({ isActive: 1 });
userSchema.index({ emailVerificationToken: 1 });
userSchema.index({ passwordResetToken: 1 });
userSchema.index({ createdAt: -1 });

// Virtual for full name
userSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

// Validate learning style percentages sum to 100
userSchema.pre('save', function(next) {
  if (this.isModified('learningStyle')) {
    const total = this.learningStyle.visual + this.learningStyle.auditory + 
                  this.learningStyle.reading + this.learningStyle.kinesthetic;
    
    if (Math.abs(total - 100) > 0.01) {
      return next(new Error('Learning style percentages must sum to 100'));
    }
  }
  next();
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  // Only hash the password if it has been modified (or is new)
  if (!this.isModified('password')) return next();

  try {
    // Hash password with cost of 12
    const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS) || 12;
    this.password = await bcrypt.hash(this.password, saltRounds);
    next();
  } catch (error) {
    next(error);
  }
});

// Update login count and last login
userSchema.pre('save', function(next) {
  if (this.isModified('lastLogin')) {
    this.loginCount += 1;
  }
  next();
});

// Instance method to check password
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Instance method to get public profile
userSchema.methods.getPublicProfile = function() {
  return {
    id: this._id,
    firstName: this.firstName,
    lastName: this.lastName,
    fullName: this.fullName,
    avatar: this.avatar,
    bio: this.bio,
    country: this.country,
    role: this.role,
    coursesEnrolled: this.coursesEnrolled.length,
    coursesCompleted: this.coursesCompleted.length,
    totalLearningTime: this.totalLearningTime,
    createdAt: this.createdAt,
  };
};

// Static method to find by email
userSchema.statics.findByEmail = function(email) {
  return this.findOne({ email: email.toLowerCase() });
};

// Static method to find active users
userSchema.statics.findActive = function() {
  return this.find({ isActive: true });
};

// Static method to get user stats
userSchema.statics.getUserStats = async function() {
  const stats = await this.aggregate([
    {
      $group: {
        _id: null,
        totalUsers: { $sum: 1 },
        activeUsers: { $sum: { $cond: ['$isActive', 1, 0] } },
        verifiedUsers: { $sum: { $cond: ['$isEmailVerified', 1, 0] } },
        studentCount: { $sum: { $cond: [{ $eq: ['$role', 'student'] }, 1, 0] } },
        teacherCount: { $sum: { $cond: [{ $eq: ['$role', 'teacher'] }, 1, 0] } },
        adminCount: { $sum: { $cond: [{ $eq: ['$role', 'admin'] }, 1, 0] } },
      }
    }
  ]);
  
  return stats[0] || {
    totalUsers: 0,
    activeUsers: 0,
    verifiedUsers: 0,
    studentCount: 0,
    teacherCount: 0,
    adminCount: 0,
  };
};

module.exports = mongoose.model('User', userSchema);