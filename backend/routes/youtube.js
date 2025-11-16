const express = require('express');
const { query, validationResult } = require('express-validator');
const YouTubeService = require('../services/youtube_service');
const { auth } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/youtube/search
// @desc    Search YouTube videos
// @access  Private
router.get('/search', [
  auth,
  query('q').trim().isLength({ min: 1 }).withMessage('Search query is required'),
  query('maxResults').optional().isInt({ min: 1, max: 50 }).withMessage('Max results must be between 1 and 50'),
  query('order').optional().isIn(['relevance', 'date', 'rating', 'viewCount', 'title']).withMessage('Invalid order parameter'),
  query('duration').optional().isIn(['any', 'short', 'medium', 'long']).withMessage('Invalid duration parameter')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const {
      q: query,
      maxResults = 10,
      order = 'relevance',
      duration = 'any',
      regionCode = 'US',
      relevanceLanguage = 'en'
    } = req.query;

    const result = await YouTubeService.searchVideos(query, {
      maxResults: parseInt(maxResults),
      order,
      duration,
      regionCode,
      relevanceLanguage
    });

    res.json(result);
  } catch (error) {
    console.error('YouTube search error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search YouTube videos'
    });
  }
});

// @route   GET /api/youtube/video/:videoId
// @desc    Get YouTube video details
// @access  Private
router.get('/video/:videoId', auth, async (req, res) => {
  try {
    const { videoId } = req.params;
    
    if (!videoId) {
      return res.status(400).json({
        success: false,
        message: 'Video ID is required'
      });
    }

    const result = await YouTubeService.getVideoDetails(videoId);
    res.json(result);
  } catch (error) {
    console.error('YouTube video details error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get video details'
    });
  }
});

// @route   GET /api/youtube/educational
// @desc    Get educational videos by topic
// @access  Private
router.get('/educational', [
  auth,
  query('topic').trim().isLength({ min: 1 }).withMessage('Topic is required'),
  query('maxResults').optional().isInt({ min: 1, max: 25 }).withMessage('Max results must be between 1 and 25')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { topic, maxResults = 10 } = req.query;

    const result = await YouTubeService.getEducationalVideos(topic, {
      maxResults: parseInt(maxResults)
    });

    res.json(result);
  } catch (error) {
    console.error('YouTube educational videos error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get educational videos'
    });
  }
});

// @route   GET /api/youtube/trending
// @desc    Get trending educational videos
// @access  Private
router.get('/trending', [
  auth,
  query('maxResults').optional().isInt({ min: 1, max: 25 }).withMessage('Max results must be between 1 and 25'),
  query('regionCode').optional().isLength({ min: 2, max: 2 }).withMessage('Region code must be 2 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { maxResults = 25, regionCode = 'US' } = req.query;

    const result = await YouTubeService.getTrendingEducationalVideos({
      maxResults: parseInt(maxResults),
      regionCode
    });

    res.json(result);
  } catch (error) {
    console.error('YouTube trending videos error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get trending videos'
    });
  }
});

// @route   GET /api/youtube/embed/:videoId
// @desc    Get video embed HTML
// @access  Private
router.get('/embed/:videoId', auth, async (req, res) => {
  try {
    const { videoId } = req.params;
    const {
      width = 560,
      height = 315,
      autoplay = false,
      controls = true,
      modestbranding = true,
      rel = false
    } = req.query;

    if (!videoId) {
      return res.status(400).json({
        success: false,
        message: 'Video ID is required'
      });
    }

    const embedHtml = YouTubeService.getEmbedHtml(videoId, {
      width: parseInt(width),
      height: parseInt(height),
      autoplay: autoplay === 'true',
      controls: controls === 'true',
      modestbranding: modestbranding === 'true',
      rel: rel === 'true'
    });

    res.json({
      success: true,
      data: {
        videoId,
        embedHtml,
        embedUrl: `https://www.youtube.com/embed/${videoId}`
      }
    });
  } catch (error) {
    console.error('YouTube embed error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate embed code'
    });
  }
});

// @route   POST /api/youtube/validate-url
// @desc    Validate YouTube URL and extract video ID
// @access  Private
router.post('/validate-url', auth, async (req, res) => {
  try {
    const { url } = req.body;

    if (!url) {
      return res.status(400).json({
        success: false,
        message: 'URL is required'
      });
    }

    const isValid = YouTubeService.isValidYouTubeUrl(url);
    const videoId = YouTubeService.extractVideoId(url);

    if (isValid && videoId) {
      // Get video details to ensure it exists and is accessible
      const videoDetails = await YouTubeService.getVideoDetails(videoId);
      
      res.json({
        success: true,
        data: {
          isValid: true,
          videoId,
          url: `https://www.youtube.com/watch?v=${videoId}`,
          embedUrl: `https://www.youtube.com/embed/${videoId}`,
          videoExists: videoDetails.success,
          videoDetails: videoDetails.success ? videoDetails.data : null
        }
      });
    } else {
      res.json({
        success: true,
        data: {
          isValid: false,
          videoId: null,
          message: 'Invalid YouTube URL'
        }
      });
    }
  } catch (error) {
    console.error('YouTube URL validation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to validate YouTube URL'
    });
  }
});

// @route   GET /api/youtube/quota
// @desc    Get API quota usage information
// @access  Private
router.get('/quota', auth, async (req, res) => {
  try {
    const quotaInfo = YouTubeService.getQuotaUsage();
    
    res.json({
      success: true,
      data: {
        quotaUsage: quotaInfo,
        message: 'These are approximate quota costs per request type'
      }
    });
  } catch (error) {
    console.error('YouTube quota info error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get quota information'
    });
  }
});

module.exports = router;