#!/usr/bin/env python3
"""
Test script for ByteBrain Python Chatbot
Tests both simple and advanced chatbot functionality
"""

import json
import requests
import time
import sys
from simple_chatbot import SimpleChatbot

def test_simple_chatbot():
    """Test the simple chatbot directly"""
    print("🧪 Testing Simple Chatbot...")
    
    chatbot = SimpleChatbot()
    
    test_messages = [
        "Hello!",
        "Help me with math",
        "Explain algebra",
        "I'm confused about science",
        "Can you quiz me?",
        "Show me an example",
        "This is difficult",
        "Thank you"
    ]
    
    for message in test_messages:
        print(f"\n👤 User: {message}")
        response = chatbot.get_response(message, "test_user")
        print(f"🤖 Bot: {response['response']}")
        
        if response['suggestions']:
            print("💡 Suggestions:", ", ".join(response['suggestions'][:2]))
    
    print("\n✅ Simple chatbot test completed!")

def test_http_server(port=5002):
    """Test the HTTP server endpoints"""
    print(f"\n🌐 Testing HTTP Server on port {port}...")
    
    base_url = f"http://localhost:{port}"
    
    try:
        # Test health endpoint
        print("Testing health endpoint...")
        response = requests.get(f"{base_url}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Health check passed")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
        
        # Test chat endpoint
        print("Testing chat endpoint...")
        chat_data = {
            "message": "Hello, I need help with programming",
            "user_id": "test_user_123"
        }
        
        response = requests.post(
            f"{base_url}/chat",
            json=chat_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get("success"):
                print("✅ Chat endpoint working")
                print(f"🤖 Response: {result['data']['response'][:100]}...")
            else:
                print(f"❌ Chat failed: {result.get('error')}")
                return False
        else:
            print(f"❌ Chat endpoint failed: {response.status_code}")
            return False
        
        # Test history endpoint
        print("Testing history endpoint...")
        response = requests.get(f"{base_url}/history/test_user_123", timeout=5)
        if response.status_code == 200:
            result = response.json()
            if result.get("success"):
                print(f"✅ History endpoint working (found {result['data']['count']} messages)")
            else:
                print(f"❌ History failed: {result.get('error')}")
        else:
            print(f"❌ History endpoint failed: {response.status_code}")
        
        print("✅ HTTP server test completed!")
        return True
        
    except requests.exceptions.ConnectionError:
        print(f"❌ Could not connect to server on port {port}")
        print("💡 Make sure to run: python simple_chatbot.py server 5002")
        return False
    except Exception as e:
        print(f"❌ HTTP test error: {e}")
        return False

def test_advanced_chatbot(port=5001):
    """Test the advanced chatbot if available"""
    print(f"\n🚀 Testing Advanced Chatbot on port {port}...")
    
    base_url = f"http://localhost:{port}"
    
    try:
        # Test health endpoint
        response = requests.get(f"{base_url}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Advanced chatbot health check passed")
            
            # Test chat with advanced features
            chat_data = {
                "message": "Explain quantum physics in simple terms",
                "user_id": "advanced_test_user"
            }
            
            response = requests.post(
                f"{base_url}/chat",
                json=chat_data,
                headers={"Content-Type": "application/json"},
                timeout=15
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get("success"):
                    print("✅ Advanced chat working")
                    print(f"🤖 Response: {result['data']['response'][:150]}...")
                    if 'sentiment' in result['data']:
                        print(f"📊 Sentiment: {result['data']['sentiment']['compound']:.2f}")
                else:
                    print(f"❌ Advanced chat failed: {result.get('error')}")
            
            # Test topics endpoint
            response = requests.get(f"{base_url}/chat/topics", timeout=5)
            if response.status_code == 200:
                result = response.json()
                if result.get("success"):
                    topics = result['data']['topics']
                    print(f"📚 Available topics: {', '.join(topics[:5])}...")
            
            print("✅ Advanced chatbot test completed!")
            return True
        else:
            print(f"❌ Advanced chatbot not available on port {port}")
            return False
            
    except requests.exceptions.ConnectionError:
        print(f"💡 Advanced chatbot not running on port {port}")
        print("   To test: python chatbot_server.py")
        return False
    except Exception as e:
        print(f"❌ Advanced chatbot test error: {e}")
        return False

def interactive_test():
    """Interactive testing mode"""
    print("\n🎮 Interactive Test Mode")
    print("Type messages to test the chatbot (type 'quit' to exit)")
    
    chatbot = SimpleChatbot()
    
    while True:
        try:
            message = input("\n👤 You: ").strip()
            if message.lower() in ['quit', 'exit', 'q']:
                break
            
            if message:
                response = chatbot.get_response(message, "interactive_user")
                print(f"🤖 Bot: {response['response']}")
                
                if response['suggestions']:
                    print("💡 Try asking:")
                    for i, suggestion in enumerate(response['suggestions'][:3], 1):
                        print(f"   {i}. {suggestion}")
        
        except KeyboardInterrupt:
            break
    
    print("\n👋 Thanks for testing!")

def main():
    """Main test function"""
    print("🤖 ByteBrain Python Chatbot Test Suite")
    print("=" * 50)
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "interactive":
            interactive_test()
            return
        elif sys.argv[1] == "http":
            port = int(sys.argv[2]) if len(sys.argv) > 2 else 5002
            test_http_server(port)
            return
        elif sys.argv[1] == "advanced":
            port = int(sys.argv[2]) if len(sys.argv) > 2 else 5001
            test_advanced_chatbot(port)
            return
    
    # Run all tests
    test_simple_chatbot()
    
    print("\n" + "=" * 50)
    print("🔧 To test HTTP servers:")
    print("  python test_chatbot.py http 5002    # Test simple server")
    print("  python test_chatbot.py advanced 5001 # Test advanced server")
    print("  python test_chatbot.py interactive   # Interactive mode")

if __name__ == "__main__":
    main()