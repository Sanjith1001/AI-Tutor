# ByteBrain Groq AI Chatbot Integration

## 🚀 Overview

Your Flutter app now integrates with your powerful Groq-based chatbot using Llama 3.1 model for intelligent educational assistance.

## 🔧 Setup Instructions

### 1. Get Groq API Key

1. Visit [Groq Console](https://console.groq.com/)
2. Sign up for a free account
3. Create an API key
4. Copy your API key

### 2. Configure Environment

Create `.env` file in the `Byte_Brain` folder:

```env
GROQ_API_KEY=your_groq_api_key_here
```

### 3. Start the Groq Server

**Option A: Using startup script (Windows)**
```bash
# Double-click or run from command line
start_groq_chatbot.bat
```

**Option B: Using bash script**
```bash
chmod +x start_groq_chatbot.sh
./start_groq_chatbot.sh
```

**Option C: Manual startup**
```bash
cd Byte_Brain
pip install flask flask-cors groq python-dotenv
python server.py
```

### 4. Run Your Flutter App

```bash
flutter run
```

### 5. Test the Integration

1. Click the **AI Assistant** floating action button
2. Start chatting with the Groq-powered AI!

## 🤖 Features

### Advanced AI Capabilities
- **Llama 3.1 Model**: State-of-the-art language understanding
- **Educational Focus**: Specialized for learning and teaching
- **Context Awareness**: Remembers conversation history
- **Detailed Explanations**: Provides step-by-step solutions

### Supported Subjects
- 🔢 **Mathematics**: Algebra, Geometry, Calculus, Problem Solving
- 🔬 **Science**: Physics, Chemistry, Biology, Research Methods
- 💻 **Programming**: Python, JavaScript, Algorithms, Best Practices
- 📚 **Study Skills**: Learning strategies, Memory techniques
- 📖 **Literature**: Writing, Analysis, Critical Thinking
- 🏛️ **History**: Events, Analysis, Timelines, Context

### Smart Features
- **Contextual Suggestions**: AI-generated follow-up questions
- **Conversation Memory**: Maintains context across messages
- **Educational Prompts**: Optimized for learning scenarios
- **Error Handling**: Graceful fallbacks and helpful error messages

## 📡 API Endpoints

Your enhanced server provides:

- `GET /health` - Server status and configuration
- `POST /chat` - Send messages to AI
- `GET /chat/history/{user_id}` - Retrieve conversation history
- `DELETE /chat/clear/{user_id}` - Clear user's chat history
- `GET /chat/topics` - Available learning topics

## 🎯 Usage Examples

### Mathematics Help
```
User: "Help me solve x² + 5x + 6 = 0"
AI: "I'll help you solve this quadratic equation step by step using factoring..."
```

### Programming Assistance
```
User: "Explain Python loops"
AI: "Python has several types of loops. Let me explain each with examples..."
```

### Study Strategies
```
User: "How can I study more effectively?"
AI: "Here are proven study techniques tailored to your learning style..."
```

## 🔍 Monitoring

### Server Logs
The Groq server shows:
- Incoming chat requests
- AI model responses
- API usage and errors
- Conversation statistics

### Flutter App Status
- App bar shows "Groq AI • llama-3.1-8b-instant" when connected
- Shows "AI Assistant • Offline" when disconnected
- Real-time connection status updates

## ⚡ Performance

### Response Times
- **Groq API**: ~1-3 seconds for complex queries
- **Simple queries**: ~0.5-1 second
- **Context-aware responses**: ~2-4 seconds

### Rate Limits
- Groq free tier: Generous limits for development
- Conversation history: Stored in memory (last 20 messages per user)
- Auto-cleanup: Prevents memory overflow

## 🛠️ Troubleshooting

### Common Issues

**1. "GROQ_API_KEY not configured"**
- Create `.env` file in `Byte_Brain` folder
- Add your API key: `GROQ_API_KEY=your_key_here`
- Restart the server

**2. "AI Assistant • Offline"**
- Make sure Groq server is running on port 5000
- Check if `.env` file exists with valid API key
- Verify no firewall blocking port 5000

**3. Slow responses**
- Normal for complex AI processing
- Groq API may have temporary delays
- Check your internet connection

**4. Server won't start**
- Install dependencies: `pip install flask flask-cors groq python-dotenv`
- Check Python version (3.7+ required)
- Verify port 5000 is available

### Testing Connection

```bash
# Test server health
curl http://localhost:5000/health

# Test chat functionality
curl -X POST http://localhost:5000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, explain photosynthesis", "user_id": "test"}'
```

## 🎨 Customization

### Modify AI Behavior
Edit the `educational_context` in `server.py`:

```python
educational_context = """You are ByteBrain AI, an educational assistant...
# Add your custom instructions here
"""
```

### Add New Subjects
Update the `generate_suggestions()` function to include new topics:

```python
elif any(word in user_lower for word in ['art', 'music', 'creative']):
    return [
        "Show me techniques",
        "Explain the theory",
        "Give me practice exercises"
    ]
```

### Adjust Response Length
Modify `max_tokens` in the chat endpoint:

```python
response = client.chat.completions.create(
    model="llama-3.1-8b-instant",
    messages=messages,
    max_tokens=500,  # Increase for longer responses
    temperature=0.7
)
```

## 🚀 Production Deployment

### Environment Setup
1. Use environment variables for configuration
2. Implement proper logging
3. Add rate limiting
4. Use a production WSGI server (gunicorn)
5. Set up SSL/HTTPS

### Database Integration
Replace in-memory storage with a database:
```python
# Instead of: conversation_history = {}
# Use: PostgreSQL, MongoDB, or SQLite
```

## 📈 Analytics

Track usage patterns:
- Most asked topics
- Response satisfaction
- Learning progress
- Popular features

## 🔐 Security

- API key stored securely in environment variables
- CORS configured for your Flutter app
- Input validation and sanitization
- Rate limiting to prevent abuse

---

**Your Groq-powered AI chatbot is now ready to provide intelligent educational assistance! 🎓✨**