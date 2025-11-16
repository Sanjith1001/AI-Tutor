const mongoose = require('mongoose');

const quizQuestionSchema = new mongoose.Schema({
  question: {
    type: String,
    required: true,
    maxlength: 500,
  },
  options: [{
    type: String,
    required: true,
    maxlength: 200,
  }],
  correctAnswer: {
    type: Number,
    required: true,
    min: 0,
  },
  difficulty: {
    type: String,
    required: true,
    enum: ['Easy', 'Medium', 'Hard'],
  },
  explanation: {
    type: String,
    maxlength: 300,
  },
});

const quizSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  topic: {
    type: String,
    required: true,
    maxlength: 100,
  },
  title: {
    type: String,
    required: true,
    maxlength: 200,
  },
  questions: [quizQuestionSchema],
  totalQuestions: {
    type: Number,
    required: true,
    min: 1,
    max: 50,
  },
  isCompleted: {
    type: Boolean,
    default: false,
  },
  score: {
    type: Number,
    min: 0,
    default: 0,
  },
  percentage: {
    type: Number,
    min: 0,
    max: 100,
    default: 0,
  },
  skillLevel: {
    type: String,
    enum: ['Beginner', 'Intermediate', 'Advanced'],
  },
  timeSpent: {
    type: Number, // in seconds
    default: 0,
  },
  completedAt: {
    type: Date,
  },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Indexes for better performance
quizSchema.index({ userId: 1, createdAt: -1 });
quizSchema.index({ topic: 1 });
quizSchema.index({ isCompleted: 1 });
quizSchema.index({ skillLevel: 1 });

// Virtual for formatted duration
quizSchema.virtual('formattedDuration').get(function() {
  if (!this.timeSpent) return '0 min';
  const minutes = Math.floor(this.timeSpent / 60);
  const seconds = this.timeSpent % 60;
  if (minutes > 0) {
    return `${minutes} min ${seconds > 0 ? seconds + ' sec' : ''}`.trim();
  }
  return `${seconds} sec`;
});

// Static method to get user quizzes
quizSchema.statics.getUserQuizzes = function(userId, limit = 10) {
  return this.find({ userId })
    .sort({ createdAt: -1 })
    .limit(limit)
    .populate('userId', 'firstName lastName');
};

// Static method to get quiz statistics
quizSchema.statics.getQuizStats = async function(userId) {
  const stats = await this.aggregate([
    { $match: { userId: new mongoose.Types.ObjectId(userId), isCompleted: true } },
    {
      $group: {
        _id: null,
        totalQuizzes: { $sum: 1 },
        averageScore: { $avg: '$percentage' },
        totalTimeSpent: { $sum: '$timeSpent' },
        topicsCovered: { $addToSet: '$topic' },
        skillLevels: {
          $push: {
            level: '$skillLevel',
            topic: '$topic',
            score: '$percentage'
          }
        },
        lastQuiz: { $max: '$completedAt' },
      }
    }
  ]);

  if (stats.length === 0) {
    return {
      totalQuizzes: 0,
      averageScore: 0,
      totalTimeSpent: 0,
      topicsCovered: [],
      skillLevels: [],
      lastQuiz: null,
    };
  }

  const result = stats[0];
  result.topicsCovered = result.topicsCovered || [];
  result.skillLevels = result.skillLevels || [];
  
  return result;
};

module.exports = mongoose.model('Quiz', quizSchema);