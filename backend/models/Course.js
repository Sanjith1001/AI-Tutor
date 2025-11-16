const mongoose = require('mongoose');

const courseSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  instructor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  category: {
    type: String,
    required: true,
    enum: ['Programming', 'Data Science', 'Web Development', 'Mobile Development', 'AI/ML', 'Other']
  },
  level: {
    type: String,
    required: true,
    enum: ['Beginner', 'Intermediate', 'Advanced']
  },
  duration: {
    type: Number, // in hours
    required: true
  },
  price: {
    type: Number,
    default: 0
  },
  thumbnail: {
    type: String,
    default: ''
  },
  modules: [{
    title: {
      type: String,
      required: true
    },
    description: String,
    content: String,
    videoUrl: String,
    resources: [{
      title: String,
      url: String,
      type: {
        type: String,
        enum: ['pdf', 'video', 'link', 'document']
      }
    }],
    quiz: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Quiz'
    },
    order: {
      type: Number,
      default: 0
    }
  }],
  enrolledStudents: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    enrolledAt: {
      type: Date,
      default: Date.now
    },
    progress: {
      type: Number,
      default: 0,
      min: 0,
      max: 100
    },
    completedModules: [{
      type: mongoose.Schema.Types.ObjectId
    }],
    lastAccessed: {
      type: Date,
      default: Date.now
    }
  }],
  ratings: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    review: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  averageRating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  totalRatings: {
    type: Number,
    default: 0
  },
  isPublished: {
    type: Boolean,
    default: false
  },
  tags: [{
    type: String,
    trim: true
  }],
  prerequisites: [{
    type: String,
    trim: true
  }],
  learningOutcomes: [{
    type: String,
    trim: true
  }]
}, {
  timestamps: true
});

// Index for search functionality
courseSchema.index({ title: 'text', description: 'text', tags: 'text' });
courseSchema.index({ category: 1, level: 1 });
courseSchema.index({ averageRating: -1 });
courseSchema.index({ createdAt: -1 });

// Virtual for enrolled students count
courseSchema.virtual('enrolledCount').get(function() {
  return this.enrolledStudents.length;
});

// Method to calculate average rating
courseSchema.methods.calculateAverageRating = function() {
  if (this.ratings.length === 0) {
    this.averageRating = 0;
    this.totalRatings = 0;
    return;
  }

  const sum = this.ratings.reduce((acc, rating) => acc + rating.rating, 0);
  this.averageRating = Math.round((sum / this.ratings.length) * 10) / 10;
  this.totalRatings = this.ratings.length;
};

// Method to check if user is enrolled
courseSchema.methods.isUserEnrolled = function(userId) {
  return this.enrolledStudents.some(enrollment => 
    enrollment.user.toString() === userId.toString()
  );
};

// Method to get user's progress
courseSchema.methods.getUserProgress = function(userId) {
  const enrollment = this.enrolledStudents.find(enrollment => 
    enrollment.user.toString() === userId.toString()
  );
  return enrollment ? enrollment.progress : 0;
};

// Pre-save middleware to update average rating
courseSchema.pre('save', function(next) {
  if (this.isModified('ratings')) {
    this.calculateAverageRating();
  }
  next();
});

module.exports = mongoose.model('Course', courseSchema);