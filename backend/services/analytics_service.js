const User = require('../models/User');
const Course = require('../models/Course');

class AnalyticsService {
  // Get user learning analytics
  async getUserAnalytics(userId) {
    try {
      const user = await User.findById(userId);
      if (!user) {
        return { success: false, message: 'User not found' };
      }

      // Get enrolled courses with progress
      const enrolledCourses = await Course.find({
        'enrolledStudents.user': userId
      }).select('title category difficulty enrolledStudents totalModules');

      const userEnrollments = enrolledCourses.map(course => {
        const enrollment = course.enrolledStudents.find(
          e => e.user.toString() === userId
        );
        return {
          courseId: course._id,
          courseTitle: course.title,
          category: course.category,
          difficulty: course.difficulty,
          progress: enrollment.progress,
          completedModules: enrollment.completedModules.length,
          totalModules: course.totalModules,
          enrolledAt: enrollment.enrolledAt,
          lastAccessedAt: enrollment.lastAccessedAt,
          certificateIssued: enrollment.certificateIssued
        };
      });

      // Calculate statistics
      const totalCourses = enrolledCourses.length;
      const completedCourses = userEnrollments.filter(e => e.progress === 100).length;
      const inProgressCourses = userEnrollments.filter(e => e.progress > 0 && e.progress < 100).length;
      const averageProgress = totalCourses > 0 
        ? userEnrollments.reduce((sum, e) => sum + e.progress, 0) / totalCourses 
        : 0;

      // Category breakdown
      const categoryStats = {};
      userEnrollments.forEach(enrollment => {
        if (!categoryStats[enrollment.category]) {
          categoryStats[enrollment.category] = {
            total: 0,
            completed: 0,
            inProgress: 0,
            averageProgress: 0
          };
        }
        categoryStats[enrollment.category].total++;
        if (enrollment.progress === 100) {
          categoryStats[enrollment.category].completed++;
        } else if (enrollment.progress > 0) {
          categoryStats[enrollment.category].inProgress++;
        }
      });

      // Calculate average progress per category
      Object.keys(categoryStats).forEach(category => {
        const categoryEnrollments = userEnrollments.filter(e => e.category === category);
        categoryStats[category].averageProgress = categoryEnrollments.length > 0
          ? categoryEnrollments.reduce((sum, e) => sum + e.progress, 0) / categoryEnrollments.length
          : 0;
      });

      // Learning streak calculation
      const learningStreak = await this.calculateLearningStreak(userId);

      // Time spent learning (approximate based on module completions)
      const totalModulesCompleted = userEnrollments.reduce((sum, e) => sum + e.completedModules, 0);
      const estimatedTimeSpent = totalModulesCompleted * 15; // Assume 15 minutes per module

      return {
        success: true,
        data: {
          overview: {
            totalCourses,
            completedCourses,
            inProgressCourses,
            averageProgress: Math.round(averageProgress * 100) / 100,
            certificatesEarned: userEnrollments.filter(e => e.certificateIssued).length,
            learningStreak,
            estimatedTimeSpent // in minutes
          },
          enrollments: userEnrollments,
          categoryStats,
          learningPath: await this.generateLearningPath(userId, userEnrollments)
        }
      };
    } catch (error) {
      console.error('Get user analytics error:', error);
      return {
        success: false,
        message: 'Failed to get user analytics'
      };
    }
  }

  // Calculate learning streak
  async calculateLearningStreak(userId) {
    try {
      const courses = await Course.find({
        'enrolledStudents.user': userId
      });

      let streak = 0;
      let currentDate = new Date();
      currentDate.setHours(0, 0, 0, 0);

      // Get all completion dates
      const completionDates = [];
      courses.forEach(course => {
        const enrollment = course.enrolledStudents.find(
          e => e.user.toString() === userId
        );
        if (enrollment && enrollment.completedModules) {
          enrollment.completedModules.forEach(module => {
            if (module.completedAt) {
              const date = new Date(module.completedAt);
              date.setHours(0, 0, 0, 0);
              completionDates.push(date.getTime());
            }
          });
        }
      });

      // Remove duplicates and sort
      const uniqueDates = [...new Set(completionDates)].sort((a, b) => b - a);

      // Calculate streak
      for (let i = 0; i < uniqueDates.length; i++) {
        const date = new Date(uniqueDates[i]);
        const expectedDate = new Date(currentDate.getTime() - (i * 24 * 60 * 60 * 1000));
        
        if (date.getTime() === expectedDate.getTime()) {
          streak++;
        } else {
          break;
        }
      }

      return streak;
    } catch (error) {
      console.error('Calculate learning streak error:', error);
      return 0;
    }
  }

  // Generate personalized learning path
  async generateLearningPath(userId, enrollments) {
    try {
      // Analyze completed courses to suggest next steps
      const completedCategories = enrollments
        .filter(e => e.progress === 100)
        .map(e => e.category);

      const inProgressCategories = enrollments
        .filter(e => e.progress > 0 && e.progress < 100)
        .map(e => e.category);

      // Get recommended courses based on learning history
      const recommendedCourses = await Course.find({
        isPublished: true,
        isActive: true,
        'enrolledStudents.user': { $ne: userId },
        $or: [
          { category: { $in: completedCategories } },
          { category: { $in: inProgressCategories } }
        ]
      })
      .limit(5)
      .select('title category difficulty averageRating enrollmentCount');

      return {
        nextSteps: [
          ...inProgressCategories.length > 0 ? ['Complete your in-progress courses'] : [],
          ...completedCategories.length > 0 ? ['Explore advanced topics in your completed categories'] : [],
          'Try courses in new categories to broaden your skills'
        ],
        recommendedCourses: recommendedCourses.map(course => ({
          id: course._id,
          title: course.title,
          category: course.category,
          difficulty: course.difficulty,
          rating: course.averageRating,
          popularity: course.enrollmentCount
        }))
      };
    } catch (error) {
      console.error('Generate learning path error:', error);
      return {
        nextSteps: [],
        recommendedCourses: []
      };
    }
  }

  // Get course analytics (for instructors/admins)
  async getCourseAnalytics(courseId) {
    try {
      const course = await Course.findById(courseId)
        .populate('enrolledStudents.user', 'firstName lastName email')
        .populate('ratings.user', 'firstName lastName');

      if (!course) {
        return { success: false, message: 'Course not found' };
      }

      const enrollments = course.enrolledStudents;
      const totalEnrollments = enrollments.length;
      const completedEnrollments = enrollments.filter(e => e.progress === 100).length;
      const inProgressEnrollments = enrollments.filter(e => e.progress > 0 && e.progress < 100).length;
      const notStartedEnrollments = enrollments.filter(e => e.progress === 0).length;

      // Calculate average progress
      const averageProgress = totalEnrollments > 0
        ? enrollments.reduce((sum, e) => sum + e.progress, 0) / totalEnrollments
        : 0;

      // Completion rate
      const completionRate = totalEnrollments > 0
        ? (completedEnrollments / totalEnrollments) * 100
        : 0;

      // Module completion statistics
      const moduleStats = course.modules.map((module, index) => {
        const completions = enrollments.filter(enrollment =>
          enrollment.completedModules.some(cm => cm.moduleId.toString() === module._id.toString())
        ).length;

        return {
          moduleIndex: index + 1,
          moduleTitle: module.title,
          completions,
          completionRate: totalEnrollments > 0 ? (completions / totalEnrollments) * 100 : 0
        };
      });

      // Enrollment timeline (last 30 days)
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
      const recentEnrollments = enrollments.filter(e => e.enrolledAt >= thirtyDaysAgo);
      
      // Group by day
      const enrollmentTimeline = {};
      recentEnrollments.forEach(enrollment => {
        const date = enrollment.enrolledAt.toISOString().split('T')[0];
        enrollmentTimeline[date] = (enrollmentTimeline[date] || 0) + 1;
      });

      // Rating distribution
      const ratingDistribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
      course.ratings.forEach(rating => {
        ratingDistribution[rating.rating]++;
      });

      return {
        success: true,
        data: {
          overview: {
            totalEnrollments,
            completedEnrollments,
            inProgressEnrollments,
            notStartedEnrollments,
            averageProgress: Math.round(averageProgress * 100) / 100,
            completionRate: Math.round(completionRate * 100) / 100,
            averageRating: course.averageRating,
            totalRatings: course.totalRatings,
            views: course.views
          },
          moduleStats,
          enrollmentTimeline,
          ratingDistribution,
          recentEnrollments: recentEnrollments.slice(0, 10).map(e => ({
            user: e.user,
            enrolledAt: e.enrolledAt,
            progress: e.progress,
            lastAccessedAt: e.lastAccessedAt
          })),
          topPerformers: enrollments
            .filter(e => e.progress === 100)
            .sort((a, b) => {
              const aTime = a.completedModules.length > 0 
                ? new Date(a.completedModules[a.completedModules.length - 1].completedAt) - new Date(a.enrolledAt)
                : Infinity;
              const bTime = b.completedModules.length > 0
                ? new Date(b.completedModules[b.completedModules.length - 1].completedAt) - new Date(b.enrolledAt)
                : Infinity;
              return aTime - bTime;
            })
            .slice(0, 5)
            .map(e => ({
              user: e.user,
              completionTime: e.completedModules.length > 0
                ? Math.round((new Date(e.completedModules[e.completedModules.length - 1].completedAt) - new Date(e.enrolledAt)) / (1000 * 60 * 60 * 24))
                : null,
              certificateIssued: e.certificateIssued
            }))
        }
      };
    } catch (error) {
      console.error('Get course analytics error:', error);
      return {
        success: false,
        message: 'Failed to get course analytics'
      };
    }
  }

  // Get platform-wide analytics (admin only)
  async getPlatformAnalytics() {
    try {
      // User statistics
      const totalUsers = await User.countDocuments();
      const activeUsers = await User.countDocuments({
        lastLoginAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
      });

      // Course statistics
      const totalCourses = await Course.countDocuments();
      const publishedCourses = await Course.countDocuments({ isPublished: true });
      const totalEnrollments = await Course.aggregate([
        { $project: { enrollmentCount: { $size: '$enrolledStudents' } } },
        { $group: { _id: null, total: { $sum: '$enrollmentCount' } } }
      ]);

      // Popular categories
      const categoryStats = await Course.aggregate([
        { $match: { isPublished: true } },
        {
          $group: {
            _id: '$category',
            courseCount: { $sum: 1 },
            totalEnrollments: { $sum: { $size: '$enrolledStudents' } },
            averageRating: { $avg: '$averageRating' }
          }
        },
        { $sort: { totalEnrollments: -1 } }
      ]);

      // Learning trends (last 6 months)
      const sixMonthsAgo = new Date(Date.now() - 6 * 30 * 24 * 60 * 60 * 1000);
      const learningTrends = await Course.aggregate([
        { $unwind: '$enrolledStudents' },
        { $match: { 'enrolledStudents.enrolledAt': { $gte: sixMonthsAgo } } },
        {
          $group: {
            _id: {
              year: { $year: '$enrolledStudents.enrolledAt' },
              month: { $month: '$enrolledStudents.enrolledAt' }
            },
            enrollments: { $sum: 1 }
          }
        },
        { $sort: { '_id.year': 1, '_id.month': 1 } }
      ]);

      // Top performing courses
      const topCourses = await Course.find({ isPublished: true })
        .sort({ enrollmentCount: -1, averageRating: -1 })
        .limit(10)
        .select('title category enrollmentCount averageRating totalRatings');

      return {
        success: true,
        data: {
          overview: {
            totalUsers,
            activeUsers,
            totalCourses,
            publishedCourses,
            totalEnrollments: totalEnrollments[0]?.total || 0,
            userEngagementRate: totalUsers > 0 ? Math.round((activeUsers / totalUsers) * 100) : 0
          },
          categoryStats,
          learningTrends,
          topCourses
        }
      };
    } catch (error) {
      console.error('Get platform analytics error:', error);
      return {
        success: false,
        message: 'Failed to get platform analytics'
      };
    }
  }

  // Track user activity
  async trackActivity(userId, activityType, metadata = {}) {
    try {
      const user = await User.findById(userId);
      if (!user) {
        return { success: false, message: 'User not found' };
      }

      // Update user's last activity
      user.lastActivityAt = new Date();
      
      // Add to activity log (you might want to create a separate Activity model)
      if (!user.activityLog) {
        user.activityLog = [];
      }

      user.activityLog.push({
        type: activityType,
        timestamp: new Date(),
        metadata
      });

      // Keep only last 100 activities
      if (user.activityLog.length > 100) {
        user.activityLog = user.activityLog.slice(-100);
      }

      await user.save();

      return { success: true, message: 'Activity tracked successfully' };
    } catch (error) {
      console.error('Track activity error:', error);
      return {
        success: false,
        message: 'Failed to track activity'
      };
    }
  }
}

module.exports = new AnalyticsService();