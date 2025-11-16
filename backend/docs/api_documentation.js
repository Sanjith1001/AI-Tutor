// API Documentation Generator
const fs = require('fs');
const path = require('path');

class APIDocumentationGenerator {
  constructor() {
    this.endpoints = [];
    this.models = [];
  }

  // Generate comprehensive API documentation
  generateDocumentation() {
    const documentation = {
      title: 'ByteBrain AI-Tutor API Documentation',
      version: '1.0.0',
      description: 'Complete API documentation for ByteBrain AI-powered learning platform',
      baseUrl: 'http://localhost:3000/api',
      authentication: {
        type: 'Bearer Token (JWT)',
        header: 'Authorization: Bearer <token>',
        description: 'Most endpoints require authentication. Include JWT token in Authorization header.'
      },
      endpoints: this.getEndpointDocumentation(),
      models: this.getModelDocumentation(),
      examples: this.getExamples(),
      errorCodes: this.getErrorCodes()
    };

    return documentation;
  }

  // Get all endpoint documentation
  getEndpointDocumentation() {
    return {
      authentication: {
        'POST /auth/register': {
          description: 'Register a new user account',
          authentication: false,
          parameters: {
            body: {
              email: { type: 'string', required: true, description: 'Valid email address' },
              password: { type: 'string', required: true, description: 'Minimum 6 characters' },
              firstName: { type: 'string', required: true, description: 'User first name' },
              lastName: { type: 'string', required: true, description: 'User last name' }
            }
          },
          responses: {
            201: { description: 'User registered successfully', example: { success: true, data: { user: {}, token: 'jwt_token' } } },
            400: { description: 'Validation error or user already exists' }
          }
        },
        'POST /auth/login': {
          description: 'Login with email and password',
          authentication: false,
          parameters: {
            body: {
              email: { type: 'string', required: true },
              password: { type: 'string', required: true }
            }
          },
          responses: {
            200: { description: 'Login successful', example: { success: true, data: { user: {}, token: 'jwt_token' } } },
            401: { description: 'Invalid credentials' }
          }
        },
        'POST /auth/logout': {
          description: 'Logout user and set offline status',
          authentication: true,
          responses: {
            200: { description: 'Logout successful' }
          }
        },
        'POST /auth/refresh': {
          description: 'Refresh JWT token',
          authentication: false,
          parameters: {
            body: {
              refreshToken: { type: 'string', required: true }
            }
          }
        }
      },
      courses: {
        'GET /courses': {
          description: 'Get all published courses with filtering and pagination',
          authentication: false,
          parameters: {
            query: {
              page: { type: 'number', default: 1, description: 'Page number for pagination' },
              limit: { type: 'number', default: 12, description: 'Number of courses per page' },
              category: { type: 'string', description: 'Filter by course category' },
              difficulty: { type: 'string', enum: ['beginner', 'intermediate', 'advanced'] },
              search: { type: 'string', description: 'Search in course titles and descriptions' },
              sort: { type: 'string', enum: ['newest', 'oldest', 'popular', 'rating'], default: 'newest' }
            }
          },
          responses: {
            200: { description: 'Courses retrieved successfully' }
          }
        },
        'GET /courses/:id': {
          description: 'Get single course details',
          authentication: false,
          parameters: {
            path: {
              id: { type: 'string', required: true, description: 'Course ID' }
            }
          },
          responses: {
            200: { description: 'Course details retrieved' },
            404: { description: 'Course not found' }
          }
        },
        'POST /courses/:id/enroll': {
          description: 'Enroll in a course',
          authentication: true,
          parameters: {
            path: {
              id: { type: 'string', required: true, description: 'Course ID' }
            }
          },
          responses: {
            200: { description: 'Enrollment successful' },
            400: { description: 'Already enrolled or course not available' }
          }
        },
        'POST /courses/:id/modules/:moduleId/complete': {
          description: 'Mark a module as completed',
          authentication: true,
          parameters: {
            path: {
              id: { type: 'string', required: true, description: 'Course ID' },
              moduleId: { type: 'string', required: true, description: 'Module ID' }
            },
            body: {
              score: { type: 'number', description: 'Optional completion score' }
            }
          }
        }
      },
      media: {
        'POST /media/upload/image': {
          description: 'Upload an image file',
          authentication: true,
          parameters: {
            formData: {
              image: { type: 'file', required: true, description: 'Image file (JPEG, PNG, GIF, WebP)' }
            }
          },
          responses: {
            200: { description: 'Image uploaded successfully' },
            400: { description: 'Invalid file type or size' }
          }
        },
        'POST /media/upload/video': {
          description: 'Upload a video file',
          authentication: true,
          parameters: {
            formData: {
              video: { type: 'file', required: true, description: 'Video file (MP4, WebM, OGG)' }
            }
          }
        }
      },
      youtube: {
        'GET /youtube/search': {
          description: 'Search YouTube videos',
          authentication: true,
          parameters: {
            query: {
              q: { type: 'string', required: true, description: 'Search query' },
              maxResults: { type: 'number', default: 10, description: 'Maximum results to return' },
              order: { type: 'string', enum: ['relevance', 'date', 'rating', 'viewCount'], default: 'relevance' }
            }
          }
        },
        'GET /youtube/educational': {
          description: 'Get educational videos by topic',
          authentication: true,
          parameters: {
            query: {
              topic: { type: 'string', required: true, description: 'Educational topic' }
            }
          }
        }
      },
      analytics: {
        'GET /analytics/online-users': {
          description: 'Get count of online users (Admin only)',
          authentication: true,
          authorization: 'admin',
          responses: {
            200: { description: 'Online user count retrieved' }
          }
        },
        'GET /analytics/user-stats': {
          description: 'Get comprehensive user statistics (Admin only)',
          authentication: true,
          authorization: 'admin'
        },
        'PUT /analytics/activity': {
          description: 'Update user activity (heartbeat)',
          authentication: true
        }
      },
      notifications: {
        'POST /notifications/register-token': {
          description: 'Register FCM token for push notifications',
          authentication: true,
          parameters: {
            body: {
              fcmToken: { type: 'string', required: true, description: 'Firebase Cloud Messaging token' }
            }
          }
        },
        'POST /notifications/test': {
          description: 'Send test push notification to current user',
          authentication: true
        },
        'POST /notifications/broadcast': {
          description: 'Broadcast notification to all users (Admin only)',
          authentication: true,
          authorization: 'admin',
          parameters: {
            body: {
              title: { type: 'string', required: true },
              body: { type: 'string', required: true },
              data: { type: 'object', description: 'Additional notification data' }
            }
          }
        }
      }
    };
  }

  // Get model documentation
  getModelDocumentation() {
    return {
      User: {
        description: 'User account information',
        properties: {
          _id: { type: 'ObjectId', description: 'Unique user identifier' },
          email: { type: 'string', description: 'User email address' },
          firstName: { type: 'string', description: 'User first name' },
          lastName: { type: 'string', description: 'User last name' },
          role: { type: 'string', enum: ['student', 'teacher', 'admin'], description: 'User role' },
          isEmailVerified: { type: 'boolean', description: 'Email verification status' },
          isOnline: { type: 'boolean', description: 'Current online status' },
          lastLogin: { type: 'Date', description: 'Last login timestamp' },
          learningStyle: {
            type: 'object',
            description: 'VARK learning style preferences',
            properties: {
              visual: { type: 'number', description: 'Visual learning percentage (0-100)' },
              auditory: { type: 'number', description: 'Auditory learning percentage (0-100)' },
              reading: { type: 'number', description: 'Reading learning percentage (0-100)' },
              kinesthetic: { type: 'number', description: 'Kinesthetic learning percentage (0-100)' }
            }
          }
        }
      },
      Course: {
        description: 'Course information and content',
        properties: {
          _id: { type: 'ObjectId', description: 'Unique course identifier' },
          title: { type: 'string', description: 'Course title' },
          description: { type: 'string', description: 'Course description' },
          category: { type: 'string', description: 'Course category' },
          difficulty: { type: 'string', enum: ['beginner', 'intermediate', 'advanced'] },
          modules: { type: 'array', description: 'Array of course modules' },
          isPublished: { type: 'boolean', description: 'Publication status' },
          isFree: { type: 'boolean', description: 'Free or paid course' },
          price: { type: 'number', description: 'Course price (if not free)' },
          averageRating: { type: 'number', description: 'Average user rating (0-5)' },
          totalRatings: { type: 'number', description: 'Total number of ratings' },
          enrollmentCount: { type: 'number', description: 'Number of enrolled students' },
          totalDuration: { type: 'number', description: 'Total course duration in minutes' },
          totalModules: { type: 'number', description: 'Number of modules in course' }
        }
      },
      Module: {
        description: 'Course module content',
        properties: {
          _id: { type: 'ObjectId', description: 'Unique module identifier' },
          title: { type: 'string', description: 'Module title' },
          description: { type: 'string', description: 'Module description' },
          content: { type: 'string', description: 'Module content (text, HTML, or markdown)' },
          contentType: { type: 'string', enum: ['text', 'video', 'audio', 'interactive', 'quiz'] },
          duration: { type: 'number', description: 'Module duration in minutes' },
          order: { type: 'number', description: 'Module order in course' }
        }
      }
    };
  }

  // Get example requests and responses
  getExamples() {
    return {
      authentication: {
        register: {
          request: {
            method: 'POST',
            url: '/api/auth/register',
            body: {
              email: 'student@bytebrain.com',
              password: 'securepassword123',
              firstName: 'John',
              lastName: 'Doe'
            }
          },
          response: {
            success: true,
            message: 'User registered successfully',
            data: {
              user: {
                _id: '507f1f77bcf86cd799439011',
                email: 'student@bytebrain.com',
                firstName: 'John',
                lastName: 'Doe',
                role: 'student',
                isEmailVerified: false
              },
              token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
              refreshToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
            }
          }
        },
        login: {
          request: {
            method: 'POST',
            url: '/api/auth/login',
            body: {
              email: 'student@bytebrain.com',
              password: 'securepassword123'
            }
          },
          response: {
            success: true,
            message: 'Login successful',
            data: {
              user: {
                _id: '507f1f77bcf86cd799439011',
                email: 'student@bytebrain.com',
                firstName: 'John',
                lastName: 'Doe',
                role: 'student'
              },
              token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
            }
          }
        }
      },
      courses: {
        getCourses: {
          request: {
            method: 'GET',
            url: '/api/courses?page=1&limit=5&category=programming&difficulty=beginner'
          },
          response: {
            success: true,
            data: {
              courses: [
                {
                  _id: '507f1f77bcf86cd799439012',
                  title: 'Introduction to JavaScript',
                  description: 'Learn JavaScript fundamentals...',
                  category: 'programming',
                  difficulty: 'beginner',
                  isFree: true,
                  averageRating: 4.5,
                  enrollmentCount: 150,
                  totalModules: 8,
                  formattedDuration: '4h 30m'
                }
              ],
              pagination: {
                currentPage: 1,
                totalPages: 3,
                totalCourses: 15,
                hasNext: true,
                hasPrev: false
              }
            }
          }
        }
      }
    };
  }

  // Get error codes documentation
  getErrorCodes() {
    return {
      400: {
        name: 'Bad Request',
        description: 'Invalid request parameters or validation failed',
        example: {
          success: false,
          message: 'Validation failed',
          errors: [
            {
              field: 'email',
              message: 'Please provide a valid email'
            }
          ]
        }
      },
      401: {
        name: 'Unauthorized',
        description: 'Authentication required or invalid token',
        example: {
          success: false,
          message: 'No token provided, authorization denied'
        }
      },
      403: {
        name: 'Forbidden',
        description: 'Insufficient permissions for this action',
        example: {
          success: false,
          message: 'Admin access required'
        }
      },
      404: {
        name: 'Not Found',
        description: 'Requested resource not found',
        example: {
          success: false,
          message: 'Course not found'
        }
      },
      429: {
        name: 'Too Many Requests',
        description: 'Rate limit exceeded',
        example: {
          success: false,
          message: 'Too many requests, please try again later'
        }
      },
      500: {
        name: 'Internal Server Error',
        description: 'Server error occurred',
        example: {
          success: false,
          message: 'Server error'
        }
      }
    };
  }

  // Generate HTML documentation
  generateHTML() {
    const docs = this.generateDocumentation();
    
    return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${docs.title}</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2196F3; border-bottom: 3px solid #2196F3; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 40px; }
        h3 { color: #666; }
        .endpoint { background: #f8f9fa; padding: 20px; margin: 20px 0; border-radius: 6px; border-left: 4px solid #2196F3; }
        .method { display: inline-block; padding: 4px 8px; border-radius: 4px; font-weight: bold; color: white; margin-right: 10px; }
        .get { background: #4CAF50; }
        .post { background: #2196F3; }
        .put { background: #FF9800; }
        .delete { background: #f44336; }
        .auth-required { color: #f44336; font-size: 12px; }
        .auth-optional { color: #4CAF50; font-size: 12px; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 4px; overflow-x: auto; }
        code { background: #f4f4f4; padding: 2px 4px; border-radius: 3px; }
        .toc { background: #e3f2fd; padding: 20px; border-radius: 6px; margin-bottom: 30px; }
        .toc ul { margin: 0; }
        .toc a { text-decoration: none; color: #1976d2; }
        .toc a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>${docs.title}</h1>
        <p><strong>Version:</strong> ${docs.version}</p>
        <p><strong>Base URL:</strong> <code>${docs.baseUrl}</code></p>
        <p>${docs.description}</p>
        
        <div class="toc">
            <h3>📋 Table of Contents</h3>
            <ul>
                <li><a href="#authentication">Authentication</a></li>
                <li><a href="#endpoints">API Endpoints</a></li>
                <li><a href="#models">Data Models</a></li>
                <li><a href="#examples">Examples</a></li>
                <li><a href="#errors">Error Codes</a></li>
            </ul>
        </div>

        <h2 id="authentication">🔐 Authentication</h2>
        <p><strong>Type:</strong> ${docs.authentication.type}</p>
        <p><strong>Header:</strong> <code>${docs.authentication.header}</code></p>
        <p>${docs.authentication.description}</p>

        <h2 id="endpoints">🚀 API Endpoints</h2>
        ${this.generateEndpointHTML(docs.endpoints)}

        <h2 id="models">📊 Data Models</h2>
        ${this.generateModelHTML(docs.models)}

        <h2 id="examples">💡 Examples</h2>
        ${this.generateExampleHTML(docs.examples)}

        <h2 id="errors">❌ Error Codes</h2>
        ${this.generateErrorHTML(docs.errorCodes)}
    </div>
</body>
</html>`;
  }

  generateEndpointHTML(endpoints) {
    let html = '';
    
    Object.keys(endpoints).forEach(category => {
      html += `<h3>${category.charAt(0).toUpperCase() + category.slice(1)}</h3>`;
      
      Object.keys(endpoints[category]).forEach(endpoint => {
        const details = endpoints[category][endpoint];
        const [method, path] = endpoint.split(' ');
        
        html += `
        <div class="endpoint">
            <h4>
                <span class="method ${method.toLowerCase()}">${method}</span>
                <code>${path}</code>
                ${details.authentication ? '<span class="auth-required">🔒 Auth Required</span>' : '<span class="auth-optional">🔓 Public</span>'}
                ${details.authorization ? `<span class="auth-required">👑 ${details.authorization}</span>` : ''}
            </h4>
            <p>${details.description}</p>
            ${details.parameters ? this.generateParameterHTML(details.parameters) : ''}
            ${details.responses ? this.generateResponseHTML(details.responses) : ''}
        </div>`;
      });
    });
    
    return html;
  }

  generateParameterHTML(parameters) {
    let html = '<h5>Parameters:</h5>';
    
    Object.keys(parameters).forEach(type => {
      html += `<p><strong>${type.charAt(0).toUpperCase() + type.slice(1)}:</strong></p><ul>`;
      
      Object.keys(parameters[type]).forEach(param => {
        const details = parameters[type][param];
        html += `<li><code>${param}</code> (${details.type}) ${details.required ? '<strong>required</strong>' : 'optional'} - ${details.description || ''}</li>`;
      });
      
      html += '</ul>';
    });
    
    return html;
  }

  generateResponseHTML(responses) {
    let html = '<h5>Responses:</h5><ul>';
    
    Object.keys(responses).forEach(code => {
      const response = responses[code];
      html += `<li><strong>${code}:</strong> ${response.description}</li>`;
    });
    
    html += '</ul>';
    return html;
  }

  generateModelHTML(models) {
    let html = '';
    
    Object.keys(models).forEach(modelName => {
      const model = models[modelName];
      html += `<h3>${modelName}</h3><p>${model.description}</p><ul>`;
      
      Object.keys(model.properties).forEach(prop => {
        const details = model.properties[prop];
        html += `<li><code>${prop}</code> (${details.type}) - ${details.description}</li>`;
      });
      
      html += '</ul>';
    });
    
    return html;
  }

  generateExampleHTML(examples) {
    let html = '';
    
    Object.keys(examples).forEach(category => {
      html += `<h3>${category.charAt(0).toUpperCase() + category.slice(1)}</h3>`;
      
      Object.keys(examples[category]).forEach(example => {
        const details = examples[category][example];
        html += `
        <h4>${example}</h4>
        <p><strong>Request:</strong></p>
        <pre><code>${JSON.stringify(details.request, null, 2)}</code></pre>
        <p><strong>Response:</strong></p>
        <pre><code>${JSON.stringify(details.response, null, 2)}</code></pre>`;
      });
    });
    
    return html;
  }

  generateErrorHTML(errors) {
    let html = '<ul>';
    
    Object.keys(errors).forEach(code => {
      const error = errors[code];
      html += `
      <li>
        <h4>${code} - ${error.name}</h4>
        <p>${error.description}</p>
        <pre><code>${JSON.stringify(error.example, null, 2)}</code></pre>
      </li>`;
    });
    
    html += '</ul>';
    return html;
  }

  // Save documentation to file
  saveToFile() {
    const html = this.generateHTML();
    const filePath = path.join(__dirname, 'api-documentation.html');
    
    fs.writeFileSync(filePath, html);
    console.log(`📚 API documentation saved to: ${filePath}`);
    
    return filePath;
  }
}

module.exports = APIDocumentationGenerator;