#!/bin/bash

# CCMenuBar Pro Demo Script
# This script demonstrates all the dropdown menu features

echo "🎯 CCMenuBar Pro Demo"
echo "=========================="
echo ""

# Start the app
echo "1. Starting CCMenuBar..."
ccmenubar --start
sleep 2

# Set initial status
echo "2. Setting status..."
ccmenubar "🚀 Demo Starting!"
sleep 1

# Clear everything first
echo "3. Clearing all menu items..."
ccmenubar --clear-all
sleep 1

# Add some todos
echo "4. Adding todo items..."
ccmenubar --add-todo "Review pull request #42" "⬜"
sleep 0.5
ccmenubar --add-todo "Write unit tests for auth" "⏳"
sleep 0.5
ccmenubar --add-todo "Update API documentation" "⬜"
sleep 0.5
ccmenubar --add-todo "Deploy to staging" "✅"
sleep 0.5
ccmenubar --add-todo "Security audit" "❌"
sleep 1

echo "   ✓ Added 5 todo items with different statuses"
echo ""

# Add current tasks
echo "5. Adding current tasks..."
ccmenubar --add-task "Building application" "🔨"
sleep 0.5
ccmenubar --add-task "Running test suite" "🧪"
sleep 0.5
ccmenubar --add-task "Analyzing code" "🔬"
sleep 1

echo "   ✓ Added 3 current tasks"
echo ""

# Add recent files (these will be clickable!)
echo "6. Adding recent files..."
ccmenubar --add-file "$HOME/.zshrc" "📖"
sleep 0.5
ccmenubar --add-file "$HOME/.bashrc" "✏️"
sleep 0.5
ccmenubar --add-file "/tmp/test.txt" "📝"
sleep 1

echo "   ✓ Added 3 recent files (click them in the menu to open!)"
echo ""

# Add custom info/statistics
echo "7. Adding project statistics..."
ccmenubar --menu-items \
  "Branch: feature/demo" \
  "Files: 42" \
  "Tests: 10/10 passing" \
  "Coverage: 95%" \
  "Build: #1337" \
  "Time: $(date '+%H:%M:%S')"
sleep 1

echo "   ✓ Added 6 info items"
echo ""

# Update status with animation
echo "8. Animating status bar..."
for i in {1..3}; do
  ccmenubar "⠋ Processing..."
  sleep 0.3
  ccmenubar "⠙ Processing..."
  sleep 0.3
  ccmenubar "⠹ Processing..."
  sleep 0.3
  ccmenubar "⠸ Processing..."
  sleep 0.3
done

ccmenubar "✅ Demo Complete!"

echo ""
echo "✨ Demo Complete!"
echo ""
echo "📋 What you should see in the dropdown menu:"
echo "   - 5 todo items with different status emojis"
echo "   - 3 current tasks"
echo "   - 3 recent files (try clicking them!)"
echo "   - 6 project statistics"
echo ""
echo "🎮 Try these commands:"
echo "   ccmenubar --clear-todos       # Clear just the todos"
echo "   ccmenubar --clear-files       # Clear recent files"
echo "   ccmenubar --clear-all         # Clear everything"
echo "   ccmenubar --help              # See all commands"
echo ""
echo "💡 Tip: Click the dropdown menu to see everything!"
