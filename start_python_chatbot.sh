#!/bin/bash

echo "Starting ByteBrain Python Chatbot..."
echo "====================================="

# Navigate to the chatbot directory
cd backend/python_chatbot

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
echo ""
echo "Starting simple chatbot server..."
echo ""
echo "The chatbot will be available at: http://localhost:5002"
echo "Health check: http://localhost:5002/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo "====================================="

# Start the chatbot server
$PYTHON_CMD simple_chatbot.py server 5002