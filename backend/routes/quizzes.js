const express = require('express');
const { body, validationResult } = require('express-validator');
const Quiz = require('../models/Quiz');
const QuizResponse = require('../models/QuizResponse');
const { auth } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/quizzes
// @desc    Create a new quiz
// @access  Private
router.post('/', [
  auth,
  body('topic').trim().isLength({ min: 1, max: 100 }).withMessage('Topic is required (1-100 characters)'),
  body('title').trim().isLength({ min: 1, max: 200 }).withMessage('Title is required (1-200 characters)'),
  body('questions').isArray({ min: 1, max: 50 }).withMessage('Questions array is required (1-50 questions)'),
  body('questions.*.question').trim().isLength({ min: 1, max: 500 }).withMessage('Question text is required'),
  body('questions.*.options').isArray({ min: 2, max: 6 }).withMessage('Each question needs 2-6 options'),
  body('questions.*.correctAnswer').isInt({ min: 0 }).withMessage('Correct answer index is required'),
  body('questions.*.difficulty').isIn(['Easy', 'Medium', 'Hard']).withMessage('Invalid difficulty level'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { topic, title, questions } = req.body;

    // Validate each question's correctAnswer index
    for (let i = 0; i < questions.length; i++) {
      const question = questions[i];
      if (question.correctAnswer >= question.options.length) {
        return res.status(400).json({
          success: false,
          message: `Question ${i + 1}: Correct answer index is out of range`,
        });
      }
    }

    const quiz = await Quiz.create({
      userId: req.user.id,
      topic,
      title,
      questions,
      totalQuestions: questions.length,
    });

    res.status(201).json({
      success: true,
      message: 'Quiz created successfully',
      data: { quiz },
    });
  } catch (error) {
    console.error('Create quiz error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating quiz',
    });
  }
});

// @route   GET /api/quizzes
// @desc    Get user's quizzes
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const completed = req.query.completed;
    
    let filter = { userId: req.user.id };
    if (completed !== undefined) {
      filter.isCompleted = completed === 'true';
    }

    const quizzes = await Quiz.find(filter)
      .sort({ createdAt: -1 })
      .limit(limit)
      .populate('userId', 'firstName lastName');

    res.json({
      success: true,
      data: { quizzes },
    });
  } catch (error) {
    console.error('Get quizzes error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching quizzes',
    });
  }
});

// @route   GET /api/quizzes/:id
// @desc    Get a specific quiz
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const quiz = await Quiz.findOne({
      _id: req.params.id,
      userId: req.user.id,
    }).populate('userId', 'firstName lastName');

    if (!quiz) {
      return res.status(404).json({
        success: false,
        message: 'Quiz not found',
      });
    }

    res.json({
      success: true,
      data: { quiz },
    });
  } catch (error) {
    console.error('Get quiz error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching quiz',
    });
  }
});

// @route   POST /api/quizzes/:id/submit
// @desc    Submit quiz responses
// @access  Private
router.post('/:id/submit', [
  auth,
  body('responses').isArray({ min: 1 }).withMessage('Responses array is required'),
  body('responses.*.questionIndex').isInt({ min: 0 }).withMessage('Question index is required'),
  body('responses.*.selectedAnswer').trim().isLength({ min: 1 }).withMessage('Selected answer is required'),
  body('responses.*.selectedIndex').isInt({ min: 0 }).withMessage('Selected index is required'),
  body('responses.*.timeSpent').optional().isInt({ min: 0 }).withMessage('Time spent must be positive'),
  body('totalTimeSpent').isInt({ min: 0 }).withMessage('Total time spent is required'),
  body('startedAt').isISO8601().withMessage('Start time is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const quiz = await Quiz.findOne({
      _id: req.params.id,
      userId: req.user.id,
    });

    if (!quiz) {
      return res.status(404).json({
        success: false,
        message: 'Quiz not found',
      });
    }

    if (quiz.isCompleted) {
      return res.status(400).json({
        success: false,
        message: 'Quiz already completed',
      });
    }

    const { responses, totalTimeSpent, startedAt } = req.body;

    // Validate responses against quiz questions
    if (responses.length !== quiz.questions.length) {
      return res.status(400).json({
        success: false,
        message: 'Number of responses must match number of questions',
      });
    }

    // Process responses and calculate score
    let totalScore = 0;
    const processedResponses = [];

    for (let i = 0; i < responses.length; i++) {
      const response = responses[i];
      const question = quiz.questions[response.questionIndex];

      if (!question) {
        return res.status(400).json({
          success: false,
          message: `Invalid question index: ${response.questionIndex}`,
        });
      }

      const correctAnswer = question.options[question.correctAnswer];
      const isCorrect = response.selectedIndex === question.correctAnswer;
      
      if (isCorrect) {
        totalScore++;
      }

      processedResponses.push({
        questionIndex: response.questionIndex,
        question: question.question,
        selectedAnswer: response.selectedAnswer,
        selectedIndex: response.selectedIndex,
        correctAnswer: correctAnswer,
        correctIndex: question.correctAnswer,
        isCorrect: isCorrect,
        timeSpent: response.timeSpent || 0,
        difficulty: question.difficulty,
      });
    }

    const percentage = Math.round((totalScore / quiz.questions.length) * 100);
    
    // Determine skill level
    let skillLevel;
    if (percentage >= 80) {
      skillLevel = 'Advanced';
    } else if (percentage >= 60) {
      skillLevel = 'Intermediate';
    } else {
      skillLevel = 'Beginner';
    }

    // Create quiz response record
    const quizResponse = await QuizResponse.create({
      userId: req.user.id,
      quizId: quiz._id,
      responses: processedResponses,
      totalScore,
      totalQuestions: quiz.questions.length,
      percentage,
      skillLevel,
      totalTimeSpent,
      startedAt: new Date(startedAt),
      completedAt: new Date(),
    });

    // Update quiz as completed
    await Quiz.findByIdAndUpdate(quiz._id, {
      isCompleted: true,
      score: totalScore,
      percentage,
      skillLevel,
      timeSpent: totalTimeSpent,
      completedAt: new Date(),
    });

    res.json({
      success: true,
      message: 'Quiz submitted successfully',
      data: {
        quizResponse,
        score: totalScore,
        totalQuestions: quiz.questions.length,
        percentage,
        skillLevel,
      },
    });
  } catch (error) {
    console.error('Submit quiz error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while submitting quiz',
    });
  }
});

// @route   GET /api/quizzes/stats/overview
// @desc    Get quiz statistics overview
// @access  Private
router.get('/stats/overview', auth, async (req, res) => {
  try {
    const stats = await Quiz.getQuizStats(req.user.id);
    const responseStats = await QuizResponse.getDetailedAnalytics(req.user.id);

    res.json({
      success: true,
      data: {
        quizStats: stats,
        responseStats: responseStats,
      },
    });
  } catch (error) {
    console.error('Get quiz stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching quiz statistics',
    });
  }
});

// @route   GET /api/quizzes/:id/responses
// @desc    Get quiz responses
// @access  Private
router.get('/:id/responses', auth, async (req, res) => {
  try {
    const quiz = await Quiz.findOne({
      _id: req.params.id,
      userId: req.user.id,
    });

    if (!quiz) {
      return res.status(404).json({
        success: false,
        message: 'Quiz not found',
      });
    }

    const responses = await QuizResponse.findOne({
      quizId: req.params.id,
      userId: req.user.id,
    }).populate('quizId', 'topic title');

    res.json({
      success: true,
      data: { responses },
    });
  } catch (error) {
    console.error('Get quiz responses error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching quiz responses',
    });
  }
});

// @route   DELETE /api/quizzes/:id
// @desc    Delete a quiz and its responses
// @access  Private
router.delete('/:id', auth, async (req, res) => {
  try {
    const quiz = await Quiz.findOne({
      _id: req.params.id,
      userId: req.user.id,
    });

    if (!quiz) {
      return res.status(404).json({
        success: false,
        message: 'Quiz not found',
      });
    }

    // Delete quiz responses first
    await QuizResponse.deleteMany({ quizId: req.params.id });
    
    // Delete quiz
    await Quiz.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Quiz deleted successfully',
    });
  } catch (error) {
    console.error('Delete quiz error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting quiz',
    });
  }
});

module.exports = router;