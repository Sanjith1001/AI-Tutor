# ByteBrain Python Chatbot

A comprehensive Python-based chatbot system for the ByteBrain educational platform with two implementations:

1. **Advanced Chatbot** (`chatbot_server.py`) - Full-featured with OpenAI integration
2. **Simple Chatbot** (`simple_chatbot.py`) - Lightweight, no external dependencies

## Features

### Advanced Chatbot
- 🤖 OpenAI GPT integration for intelligent responses
- 📊 Sentiment analysis using NLTK
- 👤 User context and conversation history
- 🎯 Personalized learning preferences
- 📚 Educational intent detection
- 🔄 RESTful API with Flask

### Simple Chatbot
- 💬 Pattern-based responses
- 📖 Educational topic coverage
- 💡 Learning tips and suggestions
- 📝 Conversation history
- 🌐 Built-in HTTP server
- 🚀 Zero external dependencies

## Quick Start

### Option 1: Simple Chatbot (Recommended for testing)

```bash
# Navigate to the chatbot directory
cd backend/python_chatbot

# Run as command-line interface
python simple_chatbot.py

# Or run as HTTP server
python simple_chatbot.py server 5002
```

### Option 2: Advanced Chatbot

```bash
# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your OpenAI API key

# Run the server
python chatbot_server.py
```

## API Endpoints

### Simple Chatbot (Port 5002)
- `GET /health` - Health check
- `POST /chat` - Send message
- `GET /history/{user_id}` - Get chat history

### Advanced Chatbot (Port 5001)
- `GET /health` - Health check
- `POST /chat` - Send message with AI processing
- `GET /chat/history/{user_id}` - Get chat history
- `GET/POST /chat/preferences/{user_id}` - User preferences
- `DELETE /chat/clear/{user_id}` - Clear history
- `GET /chat/topics` - Available learning topics

## Usage Examples

### Send a Chat Message

```bash
curl -X POST http://localhost:5002/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Help me understand algebra",
    "user_id": "student123"
  }'
```

### Response Format

```json
{
  "success": true,
  "data": {
    "response": "Math is fascinating! What specific area would you like to explore?",
    "suggestions": [
      "Show me a specific problem",
      "Explain a math concept",
      "Give me practice questions"
    ],
    "timestamp": "2024-01-15T10:30:00"
  }
}
```

## Integration with Flutter App

Update your Flutter app to use the Python chatbot:

```dart
// In your AI chatbot service
class PythonChatbotService {
  static const String baseUrl = 'http://localhost:5002'; // or 5001 for advanced
  
  static Future<Map<String, dynamic>> sendMessage(String message, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': message,
        'user_id': userId,
      }),
    );
    
    return json.decode(response.body);
  }
}
```

## Educational Topics Covered

- 📐 Mathematics (Algebra, Geometry, Calculus)
- 🔬 Science (Physics, Chemistry, Biology)
- 💻 Programming (Python, JavaScript, General Coding)
- 📚 History and Literature
- 🎨 Arts and Creative Subjects
- 🌍 General Knowledge and Learning Tips

## Configuration

### Environment Variables (.env)

```env
# For Advanced Chatbot
OPENAI_API_KEY=your_openai_api_key_here
FLASK_DEBUG=False
PYTHON_CHATBOT_PORT=5001

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## Development

### Running Tests

```bash
# Test the simple chatbot
python -c "
from simple_chatbot import SimpleChatbot
bot = SimpleChatbot()
print(bot.get_response('Hello, help me with math'))
"
```

### Adding New Response Patterns

Edit the `responses` dictionary in `simple_chatbot.py`:

```python
self.responses = {
    "new_pattern|alternative": [
        "Response option 1",
        "Response option 2"
    ]
}
```

## Deployment

### Docker Support (Optional)

```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 5001

CMD ["python", "chatbot_server.py"]
```

### Production Considerations

1. Use a production WSGI server (gunicorn)
2. Set up proper logging
3. Implement rate limiting
4. Add authentication if needed
5. Use environment-specific configurations

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the port number
2. **OpenAI API errors**: Check your API key and quota
3. **NLTK download issues**: Run `python -c "import nltk; nltk.download('vader_lexicon')"`
4. **CORS errors**: Ensure proper headers are set

### Logs

Check the console output for detailed error messages and request logs.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## License

This chatbot is part of the ByteBrain educational platform.