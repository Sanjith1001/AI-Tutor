const axios = require('axios');

class YouTubeService {
  constructor() {
    this.apiKey = process.env.YOUTUBE_API_KEY;
    this.baseUrl = 'https://www.googleapis.com/youtube/v3';
    
    if (!this.apiKey) {
      console.warn('⚠️  YouTube API key not found. YouTube features will be disabled.');
    }
  }

  // Search for videos
  async searchVideos(query, options = {}) {
    if (!this.apiKey) {
      throw new Error('YouTube API key not configured');
    }

    try {
      const {
        maxResults = 10,
        order = 'relevance',
        duration = 'any',
        type = 'video',
        regionCode = 'US',
        relevanceLanguage = 'en'
      } = options;

      const response = await axios.get(`${this.baseUrl}/search`, {
        params: {
          key: this.apiKey,
          q: query,
          part: 'snippet',
          type,
          maxResults,
          order,
          videoDuration: duration,
          regionCode,
          relevanceLanguage,
          safeSearch: 'moderate'
        }
      });

      return {
        success: true,
        data: {
          videos: response.data.items.map(item => ({
            id: item.id.videoId,
            title: item.snippet.title,
            description: item.snippet.description,
            thumbnail: {
              default: item.snippet.thumbnails.default?.url,
              medium: item.snippet.thumbnails.medium?.url,
              high: item.snippet.thumbnails.high?.url,
              maxres: item.snippet.thumbnails.maxres?.url
            },
            channelTitle: item.snippet.channelTitle,
            channelId: item.snippet.channelId,
            publishedAt: item.snippet.publishedAt,
            url: `https://www.youtube.com/watch?v=${item.id.videoId}`,
            embedUrl: `https://www.youtube.com/embed/${item.id.videoId}`
          })),
          totalResults: response.data.pageInfo.totalResults,
          nextPageToken: response.data.nextPageToken,
          prevPageToken: response.data.prevPageToken
        }
      };
    } catch (error) {
      console.error('YouTube search error:', error.response?.data || error.message);
      return {
        success: false,
        message: 'Failed to search YouTube videos',
        error: error.response?.data?.error || error.message
      };
    }
  } 
 // Get video details
  async getVideoDetails(videoId) {
    if (!this.apiKey) {
      throw new Error('YouTube API key not configured');
    }

    try {
      const response = await axios.get(`${this.baseUrl}/videos`, {
        params: {
          key: this.apiKey,
          id: videoId,
          part: 'snippet,contentDetails,statistics,status'
        }
      });

      if (response.data.items.length === 0) {
        return {
          success: false,
          message: 'Video not found'
        };
      }

      const video = response.data.items[0];
      
      return {
        success: true,
        data: {
          id: video.id,
          title: video.snippet.title,
          description: video.snippet.description,
          thumbnail: {
            default: video.snippet.thumbnails.default?.url,
            medium: video.snippet.thumbnails.medium?.url,
            high: video.snippet.thumbnails.high?.url,
            maxres: video.snippet.thumbnails.maxres?.url
          },
          channelTitle: video.snippet.channelTitle,
          channelId: video.snippet.channelId,
          publishedAt: video.snippet.publishedAt,
          duration: this.parseDuration(video.contentDetails.duration),
          viewCount: parseInt(video.statistics.viewCount),
          likeCount: parseInt(video.statistics.likeCount || 0),
          commentCount: parseInt(video.statistics.commentCount || 0),
          tags: video.snippet.tags || [],
          categoryId: video.snippet.categoryId,
          defaultLanguage: video.snippet.defaultLanguage,
          url: `https://www.youtube.com/watch?v=${video.id}`,
          embedUrl: `https://www.youtube.com/embed/${video.id}`,
          isEmbeddable: video.status.embeddable,
          privacyStatus: video.status.privacyStatus
        }
      };
    } catch (error) {
      console.error('YouTube video details error:', error.response?.data || error.message);
      return {
        success: false,
        message: 'Failed to get video details',
        error: error.response?.data?.error || error.message
      };
    }
  }

  // Get educational videos by topic
  async getEducationalVideos(topic, options = {}) {
    const educationalQuery = `${topic} tutorial education learn`;
    
    return await this.searchVideos(educationalQuery, {
      ...options,
      order: 'relevance',
      duration: 'medium'
    });
  }

  // Parse YouTube duration format (PT4M13S -> 253 seconds)
  parseDuration(duration) {
    const match = duration.match(/PT(\d+H)?(\d+M)?(\d+S)?/);
    
    const hours = (match[1] || '').replace('H', '') || 0;
    const minutes = (match[2] || '').replace('M', '') || 0;
    const seconds = (match[3] || '').replace('S', '') || 0;
    
    return parseInt(hours) * 3600 + parseInt(minutes) * 60 + parseInt(seconds);
  }

  // Extract video ID from YouTube URL
  extractVideoId(url) {
    const regex = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/;
    const match = url.match(regex);
    return match ? match[1] : null;
  }

  // Validate YouTube URL
  isValidYouTubeUrl(url) {
    return this.extractVideoId(url) !== null;
  }

  // Get video embed HTML
  getEmbedHtml(videoId, options = {}) {
    const {
      width = 560,
      height = 315,
      autoplay = false,
      controls = true,
      modestbranding = true,
      rel = false
    } = options;

    const params = new URLSearchParams({
      autoplay: autoplay ? 1 : 0,
      controls: controls ? 1 : 0,
      modestbranding: modestbranding ? 1 : 0,
      rel: rel ? 1 : 0
    });

    return `<iframe width="${width}" height="${height}" src="https://www.youtube.com/embed/${videoId}?${params}" frameborder="0" allowfullscreen></iframe>`;
  }
}

module.exports = new YouTubeService();