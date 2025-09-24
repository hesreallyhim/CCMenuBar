# 🎯 CCMenuBar Pro - With Dropdown Menu!

Transform your macOS menu bar into an interactive Claude Code dashboard with todos, recent files, current tasks, and more!

## 🆕 What's New in Pro Version

The pro version adds a **fully interactive dropdown menu** that shows:

- ✅ **Todo List** - Track tasks Claude suggests or you add manually
- 📁 **Recent Files** - Click to open files Claude has worked on
- 📋 **Current Tasks** - See what Claude is working on right now
- 📊 **Statistics** - File counts, test results, coverage, etc.
- 🔄 **Auto-refresh** - Menu updates as Claude works

## 📸 Visual Preview

```
🤖 CLAUDE ▼
├── Claude Code Status
├─────────────────────
├── 📋 Current Tasks
│   ⚙️ Compiling main.py
│   🧪 Running tests
├─────────────────────
├── ✅ Todo List
│   ⬜ Fix login bug
│   ✅ Write unit tests
│   ⏳ Update documentation
├─────────────────────
├── 📁 Recent Files
│   ✏️ main.py          [clickable]
│   📖 config.json      [clickable]
│   📝 README.md        [clickable]
├─────────────────────
├── 📌 Info
│   Files edited: 12
│   Tests passed: 10/10
│   Coverage: 95%
├─────────────────────
├── 🔄 Refresh
├─────────────────────
└── Quit CCMenuBar
```

## 🚀 Installation

### 1. Build the Pro App

1. Open `CCMenuBar_Pro.scpt` in Script Editor
2. Choose **File → Export...**
3. Settings:
   - **File Format:** Application
   - **Name:** CCMenuBar
   - ☑️ **Stay open after run handler** (CRITICAL!)
   - **Where:** /Applications
4. Click **Save**

### 2. Add the Icon

```bash
cp claude_logo.png /Applications/CCMenuBar.app/Contents/Resources/
```

### 3. Install Pro Wrapper

```bash
sudo cp ccmenubar_pro /usr/local/bin/ccmenubar
sudo chmod +x /usr/local/bin/ccmenubar
```

### 4. Configure Claude Code Hooks

Copy `claude_code_hooks_dropdown.json` to:
- `~/.claude/settings.json` (user-wide)
- OR `.claude/settings.json` (project-specific)

### 5. Launch

```bash
ccmenubar --start
```

## 🎮 Usage Examples

### Basic Status Updates

```bash
# Set status text
ccmenubar "🚀 Building project..."
```

### Managing Todos

```bash
# Add todos with different status indicators
ccmenubar --add-todo "Fix authentication bug" "⬜"     # Pending
ccmenubar --add-todo "Write unit tests" "✅"           # Done
ccmenubar --add-todo "Deploy to staging" "⏳"          # In progress
ccmenubar --add-todo "Security review" "❌"            # Blocked

# Clear all todos
ccmenubar --clear-todos
```

### Tracking Files

```bash
# Add files with action indicators
ccmenubar --add-file "/path/to/main.py" "✏️"          # Editing
ccmenubar --add-file "/path/to/data.json" "📖"        # Reading
ccmenubar --add-file "/path/to/new.md" "📝"           # Writing
ccmenubar --add-file "/path/to/test.js" "🧪"          # Testing

# Files are clickable in the menu!
# Clear recent files
ccmenubar --clear-files
```

### Current Tasks

```bash
# Show what's currently happening
ccmenubar --add-task "Compiling TypeScript" "⚙️"
ccmenubar --add-task "Running tests" "🧪"
ccmenubar --add-task "Building Docker image" "🐳"

# Clear tasks
ccmenubar --clear-tasks
```

### Custom Info Section

```bash
# Add statistics or any info
ccmenubar --menu-items "Files: 42" "Tests: 10/10" "Coverage: 95%"

# Multiple items at once
ccmenubar --menu-items \
  "Branch: feature/auth" \
  "Commits: 5 ahead" \
  "Memory: 2.1GB" \
  "Time: 15min"
```

## 🤖 Claude Code Integration

### Smart Hooks Configuration

The provided `claude_code_hooks_dropdown.json` automatically:

1. **Tracks edited files** - Shows in Recent Files menu (clickable!)
2. **Shows current operations** - Updates Current Tasks section
3. **Creates todos** - Adds items when attention needed
4. **Displays statistics** - File counts, search results, etc.
5. **Manages state** - Clears completed tasks automatically

### Hook Examples

#### File Operations Hook
```json
{
  "matcher": "Write|Edit",
  "hooks": [{
    "type": "command",
    "command": "file=$(echo \"$(cat)\" | jq -r '.tool_input.file_path'); ccmenubar --add-file \"$file\" \"✏️\""
  }]
}
```

#### Task Tracking Hook
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "cmd=$(echo \"$(cat)\" | jq -r '.tool_input.command'); ccmenubar --add-task \"Shell: $cmd\" \"🖥️\""
  }]
}
```

#### Completion Hook with Todos
```json
{
  "Stop": [{
    "hooks": [{
      "type": "command",
      "command": "ccmenubar \"✅ Done!\" && ccmenubar --add-todo \"Review changes\" \"⬜\" && ccmenubar --add-todo \"Test implementation\" \"⬜\""
    }]
  }]
}
```

## 🎨 Advanced Customizations

### Dynamic Todo Generation

Create todos based on test results:
```bash
#!/bin/bash
# In PostToolUse hook for tests
if [ "$test_failures" -gt 0 ]; then
  ccmenubar --add-todo "Fix failing tests: $test_failures" "❌"
fi
```

### Git Integration

Show git status in menu:
```bash
# In a hook or script
branch=$(git branch --show-current)
status=$(git status --porcelain | wc -l)
ccmenubar --menu-items "Branch: $branch" "Changes: $status files"
```

### Project Scanner

Automatically populate todos from code comments:
```bash
#!/bin/bash
# Find TODO comments and add to menu
grep -r "TODO:" . --include="*.py" | while read -r line; do
  todo=$(echo "$line" | sed 's/.*TODO: *//' | head -c 50)
  ccmenubar --add-todo "$todo" "⬜"
done
```

### Time Tracking

Track time spent on different files:
```bash
# In PreToolUse hook
start_time=$(date +%s)

# In PostToolUse hook
end_time=$(date +%s)
duration=$((end_time - start_time))
ccmenubar --menu-items "Last operation: ${duration}s"
```

## 📊 Complete Command Reference

| Command | Description | Example |
|---------|-------------|---------|
| `ccmenubar "text"` | Set status text | `ccmenubar "Building..."` |
| `--add-todo "text" [emoji]` | Add todo item | `--add-todo "Fix bug" "⬜"` |
| `--add-file "path" [emoji]` | Add file (clickable) | `--add-file "/path/to/file.py" "✏️"` |
| `--add-task "name" [emoji]` | Add current task | `--add-task "Compiling" "⚙️"` |
| `--menu-items "item1" "item2"` | Set info items | `--menu-items "Files: 10" "Tests: OK"` |
| `--clear-todos` | Clear todo list | `ccmenubar --clear-todos` |
| `--clear-files` | Clear file list | `ccmenubar --clear-files` |
| `--clear-tasks` | Clear task list | `ccmenubar --clear-tasks` |
| `--clear-menu` | Clear info items | `ccmenubar --clear-menu` |
| `--clear-all` | Clear everything | `ccmenubar --clear-all` |

## 🎯 Status Emoji Guide

### Todo Status
- ⬜ Pending/Not started
- ⏳ In progress
- ✅ Completed
- ❌ Blocked/Failed
- ❗ Urgent/Important

### File Actions
- 📄 Generic file
- ✏️ Editing
- 📖 Reading
- 📝 Writing/Creating
- 🧪 Testing
- 🔍 Searching
- 🗑️ Deleting

### Task Status
- 🔄 Running/In progress
- ⚙️ Processing
- 🧪 Testing
- 🐳 Docker operation
- 🌿 Git operation
- 📦 Package management
- ✅ Complete
- ⚠️ Warning
- ❌ Error

## 🐛 Troubleshooting

### Menu not updating?
```bash
# Force rebuild menu
osascript -e 'tell app "CCMenuBar" to rebuild_menu()'
```

### Files not opening when clicked?
- Check file paths are absolute
- Ensure files exist and have proper permissions

### Too many items in menu?
```bash
# Clear specific sections
ccmenubar --clear-files  # Keep only last 10 anyway
ccmenubar --clear-todos
```

### App crashes with menu operations?
- Check for special characters in text
- Ensure proper quote escaping
- Look at Console.app for errors

## 💡 Pro Tips

### 1. Auto-populate todos from issues
```bash
# Fetch GitHub issues and add as todos
gh issue list --json title,state | jq -r '.[] | 
  "--add-todo \"" + .title + "\" \"" + 
  (if .state == "OPEN" then "⬜" else "✅" end) + "\""' |
  xargs -I {} sh -c 'ccmenubar {}'
```

### 2. Create project dashboard
```bash
#!/bin/bash
# project-status.sh
files=$(find . -name "*.py" | wc -l)
tests=$(pytest --co -q 2>/dev/null | tail -1)
coverage=$(coverage report | tail -1 | awk '{print $4}')

ccmenubar --menu-items \
  "Python files: $files" \
  "Tests: $tests" \
  "Coverage: $coverage" \
  "Last update: $(date '+%H:%M')"
```

### 3. Track Claude's suggestions
When Claude suggests improvements, automatically add them as todos in your menu!

## 🎉 Enjoy Your Interactive Menu Bar!

With the pro CCMenuBar, you have a powerful, interactive dashboard right in your menu bar. Track todos, monitor files, see current tasks, and get instant access to everything Claude is working on!

The dropdown menu transforms CCMenuBar from a simple status indicator into a full project management tool. Happy coding! 🚀✨
