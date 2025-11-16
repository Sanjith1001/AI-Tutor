# Python Chatbot Integration Guide

## 🚀 Quick Start

### 1. Start the Python Chatbot Server

**Option A: Using the startup script (Windows)**
```bash
# Double-click or run from command line
start_python_chatbot.bat
```

**Option B: Manual startup**
```bash
cd backend/python_chatbot
python simple_chatbot.py server 5002
```

### 2. Open the Flutter App

1. Run your Flutter app as usual
2. Click the **AI Assistant** floating action button on the home screen
3. Start chatting with the Python-powered AI assistant!

## 🤖 How It Works

### Architecture
```
Flutter App (Dart) ←→ HTTP API ←→ Python Chatbot Server
```

### Features
- **Smart Responses**: Pattern-based educational responses
- **Learning Topics**: Math, Science, Programming, History, and more
- **Suggestions**: Contextual quick-reply suggestions
- **Conversation History**: Maintains chat context
- **Dual Mode**: Simple chatbot (no dependencies) + Advanced chatbot (OpenAI)

### API Endpoints
- `POST /chat` - Send messages
- `GET /health` - Server status
- `GET /history/{user_id}` - Chat history

## 🔧 Configuration

### Python Chatbot Ports
- **Simple Chatbot**: `http://localhost:5002`
- **Advanced Chatbot**: `http://localhost:5001` (requires OpenAI API key)

### Flutter Service Configuration
The `PythonChatbotService` automatically:
1. Tries advanced chatbot first (if available)
2. Falls back to simple chatbot
3. Provides error handling and offline messages

## 📱 UI Features

### Chat Interface
- **Smart Icons**: Different icons for simple vs advanced responses
- **Quick Suggestions**: Tap suggestion chips to send messages
- **Server Status**: Shows connection status in app bar
- **Typing Indicators**: Animated typing feedback

### Message Types
- **User Messages**: Blue bubbles on the right
- **AI Responses**: White bubbles on the left with suggestions
- **Error Messages**: Red-tinted for connection issues

## 🛠️ Troubleshooting

### Common Issues

**1. "AI Assistant - Offline" in app bar**
- Make sure Python chatbot server is running
- Check if port 5002 is available
- Verify Python is installed

**2. Connection errors in chat**
- Restart the Python server
- Check firewall settings
- Ensure no other app is using port 5002

**3. Python server won't start**
- Install Python from https://python.org
- Make sure Python is in your system PATH
- Try running: `python --version`

### Testing the Connection

**Test the server directly:**
```bash
# Check if server is running
curl http://localhost:5002/health

# Send a test message
curl -X POST http://localhost:5002/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "user_id": "test"}'
```

## 🎯 Educational Topics

The chatbot can help with:
- **Mathematics**: Algebra, geometry, calculus
- **Science**: Physics, chemistry, biology
- **Programming**: Python, JavaScript, general coding
- **History**: Historical events and periods
- **Study Tips**: Learning strategies and techniques
- **General Learning**: Explanations and examples

## 🔄 Advanced Features (Optional)

### OpenAI Integration
1. Get an OpenAI API key
2. Create `.env` file in `backend/python_chatbot/`
3. Add: `OPENAI_API_KEY=your_key_here`
4. Run: `python chatbot_server.py`
5. Advanced chatbot will be available on port 5001

### Features with OpenAI
- Natural language understanding
- Contextual responses
- Sentiment analysis
- Personalized learning recommendations

## 📊 Monitoring

### Server Logs
The Python server shows:
- Incoming requests
- Response times
- Error messages
- Connection status

### Flutter App Logs
Check the Flutter console for:
- API call results
- Connection status changes
- Error handling

## 🚀 Next Steps

1. **Customize Responses**: Edit patterns in `simple_chatbot.py`
2. **Add Topics**: Extend the learning topics list
3. **Enhance UI**: Customize chat bubble styles
4. **Add Features**: File uploads, voice messages, etc.
5. **Deploy**: Host the Python server for production use

---

**Need Help?** Check the logs in both Flutter console and Python server terminal for detailed error messages.