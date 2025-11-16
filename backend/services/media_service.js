const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const crypto = require('crypto');

class MediaService {
  constructor() {
    this.uploadPath = process.env.UPLOAD_PATH || 'uploads/';
    this.maxFileSize = parseInt(process.env.MAX_FILE_SIZE) || 10485760; // 10MB
    this.allowedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    this.allowedVideoTypes = ['video/mp4', 'video/webm', 'video/ogg'];
    this.allowedAudioTypes = ['audio/mp3', 'audio/wav', 'audio/ogg', 'audio/m4a'];
    this.allowedDocumentTypes = ['application/pdf', 'text/plain', 'application/msword'];
    
    this.initializeDirectories();
  }

  async initializeDirectories() {
    const directories = [
      `${this.uploadPath}images/`,
      `${this.uploadPath}videos/`,
      `${this.uploadPath}audio/`,
      `${this.uploadPath}documents/`,
      `${this.uploadPath}temp/`
    ];

    for (const dir of directories) {
      try {
        await fs.mkdir(dir, { recursive: true });
      } catch (error) {
        console.error(`Error creating directory ${dir}:`, error);
      }
    }
  }

  // Generate unique filename
  generateFileName(originalName) {
    const timestamp = Date.now();
    const randomString = crypto.randomBytes(8).toString('hex');
    const extension = path.extname(originalName);
    return `${timestamp}_${randomString}${extension}`;
  }

  // Get file category based on mime type
  getFileCategory(mimeType) {
    if (this.allowedImageTypes.includes(mimeType)) return 'images';
    if (this.allowedVideoTypes.includes(mimeType)) return 'videos';
    if (this.allowedAudioTypes.includes(mimeType)) return 'audio';
    if (this.allowedDocumentTypes.includes(mimeType)) return 'documents';
    return 'temp';
  }

  // Validate file type
  isValidFileType(mimeType, category = null) {
    const allAllowedTypes = [
      ...this.allowedImageTypes,
      ...this.allowedVideoTypes,
      ...this.allowedAudioTypes,
      ...this.allowedDocumentTypes
    ];

    if (category) {
      switch (category) {
        case 'image':
          return this.allowedImageTypes.includes(mimeType);
        case 'video':
          return this.allowedVideoTypes.includes(mimeType);
        case 'audio':
          return this.allowedAudioTypes.includes(mimeType);
        case 'document':
          return this.allowedDocumentTypes.includes(mimeType);
        default:
          return allAllowedTypes.includes(mimeType);
      }
    }

    return allAllowedTypes.includes(mimeType);
  }

  // Configure multer storage
  getMulterConfig(category = null) {
    const storage = multer.diskStorage({
      destination: (req, file, cb) => {
        const fileCategory = this.getFileCategory(file.mimetype);
        cb(null, `${this.uploadPath}${fileCategory}/`);
      },
      filename: (req, file, cb) => {
        const fileName = this.generateFileName(file.originalname);
        cb(null, fileName);
      }
    });

    const fileFilter = (req, file, cb) => {
      if (this.isValidFileType(file.mimetype, category)) {
        cb(null, true);
      } else {
        cb(new Error(`Invalid file type: ${file.mimetype}`), false);
      }
    };

    return multer({
      storage,
      fileFilter,
      limits: {
        fileSize: this.maxFileSize
      }
    });
  }

  // Upload single file
  uploadSingle(fieldName, category = null) {
    return this.getMulterConfig(category).single(fieldName);
  }

  // Upload multiple files
  uploadMultiple(fieldName, maxCount = 5, category = null) {
    return this.getMulterConfig(category).array(fieldName, maxCount);
  }

  // Upload fields (different field names)
  uploadFields(fields, category = null) {
    return this.getMulterConfig(category).fields(fields);
  }

  // Get file URL
  getFileUrl(filename, category) {
    const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    return `${baseUrl}/uploads/${category}/${filename}`;
  }

  // Delete file
  async deleteFile(filename, category) {
    try {
      const filePath = path.join(this.uploadPath, category, filename);
      await fs.unlink(filePath);
      return true;
    } catch (error) {
      console.error('Error deleting file:', error);
      return false;
    }
  }

  // Get file info
  async getFileInfo(filename, category) {
    try {
      const filePath = path.join(this.uploadPath, category, filename);
      const stats = await fs.stat(filePath);
      
      return {
        filename,
        category,
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime,
        url: this.getFileUrl(filename, category)
      };
    } catch (error) {
      console.error('Error getting file info:', error);
      return null;
    }
  }

  // Clean up old temporary files
  async cleanupTempFiles(olderThanHours = 24) {
    try {
      const tempDir = path.join(this.uploadPath, 'temp');
      const files = await fs.readdir(tempDir);
      const cutoffTime = Date.now() - (olderThanHours * 60 * 60 * 1000);

      for (const file of files) {
        const filePath = path.join(tempDir, file);
        const stats = await fs.stat(filePath);
        
        if (stats.birthtime.getTime() < cutoffTime) {
          await fs.unlink(filePath);
          console.log(`Cleaned up temp file: ${file}`);
        }
      }
    } catch (error) {
      console.error('Error cleaning up temp files:', error);
    }
  }

  // Resize image (requires sharp package)
  async resizeImage(inputPath, outputPath, width, height) {
    try {
      const sharp = require('sharp');
      await sharp(inputPath)
        .resize(width, height, {
          fit: 'cover',
          position: 'center'
        })
        .jpeg({ quality: 80 })
        .toFile(outputPath);
      
      return true;
    } catch (error) {
      console.error('Error resizing image (sharp not installed?):', error);
      return false;
    }
  }

  // Generate thumbnail for video (requires ffmpeg)
  async generateVideoThumbnail(videoPath, thumbnailPath) {
    try {
      const ffmpeg = require('fluent-ffmpeg');
      
      return new Promise((resolve, reject) => {
        ffmpeg(videoPath)
          .screenshots({
            timestamps: ['10%'],
            filename: path.basename(thumbnailPath),
            folder: path.dirname(thumbnailPath),
            size: '320x240'
          })
          .on('end', () => resolve(true))
          .on('error', (err) => reject(err));
      });
    } catch (error) {
      console.error('Error generating video thumbnail (ffmpeg not installed?):', error);
      return false;
    }
  }

  // Get storage statistics
  async getStorageStats() {
    try {
      const categories = ['images', 'videos', 'audio', 'documents', 'temp'];
      const stats = {};
      let totalSize = 0;
      let totalFiles = 0;

      for (const category of categories) {
        const categoryPath = path.join(this.uploadPath, category);
        try {
          const files = await fs.readdir(categoryPath);
          let categorySize = 0;

          for (const file of files) {
            const filePath = path.join(categoryPath, file);
            const fileStats = await fs.stat(filePath);
            categorySize += fileStats.size;
          }

          stats[category] = {
            files: files.length,
            size: categorySize,
            sizeFormatted: this.formatFileSize(categorySize)
          };

          totalFiles += files.length;
          totalSize += categorySize;
        } catch (error) {
          stats[category] = { files: 0, size: 0, sizeFormatted: '0 B' };
        }
      }

      stats.total = {
        files: totalFiles,
        size: totalSize,
        sizeFormatted: this.formatFileSize(totalSize)
      };

      return stats;
    } catch (error) {
      console.error('Error getting storage stats:', error);
      return null;
    }
  }

  // Format file size
  formatFileSize(bytes) {
    if (bytes === 0) return '0 B';
    
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  // Validate image dimensions
  async validateImageDimensions(filePath, minWidth = 100, minHeight = 100, maxWidth = 4000, maxHeight = 4000) {
    try {
      const sharp = require('sharp');
      const metadata = await sharp(filePath).metadata();
      
      return {
        valid: metadata.width >= minWidth && 
               metadata.height >= minHeight && 
               metadata.width <= maxWidth && 
               metadata.height <= maxHeight,
        width: metadata.width,
        height: metadata.height,
        format: metadata.format
      };
    } catch (error) {
      console.error('Error validating image dimensions:', error);
      return { valid: false, error: error.message };
    }
  }
}

module.exports = new MediaService();