"""
Simple Python Chatbot without external dependencies
Perfect for testing and basic educational interactions
"""

import json
import random
import re
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse
import threading

class SimpleChatbot:
    def __init__(self):
        self.responses = {
            # Greetings
            "hello|hi|hey|greetings": [
                "Hello! I'm ByteBrain AI, your learning companion. How can I help you today?",
                "Hi there! Ready to learn something new?",
                "Hey! What would you like to explore today?"
            ],
            
            # Learning topics
            "math|mathematics|algebra|geometry|calculus": [
                "Math is fascinating! What specific area would you like to explore? I can help with algebra, geometry, calculus, or basic arithmetic.",
                "Let's dive into mathematics! Are you working on a specific problem or concept?",
                "Math can be fun when you understand the patterns. What's challenging you?"
            ],
            
            "science|physics|chemistry|biology": [
                "Science is all around us! Which branch interests you - physics, chemistry, or biology?",
                "Great choice! Science helps us understand how the world works. What topic shall we explore?",
                "I love science questions! What phenomenon or concept would you like to understand better?"
            ],
            
            "programming|coding|python|javascript|code": [
                "Programming is like solving puzzles with logic! What language or concept interests you?",
                "Coding is a superpower in today's world. Are you learning a specific language or working on a project?",
                "Let's code! What programming challenge can I help you with?"
            ],
            
            "history|historical|past|ancient": [
                "History teaches us valuable lessons! What period or event would you like to learn about?",
                "The past shapes our present. Which historical topic interests you?",
                "History is full of amazing stories. What era or civilization catches your attention?"
            ],
            
            # Learning assistance
            "explain|help|understand|learn": [
                "I'd be happy to explain! What concept would you like me to break down for you?",
                "Let me help you understand. What topic is confusing you?",
                "Learning is a journey. What would you like to explore step by step?"
            ],
            
            "quiz|test|practice|exercise": [
                "Great idea! Practice makes perfect. What subject would you like to be quizzed on?",
                "Let's test your knowledge! Which topic should we focus on?",
                "I can create practice questions for you. What area needs work?"
            ],
            
            "example|show me|demonstrate": [
                "Examples make everything clearer! What concept needs a good example?",
                "I love giving examples. What would you like me to demonstrate?",
                "Real examples help understanding. What topic should I illustrate?"
            ],
            
            # Motivation and encouragement
            "difficult|hard|confused|stuck": [
                "Don't worry, everyone finds some topics challenging! Let's break it down into smaller steps.",
                "It's okay to feel stuck sometimes. That's how we grow! What specific part is confusing?",
                "Challenges are opportunities to learn. Let me help you work through this step by step."
            ],
            
            "thank|thanks|appreciate": [
                "You're very welcome! I'm here whenever you need help learning.",
                "Happy to help! Keep up the great work with your studies.",
                "My pleasure! Learning together makes it more fun."
            ],
            
            # Default responses
            "default": [
                "That's an interesting question! Can you tell me more about what you'd like to learn?",
                "I'm here to help you learn. What topic would you like to explore?",
                "Let's turn that into a learning opportunity! What subject interests you?",
                "I'd love to help you with that. Can you be more specific about what you need?"
            ]
        }
        
        self.conversation_history = {}
        self.learning_tips = [
            "💡 Tip: Break complex problems into smaller, manageable parts!",
            "🎯 Remember: Practice regularly, even if just for 15 minutes a day.",
            "🧠 Try explaining concepts to someone else - it helps you understand better!",
            "📚 Don't just memorize - understand the 'why' behind concepts.",
            "🔄 Review previous topics regularly to strengthen your memory."
        ]
    
    def get_response(self, user_input, user_id="default"):
        """Generate response based on user input"""
        user_input = user_input.lower().strip()
        
        # Initialize user history if needed
        if user_id not in self.conversation_history:
            self.conversation_history[user_id] = []
        
        # Add user message to history
        self.conversation_history[user_id].append({
            "role": "user",
            "message": user_input,
            "timestamp": datetime.now().isoformat()
        })
        
        # Find matching response pattern
        response_text = None
        matched_pattern = None
        
        for pattern, responses in self.responses.items():
            if pattern != "default" and re.search(pattern, user_input):
                response_text = random.choice(responses)
                matched_pattern = pattern
                break
        
        # Use default response if no pattern matched
        if not response_text:
            response_text = random.choice(self.responses["default"])
            matched_pattern = "default"
        
        # Add learning tip occasionally
        if random.random() < 0.3:  # 30% chance
            tip = random.choice(self.learning_tips)
            response_text += f"\n\n{tip}"
        
        # Add response to history
        self.conversation_history[user_id].append({
            "role": "assistant",
            "message": response_text,
            "pattern": matched_pattern,
            "timestamp": datetime.now().isoformat()
        })
        
        # Keep history manageable
        if len(self.conversation_history[user_id]) > 20:
            self.conversation_history[user_id] = self.conversation_history[user_id][-20:]
        
        return {
            "response": response_text,
            "pattern": matched_pattern,
            "suggestions": self.get_suggestions(matched_pattern),
            "timestamp": datetime.now().isoformat()
        }
    
    def get_suggestions(self, pattern):
        """Get contextual suggestions based on matched pattern"""
        suggestions = {
            "hello|hi|hey|greetings": [
                "What subject interests you?",
                "Need help with homework?",
                "Want to learn something new?",
                "Looking for practice exercises?"
            ],
            "math|mathematics|algebra|geometry|calculus": [
                "Show me a specific problem",
                "Explain a math concept",
                "Give me practice questions",
                "Help with homework"
            ],
            "science|physics|chemistry|biology": [
                "Explain a scientific concept",
                "Help with lab questions",
                "Discuss real-world applications",
                "Quiz me on science topics"
            ],
            "programming|coding|python|javascript|code": [
                "Help debug my code",
                "Explain programming concepts",
                "Suggest coding exercises",
                "Review my project"
            ],
            "explain|help|understand|learn": [
                "Give me examples",
                "Break it down step by step",
                "Show me the basics first",
                "Make it simpler"
            ],
            "default": [
                "Ask about math",
                "Explore science topics",
                "Learn programming",
                "Study history",
                "Get learning tips"
            ]
        }
        
        return suggestions.get(pattern, suggestions["default"])

class ChatbotHTTPHandler(BaseHTTPRequestHandler):
    chatbot = SimpleChatbot()
    
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {"status": "healthy", "service": "Simple ByteBrain Chatbot"}
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path.startswith('/history/'):
            user_id = self.path.split('/')[-1]
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            history = self.chatbot.conversation_history.get(user_id, [])
            response = {
                "success": True,
                "data": {
                    "history": history,
                    "count": len(history)
                }
            }
            self.wfile.write(json.dumps(response).encode())
        
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_POST(self):
        """Handle POST requests"""
        if self.path == '/chat':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
                message = data.get('message', '').strip()
                user_id = data.get('user_id', 'default')
                
                if not message:
                    self.send_error_response("Message cannot be empty", 400)
                    return
                
                response_data = self.chatbot.get_response(message, user_id)
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                
                response = {
                    "success": True,
                    "data": response_data
                }
                self.wfile.write(json.dumps(response).encode())
                
            except json.JSONDecodeError:
                self.send_error_response("Invalid JSON", 400)
            except Exception as e:
                self.send_error_response(f"Server error: {str(e)}", 500)
        
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_OPTIONS(self):
        """Handle CORS preflight requests"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def send_error_response(self, message, status_code):
        """Send error response"""
        self.send_response(status_code)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        
        response = {
            "success": False,
            "error": message
        }
        self.wfile.write(json.dumps(response).encode())
    
    def log_message(self, format, *args):
        """Override to customize logging"""
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {format % args}")

def run_server(port=5002):
    """Run the simple chatbot server"""
    server_address = ('', port)
    httpd = HTTPServer(server_address, ChatbotHTTPHandler)
    print(f"Simple ByteBrain Chatbot running on port {port}")
    print(f"Health check: http://localhost:{port}/health")
    print(f"Chat endpoint: http://localhost:{port}/chat")
    print("Press Ctrl+C to stop the server")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        httpd.shutdown()

if __name__ == '__main__':
    # You can also run this as a simple command-line chatbot
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == 'server':
        port = int(sys.argv[2]) if len(sys.argv) > 2 else 5002
        run_server(port)
    else:
        # Command line interface
        chatbot = SimpleChatbot()
        print("🤖 ByteBrain Simple Chatbot")
        print("Type 'quit' to exit\n")
        
        while True:
            user_input = input("You: ").strip()
            if user_input.lower() in ['quit', 'exit', 'bye']:
                print("Goodbye! Keep learning! 📚")
                break
            
            if user_input:
                response = chatbot.get_response(user_input)
                print(f"ByteBrain: {response['response']}\n")
                
                if response['suggestions']:
                    print("💡 Suggestions:")
                    for i, suggestion in enumerate(response['suggestions'][:3], 1):
                        print(f"  {i}. {suggestion}")
                    print()