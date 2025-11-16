#!/bin/bash

echo "Starting ByteBrain Groq Chatbot Server..."
echo "=========================================="

cd chatbot

# Check if Python is installed
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "ERROR: Python is not installed or not in PATH"
    echo "Please install Python from https://python.org"
    exit 1
fi

# Use python3 if available, otherwise python
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
fi

echo "Python found! Using: $PYTHON_CMD"
echo "Checking dependencies..."

echo "Installing/updating dependencies..."
pip install flask flask-cors groq python-dotenv

echo ""
echo "Checking for GROQ_API_KEY..."
if [ ! -f .env ]; then
    echo "WARNING: .env file not found!"
    echo "Please create .env file with your GROQ_API_KEY"
    echo "Example: GROQ_API_KEY=your_api_key_here"
    echo ""
    echo "You can get a free API key from: https://console.groq.com/"
    read -p "Press Enter to continue..."
fi

echo ""
echo "Starting Groq chatbot server..."
echo ""
echo "The chatbot will be available at: http://localhost:5000"
echo "Health check: http://localhost:5000/health"
echo "Chat endpoint: http://localhost:5000/chat"
echo ""
echo "Press Ctrl+C to stop the server"
echo "=========================================="

$PYTHON_CMD server.py