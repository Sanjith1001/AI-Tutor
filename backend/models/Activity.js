const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  type: {
    type: String,
    required: true,
    enum: ['quiz', 'course', 'module', 'assessment', 'login', 'vark_quiz', 'skill_assessment'],
  },
  title: {
    type: String,
    required: true,
    maxlength: 200,
  },
  description: {
    type: String,
    required: true,
    maxlength: 500,
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {},
  },
  score: {
    type: Number,
    min: 0,
    max: 100,
  },
  completed: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Indexes for better performance
activitySchema.index({ userId: 1, createdAt: -1 });
activitySchema.index({ type: 1 });
activitySchema.index({ createdAt: -1 });

// Virtual for formatted timestamp
activitySchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diff = now - this.createdAt;
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days = Math.floor(diff / 86400000);

  if (minutes < 1) return 'Just now';
  if (minutes < 60) return `${minutes} minutes ago`;
  if (hours < 24) return `${hours} hours ago`;
  if (days < 7) return `${days} days ago`;
  return `${Math.floor(days / 7)} weeks ago`;
});

// Static method to get user activities
activitySchema.statics.getUserActivities = function(userId, limit = 10) {
  return this.find({ userId })
    .sort({ createdAt: -1 })
    .limit(limit)
    .populate('userId', 'firstName lastName');
};

// Static method to get user stats
activitySchema.statics.getUserStats = async function(userId) {
  const stats = await this.aggregate([
    { $match: { userId: new mongoose.Types.ObjectId(userId) } },
    {
      $group: {
        _id: null,
        totalActivities: { $sum: 1 },
        coursesCompleted: { 
          $sum: { 
            $cond: [
              { $and: [{ $eq: ['$type', 'course'] }, { $eq: ['$completed', true] }] }, 
              1, 
              0
            ] 
          } 
        },
        quizzesTaken: { 
          $sum: { $cond: [{ $eq: ['$type', 'quiz'] }, 1, 0] } 
        },
        assessmentsTaken: { 
          $sum: { $cond: [{ $eq: ['$type', 'assessment'] }, 1, 0] } 
        },
        averageScore: { $avg: '$score' },
        lastActivity: { $max: '$createdAt' },
      }
    }
  ]);

  return stats[0] || {
    totalActivities: 0,
    coursesCompleted: 0,
    quizzesTaken: 0,
    assessmentsTaken: 0,
    averageScore: 0,
    lastActivity: null,
  };
};

module.exports = mongoose.model('Activity', activitySchema);