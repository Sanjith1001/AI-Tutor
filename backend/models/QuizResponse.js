const mongoose = require('mongoose');

const questionResponseSchema = new mongoose.Schema({
  questionIndex: {
    type: Number,
    required: true,
    min: 0,
  },
  question: {
    type: String,
    required: true,
  },
  selectedAnswer: {
    type: String,
    required: true,
  },
  selectedIndex: {
    type: Number,
    required: true,
    min: 0,
  },
  correctAnswer: {
    type: String,
    required: true,
  },
  correctIndex: {
    type: Number,
    required: true,
    min: 0,
  },
  isCorrect: {
    type: Boolean,
    required: true,
  },
  timeSpent: {
    type: Number, // in seconds
    default: 0,
  },
  difficulty: {
    type: String,
    enum: ['Easy', 'Medium', 'Hard'],
  },
});

const quizResponseSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  quizId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Quiz',
    required: true,
    index: true,
  },
  responses: [questionResponseSchema],
  totalScore: {
    type: Number,
    required: true,
    min: 0,
  },
  totalQuestions: {
    type: Number,
    required: true,
    min: 1,
  },
  percentage: {
    type: Number,
    required: true,
    min: 0,
    max: 100,
  },
  skillLevel: {
    type: String,
    required: true,
    enum: ['Beginner', 'Intermediate', 'Advanced'],
  },
  totalTimeSpent: {
    type: Number, // in seconds
    required: true,
    min: 0,
  },
  startedAt: {
    type: Date,
    required: true,
  },
  completedAt: {
    type: Date,
    required: true,
  },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Indexes for better performance
quizResponseSchema.index({ userId: 1, completedAt: -1 });
quizResponseSchema.index({ quizId: 1 });
quizResponseSchema.index({ skillLevel: 1 });
quizResponseSchema.index({ percentage: -1 });

// Virtual for performance analysis
quizResponseSchema.virtual('performanceAnalysis').get(function() {
  const correctByDifficulty = {
    Easy: { correct: 0, total: 0 },
    Medium: { correct: 0, total: 0 },
    Hard: { correct: 0, total: 0 },
  };

  this.responses.forEach(response => {
    if (response.difficulty) {
      correctByDifficulty[response.difficulty].total++;
      if (response.isCorrect) {
        correctByDifficulty[response.difficulty].correct++;
      }
    }
  });

  return {
    byDifficulty: correctByDifficulty,
    averageTimePerQuestion: this.totalTimeSpent / this.totalQuestions,
    accuracyRate: this.percentage,
  };
});

// Static method to get detailed analytics
quizResponseSchema.statics.getDetailedAnalytics = async function(userId, topic = null) {
  const matchConditions = { userId: new mongoose.Types.ObjectId(userId) };
  if (topic) {
    // We'll need to populate quiz to filter by topic
    const quizzes = await mongoose.model('Quiz').find({ userId, topic }).select('_id');
    matchConditions.quizId = { $in: quizzes.map(q => q._id) };
  }

  const analytics = await this.aggregate([
    { $match: matchConditions },
    {
      $group: {
        _id: null,
        totalResponses: { $sum: 1 },
        averageScore: { $avg: '$percentage' },
        averageTime: { $avg: '$totalTimeSpent' },
        skillLevelDistribution: {
          $push: '$skillLevel'
        },
        scoreDistribution: {
          $push: '$percentage'
        },
        recentScores: {
          $push: {
            score: '$percentage',
            date: '$completedAt',
            topic: '$quizId' // We'll populate this later
          }
        }
      }
    }
  ]);

  return analytics[0] || {
    totalResponses: 0,
    averageScore: 0,
    averageTime: 0,
    skillLevelDistribution: [],
    scoreDistribution: [],
    recentScores: [],
  };
};

module.exports = mongoose.model('QuizResponse', quizResponseSchema);