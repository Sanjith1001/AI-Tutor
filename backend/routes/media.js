const express = require('express');
const path = require('path');
const MediaService = require('../services/media_service');
const { auth, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/media/upload/image
// @desc    Upload single image
// @access  Private
router.post('/upload/image', auth, (req, res) => {
  const upload = MediaService.uploadSingle('image', 'image');
  
  upload(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided'
      });
    }

    try {
      const fileInfo = await MediaService.getFileInfo(req.file.filename, 'images');
      
      res.json({
        success: true,
        message: 'Image uploaded successfully',
        data: {
          filename: req.file.filename,
          originalName: req.file.originalname,
          size: req.file.size,
          url: fileInfo.url
        }
      });
    } catch (error) {
      console.error('Image upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to process uploaded image'
      });
    }
  });
});

// @route   POST /api/media/upload/video
// @desc    Upload single video
// @access  Private
router.post('/upload/video', auth, (req, res) => {
  const upload = MediaService.uploadSingle('video', 'video');
  
  upload(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No video file provided'
      });
    }

    try {
      const fileInfo = await MediaService.getFileInfo(req.file.filename, 'videos');
      
      res.json({
        success: true,
        message: 'Video uploaded successfully',
        data: {
          filename: req.file.filename,
          originalName: req.file.originalname,
          size: req.file.size,
          url: fileInfo.url
        }
      });
    } catch (error) {
      console.error('Video upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to process uploaded video'
      });
    }
  });
});

// @route   POST /api/media/upload/audio
// @desc    Upload single audio file
// @access  Private
router.post('/upload/audio', auth, (req, res) => {
  const upload = MediaService.uploadSingle('audio', 'audio');
  
  upload(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No audio file provided'
      });
    }

    try {
      const fileInfo = await MediaService.getFileInfo(req.file.filename, 'audio');
      
      res.json({
        success: true,
        message: 'Audio uploaded successfully',
        data: {
          filename: req.file.filename,
          originalName: req.file.originalname,
          size: req.file.size,
          url: fileInfo.url
        }
      });
    } catch (error) {
      console.error('Audio upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to process uploaded audio'
      });
    }
  });
});

// @route   POST /api/media/upload/document
// @desc    Upload single document
// @access  Private
router.post('/upload/document', auth, (req, res) => {
  const upload = MediaService.uploadSingle('document', 'document');
  
  upload(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No document file provided'
      });
    }

    try {
      const fileInfo = await MediaService.getFileInfo(req.file.filename, 'documents');
      
      res.json({
        success: true,
        message: 'Document uploaded successfully',
        data: {
          filename: req.file.filename,
          originalName: req.file.originalname,
          size: req.file.size,
          url: fileInfo.url
        }
      });
    } catch (error) {
      console.error('Document upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to process uploaded document'
      });
    }
  });
});

// @route   POST /api/media/upload/multiple
// @desc    Upload multiple files
// @access  Private
router.post('/upload/multiple', auth, (req, res) => {
  const upload = MediaService.uploadMultiple('files', 10);
  
  upload(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No files provided'
      });
    }

    try {
      const uploadedFiles = [];
      
      for (const file of req.files) {
        const category = MediaService.getFileCategory(file.mimetype);
        const fileInfo = await MediaService.getFileInfo(file.filename, category);
        
        uploadedFiles.push({
          filename: file.filename,
          originalName: file.originalname,
          size: file.size,
          category,
          url: fileInfo.url
        });
      }
      
      res.json({
        success: true,
        message: `${uploadedFiles.length} files uploaded successfully`,
        data: { files: uploadedFiles }
      });
    } catch (error) {
      console.error('Multiple upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to process uploaded files'
      });
    }
  });
});

// @route   DELETE /api/media/:category/:filename
// @desc    Delete uploaded file
// @access  Private
router.delete('/:category/:filename', auth, async (req, res) => {
  try {
    const { category, filename } = req.params;
    
    const deleted = await MediaService.deleteFile(filename, category);
    
    if (deleted) {
      res.json({
        success: true,
        message: 'File deleted successfully'
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'File not found or could not be deleted'
      });
    }
  } catch (error) {
    console.error('Delete file error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete file'
    });
  }
});

// @route   GET /api/media/info/:category/:filename
// @desc    Get file information
// @access  Private
router.get('/info/:category/:filename', auth, async (req, res) => {
  try {
    const { category, filename } = req.params;
    
    const fileInfo = await MediaService.getFileInfo(filename, category);
    
    if (fileInfo) {
      res.json({
        success: true,
        data: fileInfo
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'File not found'
      });
    }
  } catch (error) {
    console.error('Get file info error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get file information'
    });
  }
});

// @route   GET /api/media/stats
// @desc    Get storage statistics
// @access  Private/Admin
router.get('/stats', [auth, authorize('admin')], async (req, res) => {
  try {
    const stats = await MediaService.getStorageStats();
    
    if (stats) {
      res.json({
        success: true,
        data: stats
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to get storage statistics'
      });
    }
  } catch (error) {
    console.error('Get storage stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get storage statistics'
    });
  }
});

// @route   POST /api/media/cleanup
// @desc    Clean up temporary files
// @access  Private/Admin
router.post('/cleanup', [auth, authorize('admin')], async (req, res) => {
  try {
    const { olderThanHours = 24 } = req.body;
    
    await MediaService.cleanupTempFiles(olderThanHours);
    
    res.json({
      success: true,
      message: 'Temporary files cleaned up successfully'
    });
  } catch (error) {
    console.error('Cleanup temp files error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cleanup temporary files'
    });
  }
});

// Serve uploaded files statically
router.use('/uploads', express.static(path.join(__dirname, '../uploads')));

module.exports = router;