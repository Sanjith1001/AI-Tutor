import os
from flask import Flask, request, jsonify
from groq import Groq
from dotenv import load_dotenv
from flask_cors import CORS
from datetime import datetime
import logging

# Load env variables
load_dotenv()
api_key = os.getenv("GROQ_API_KEY")

# Flask app
app = Flask(__name__)
CORS(app)  # enable frontend to talk to backend

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Groq client
client = Groq(api_key=api_key) if api_key else None

# Store conversation history (in production, use a database)
conversation_history = {}

@app.route("/", methods=["GET"])
def root():
    """Root endpoint"""
    return jsonify({
        "message": "ByteBrain Groq Chatbot API",
        "endpoints": ["/health", "/chat", "/chat/clear/<user_id>", "/chat/history/<user_id>"]
    })

@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint for Flutter app"""
    return jsonify({
        "status": "healthy",
        "service": "ByteBrain Groq Chatbot",
        "model": "llama-3.1-8b-instant",
        "groq_configured": api_key is not None,
        "timestamp": datetime.now().isoformat()
    })

@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    user_input = data.get("message", "")
    user_id = data.get("user_id", "anonymous")

    if not user_input:
        return jsonify({"error": "No message provided"}), 400
    
    # If no API key is configured, return a clear error for local testing
    if not api_key or not client:
        logger.warning("GROQ_API_KEY not set")
        return jsonify({
            "success": False,
            "error": "GROQ_API_KEY not configured",
            "reply": "Sorry, the AI service is not configured. Please set up your GROQ_API_KEY in the .env file."
        }), 500

    try:
        # Get or create conversation history for user
        if user_id not in conversation_history:
            conversation_history[user_id] = []
        
        # Educational system prompt
        educational_context = """You are ByteBrain AI, an educational assistant designed to help students learn effectively. 
        
Guidelines:
- Provide clear, educational responses
- Use examples and analogies when explaining concepts
- Encourage learning and curiosity
- Break down complex topics into digestible parts
- Offer study tips and learning strategies when relevant
- Be supportive and motivating
- Keep responses concise but informative (max 250 words)
- Focus on subjects like Math, Science, Programming, History, Literature, and general learning skills

Always aim to help students understand concepts rather than just providing answers."""
        
        # Build conversation context
        messages = [{"role": "system", "content": educational_context}]
        
        # Add recent conversation history (last 6 messages for context)
        recent_history = conversation_history[user_id][-6:]
        for msg in recent_history:
            messages.append(msg)
        
        # Add current user message
        messages.append({"role": "user", "content": user_input})
        
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=messages,
            max_tokens=400,
            temperature=0.7
        )

        reply = response.choices[0].message.content
        
        # Store conversation in history
        conversation_history[user_id].append({"role": "user", "content": user_input})
        conversation_history[user_id].append({"role": "assistant", "content": reply})
        
        # Keep history manageable (last 20 messages)
        if len(conversation_history[user_id]) > 20:
            conversation_history[user_id] = conversation_history[user_id][-20:]
        
        # Generate contextual suggestions
        suggestions = generate_suggestions(user_input, reply)
        
        return jsonify({
            "success": True,
            "reply": reply,
            "suggestions": suggestions,
            "timestamp": datetime.now().isoformat(),
            "model": "llama-3.1-8b-instant",
            "user_id": user_id
        })
        
    except Exception as e:
        # Log full exception server-side but return a friendly JSON error to clients.
        logger.exception("Upstream API error while calling Groq")
        return jsonify({
            "success": False,
            "error": "Upstream API error", 
            "reply": "Sorry, I'm having trouble processing your request right now. Please try again.",
            "details": str(e)
        }), 502

def generate_suggestions(user_input, ai_reply):
    """Generate contextual suggestions based on the conversation"""
    user_lower = user_input.lower()
    
    # Math-related suggestions
    if any(word in user_lower for word in ['math', 'algebra', 'geometry', 'calculus', 'equation', 'solve']):
        return [
            "Show me step-by-step solution",
            "Give me a similar example",
            "Explain the concept behind this",
            "Create a practice problem"
        ]
    
    # Science-related suggestions
    elif any(word in user_lower for word in ['science', 'physics', 'chemistry', 'biology', 'experiment']):
        return [
            "Explain with real-world examples",
            "Show me the scientific method",
            "What are the key principles?",
            "Give me lab experiment ideas"
        ]
    
    # Programming-related suggestions
    elif any(word in user_lower for word in ['code', 'programming', 'python', 'javascript', 'algorithm']):
        return [
            "Show me code examples",
            "Explain the logic step by step",
            "What are best practices?",
            "Give me coding exercises"
        ]
    
    # Study-related suggestions
    elif any(word in user_lower for word in ['study', 'learn', 'exam', 'test', 'homework']):
        return [
            "Give me study tips",
            "Create a study plan",
            "How to remember this better?",
            "Quiz me on this topic"
        ]
    
    # History-related suggestions
    elif any(word in user_lower for word in ['history', 'historical', 'war', 'ancient', 'civilization']):
        return [
            "Tell me more about this period",
            "What were the causes?",
            "How did this impact society?",
            "Give me a timeline"
        ]
    
    # General suggestions
    else:
        return [
            "Tell me more about this",
            "Give me examples",
            "Explain it differently",
            "What should I learn next?"
        ]

@app.route("/chat/clear/<user_id>", methods=["DELETE"])
def clear_chat_history(user_id):
    """Clear chat history for a specific user"""
    if user_id in conversation_history:
        conversation_history[user_id] = []
    
    return jsonify({
        "success": True,
        "message": "Chat history cleared successfully"
    })

@app.route("/chat/history/<user_id>", methods=["GET"])
def get_chat_history(user_id):
    """Get chat history for a specific user"""
    history = conversation_history.get(user_id, [])
    return jsonify({
        "success": True,
        "data": {
            "history": history,
            "count": len(history)
        }
    })

@app.route("/chat/topics", methods=["GET"])
def get_learning_topics():
    """Get available learning topics"""
    topics = [
        "Mathematics", "Science", "Programming", "History", 
        "Literature", "Study Skills", "Physics", "Chemistry", 
        "Biology", "Computer Science", "Languages"
    ]
    return jsonify({
        "success": True,
        "data": {
            "topics": topics,
            "count": len(topics)
        }
    })

if __name__ == "__main__":
    print("🤖 Starting ByteBrain Groq Chatbot Server...")
    print("📡 Server will be available at: http://localhost:5000")
    print("🔍 Health check: http://localhost:5000/health")
    print("💬 Chat endpoint: http://localhost:5000/chat")
    print("🔑 Groq API configured:", "✅ Yes" if api_key else "❌ No")
    print("=" * 50)
    
    app.run(host="0.0.0.0", port=5000, debug=True)