from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
import openai
import json
import time
import random
from datetime import datetime
import nltk
from nltk.sentiment import SentimentIntensityAnalyzer
import logging

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize OpenAI client
openai.api_key = os.getenv('OPENAI_API_KEY')

# Initialize NLTK components
try:
    nltk.download('vader_lexicon', quiet=True)
    sia = SentimentIntensityAnalyzer()
except:
    logger.warning("NLTK sentiment analyzer not available")
    sia = None

class ByteBrainChatbot:
    def __init__(self):
        self.conversation_history = {}
        self.user_preferences = {}
        self.learning_topics = [
            "Mathematics", "Science", "History", "Literature", 
            "Programming", "Art", "Music", "Languages"
        ]
        
    def get_user_context(self, user_id):
        """Get or create user context"""
        if user_id not in self.conversation_history:
            self.conversation_history[user_id] = []
            self.user_preferences[user_id] = {
                "learning_style": "visual",
                "difficulty_level": "intermediate",
                "interests": []
            }
        return self.conversation_history[user_id], self.user_preferences[user_id]
    
    def analyze_sentiment(self, text):
        """Analyze sentiment of user message"""
        if sia:
            scores = sia.polarity_scores(text)
            return {
                "positive": scores['pos'],
                "negative": scores['neg'],
                "neutral": scores['neu'],
                "compound": scores['compound']
            }
        return {"compound": 0.0}
    
    def generate_educational_response(self, message, user_context, preferences):
        """Generate educational response based on user message"""
        
        # Educational prompts based on learning topics
        educational_prompts = {
            "explain": "I'll explain this concept step by step with examples.",
            "quiz": "Let me create a quick quiz to test your understanding.",
            "example": "Here are some practical examples to illustrate this concept.",
            "summary": "Let me summarize the key points for you.",
            "practice": "Here are some practice exercises you can try."
        }
        
        # Detect learning intent
        message_lower = message.lower()
        intent = "general"
        
        for key in educational_prompts:
            if key in message_lower:
                intent = key
                break
        
        # Generate contextual response
        if intent in educational_prompts:
            return {
                "response": educational_prompts[intent],
                "intent": intent,
                "suggestions": self.get_learning_suggestions(intent)
            }
        
        return {
            "response": "I'm here to help you learn! What topic would you like to explore?",
            "intent": "general",
            "suggestions": ["Ask me to explain a concept", "Request a quiz", "Get examples"]
        }
    
    def get_learning_suggestions(self, intent):
        """Get learning suggestions based on intent"""
        suggestions = {
            "explain": [
                "Can you give me an example?",
                "Make it simpler please",
                "Show me a diagram",
                "What are the key points?"
            ],
            "quiz": [
                "Make it easier",
                "Give me a hint",
                "Show the answer",
                "Try another question"
            ],
            "example": [
                "Show me more examples",
                "Explain this example",
                "Give me a real-world case",
                "Make it more practical"
            ],
            "general": [
                "Explain a concept",
                "Give me a quiz",
                "Show examples",
                "Summarize a topic"
            ]
        }
        return suggestions.get(intent, suggestions["general"])
    
    def process_message(self, user_id, message):
        """Process user message and generate response"""
        history, preferences = self.get_user_context(user_id)
        
        # Add user message to history
        history.append({
            "role": "user",
            "content": message,
            "timestamp": datetime.now().isoformat()
        })
        
        # Analyze sentiment
        sentiment = self.analyze_sentiment(message)
        
        # Generate response based on context
        if openai.api_key:
            try:
                response = self.generate_openai_response(message, history, preferences)
            except Exception as e:
                logger.error(f"OpenAI API error: {e}")
                response = self.generate_educational_response(message, history, preferences)
        else:
            response = self.generate_educational_response(message, history, preferences)
        
        # Add bot response to history
        history.append({
            "role": "assistant",
            "content": response["response"],
            "timestamp": datetime.now().isoformat(),
            "intent": response.get("intent", "general")
        })
        
        # Keep history manageable (last 20 messages)
        if len(history) > 20:
            history = history[-20:]
            self.conversation_history[user_id] = history
        
        return {
            "response": response["response"],
            "suggestions": response.get("suggestions", []),
            "sentiment": sentiment,
            "intent": response.get("intent", "general"),
            "timestamp": datetime.now().isoformat()
        }
    
    def generate_openai_response(self, message, history, preferences):
        """Generate response using OpenAI API"""
        
        # Create context from history
        context_messages = [
            {
                "role": "system",
                "content": f"""You are ByteBrain AI, an educational chatbot designed to help students learn effectively. 
                
User preferences:
- Learning style: {preferences['learning_style']}
- Difficulty level: {preferences['difficulty_level']}
- Interests: {', '.join(preferences.get('interests', []))}

Guidelines:
1. Provide clear, educational responses
2. Adapt to the user's learning style and level
3. Offer practical examples and explanations
4. Encourage active learning
5. Be supportive and motivating
6. Keep responses concise but informative"""
            }
        ]
        
        # Add recent conversation history
        for msg in history[-6:]:  # Last 6 messages for context
            context_messages.append({
                "role": msg["role"],
                "content": msg["content"]
            })
        
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=context_messages,
            max_tokens=300,
            temperature=0.7
        )
        
        return {
            "response": response.choices[0].message.content,
            "intent": "ai_generated",
            "suggestions": [
                "Tell me more about this",
                "Give me an example",
                "Quiz me on this topic",
                "Explain it differently"
            ]
        }

# Initialize chatbot
chatbot = ByteBrainChatbot()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "ByteBrain Chatbot"})

@app.route('/chat', methods=['POST'])
def chat():
    """Main chat endpoint"""
    try:
        data = request.get_json()
        
        if not data or 'message' not in data:
            return jsonify({"error": "Message is required"}), 400
        
        user_id = data.get('user_id', 'anonymous')
        message = data.get('message', '').strip()
        
        if not message:
            return jsonify({"error": "Message cannot be empty"}), 400
        
        # Process message
        response = chatbot.process_message(user_id, message)
        
        return jsonify({
            "success": True,
            "data": response
        })
        
    except Exception as e:
        logger.error(f"Chat error: {e}")
        return jsonify({
            "success": False,
            "error": "An error occurred while processing your message"
        }), 500

@app.route('/chat/history/<user_id>', methods=['GET'])
def get_chat_history(user_id):
    """Get chat history for a user"""
    try:
        history, _ = chatbot.get_user_context(user_id)
        return jsonify({
            "success": True,
            "data": {
                "history": history,
                "count": len(history)
            }
        })
    except Exception as e:
        logger.error(f"History error: {e}")
        return jsonify({
            "success": False,
            "error": "Failed to retrieve chat history"
        }), 500

@app.route('/chat/preferences/<user_id>', methods=['GET', 'POST'])
def user_preferences(user_id):
    """Get or update user preferences"""
    try:
        _, preferences = chatbot.get_user_context(user_id)
        
        if request.method == 'GET':
            return jsonify({
                "success": True,
                "data": preferences
            })
        
        elif request.method == 'POST':
            data = request.get_json()
            if data:
                preferences.update(data)
                return jsonify({
                    "success": True,
                    "data": preferences,
                    "message": "Preferences updated successfully"
                })
            
            return jsonify({"error": "No data provided"}), 400
            
    except Exception as e:
        logger.error(f"Preferences error: {e}")
        return jsonify({
            "success": False,
            "error": "Failed to handle preferences"
        }), 500

@app.route('/chat/clear/<user_id>', methods=['DELETE'])
def clear_chat_history(user_id):
    """Clear chat history for a user"""
    try:
        if user_id in chatbot.conversation_history:
            chatbot.conversation_history[user_id] = []
        
        return jsonify({
            "success": True,
            "message": "Chat history cleared successfully"
        })
        
    except Exception as e:
        logger.error(f"Clear history error: {e}")
        return jsonify({
            "success": False,
            "error": "Failed to clear chat history"
        }), 500

@app.route('/chat/topics', methods=['GET'])
def get_learning_topics():
    """Get available learning topics"""
    return jsonify({
        "success": True,
        "data": {
            "topics": chatbot.learning_topics,
            "count": len(chatbot.learning_topics)
        }
    })

if __name__ == '__main__':
    port = int(os.getenv('PYTHON_CHATBOT_PORT', 5001))
    debug = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    
    logger.info(f"Starting ByteBrain Chatbot on port {port}")
    app.run(host='0.0.0.0', port=port, debug=debug)