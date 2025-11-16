// Simple in-memory cache service (can be upgraded to Redis later)
class CacheService {
  constructor() {
    this.cache = new Map();
    this.ttl = new Map(); // Time to live for each key
    this.defaultTTL = 5 * 60 * 1000; // 5 minutes default
    
    // Cleanup expired entries every minute
    setInterval(() => this.cleanup(), 60 * 1000);
    
    console.log('💾 Cache Service initialized (In-Memory)');
  }

  // Set cache with TTL
  set(key, value, ttlMs = this.defaultTTL) {
    this.cache.set(key, value);
    this.ttl.set(key, Date.now() + ttlMs);
    return true;
  }

  // Get from cache
  get(key) {
    if (!this.cache.has(key)) {
      return null;
    }

    const expiry = this.ttl.get(key);
    if (expiry && Date.now() > expiry) {
      this.delete(key);
      return null;
    }

    return this.cache.get(key);
  }

  // Delete from cache
  delete(key) {
    this.cache.delete(key);
    this.ttl.delete(key);
    return true;
  }

  // Check if key exists and not expired
  has(key) {
    if (!this.cache.has(key)) {
      return false;
    }

    const expiry = this.ttl.get(key);
    if (expiry && Date.now() > expiry) {
      this.delete(key);
      return false;
    }

    return true;
  }

  // Clear all cache
  clear() {
    this.cache.clear();
    this.ttl.clear();
    return true;
  }

  // Get cache statistics
  getStats() {
    return {
      size: this.cache.size,
      keys: Array.from(this.cache.keys()),
      memoryUsage: this.getMemoryUsage()
    };
  }

  // Cleanup expired entries
  cleanup() {
    const now = Date.now();
    let cleaned = 0;

    for (const [key, expiry] of this.ttl.entries()) {
      if (expiry && now > expiry) {
        this.delete(key);
        cleaned++;
      }
    }

    if (cleaned > 0) {
      console.log(`🧹 Cache cleanup: removed ${cleaned} expired entries`);
    }
  }

  // Get approximate memory usage
  getMemoryUsage() {
    let size = 0;
    for (const [key, value] of this.cache.entries()) {
      size += JSON.stringify(key).length + JSON.stringify(value).length;
    }
    return `${Math.round(size / 1024)} KB`;
  }

  // Cache wrapper for functions
  async wrap(key, fn, ttlMs = this.defaultTTL) {
    // Check if cached
    const cached = this.get(key);
    if (cached !== null) {
      return cached;
    }

    // Execute function and cache result
    try {
      const result = await fn();
      this.set(key, result, ttlMs);
      return result;
    } catch (error) {
      throw error;
    }
  }

  // Generate cache keys
  generateKey(prefix, ...parts) {
    return `${prefix}:${parts.join(':')}`;
  }

  // Cache popular courses
  async getCachedPopularCourses() {
    return this.get('popular_courses');
  }

  setCachedPopularCourses(courses, ttlMs = 10 * 60 * 1000) { // 10 minutes
    return this.set('popular_courses', courses, ttlMs);
  }

  // Cache user analytics
  getCachedUserAnalytics(userId) {
    return this.get(`user_analytics:${userId}`);
  }

  setCachedUserAnalytics(userId, analytics, ttlMs = 5 * 60 * 1000) { // 5 minutes
    return this.set(`user_analytics:${userId}`, analytics, ttlMs);
  }

  // Cache course details
  getCachedCourse(courseId) {
    return this.get(`course:${courseId}`);
  }

  setCachedCourse(courseId, course, ttlMs = 15 * 60 * 1000) { // 15 minutes
    return this.set(`course:${courseId}`, course, ttlMs);
  }

  // Invalidate course cache when updated
  invalidateCourse(courseId) {
    this.delete(`course:${courseId}`);
    this.delete('popular_courses'); // Also invalidate popular courses
  }

  // Cache search results
  getCachedSearch(query, filters) {
    const key = this.generateKey('search', query, JSON.stringify(filters));
    return this.get(key);
  }

  setCachedSearch(query, filters, results, ttlMs = 5 * 60 * 1000) { // 5 minutes
    const key = this.generateKey('search', query, JSON.stringify(filters));
    return this.set(key, results, ttlMs);
  }

  // Cache online users count
  getCachedOnlineCount() {
    return this.get('online_users_count');
  }

  setCachedOnlineCount(count, ttlMs = 30 * 1000) { // 30 seconds
    return this.set('online_users_count', count, ttlMs);
  }
}

module.exports = new CacheService();