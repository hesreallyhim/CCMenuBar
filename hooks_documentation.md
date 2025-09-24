# 🎯 Ultimate CCMenuBar Hooks Configuration

## What This Configuration Does

This configuration turns your menu bar into a real-time Claude Code activity monitor with friendly, informative status updates. Every hook event is utilized to give you maximum visibility into what Claude is doing!

## 📊 Status Indicators by Category

### 🎬 Session Management
- **🎬 Claude starting...** - New session starting
- **⏯️ Resuming session** - Resuming from a previous session
- **🧹 Fresh start!** - Clearing context for a fresh start

### 💭 User Interaction
- **💭 Processing: [prompt]...** - Shows first 30 chars of your prompt
- **⏳ Waiting for you...** - Claude needs your input
- **🔐 Permission needed** - Tool use requires approval

### 🖥️ Shell Operations
- **🖥️ $ [command]...** - Running shell command (first 30 chars)
- **✅ Shell OK** - Command succeeded
- **⚠️ Exit: [code]** - Command failed with exit code

### 📁 File Operations
- **📖 Reading: [filename]** - Reading a file
- **✏️ Editing: [filename]** - Editing existing file
- **📝 Writing: [filename]** - Creating new file
- **✅ File saved** - File operation succeeded
- **❌ Save failed** - File operation failed

### 🔍 Search Operations
- **🎯 Glob: [pattern]** - File pattern matching
- **🔍 Grep: [pattern]** - Content searching
- **📊 Found: X matches** - Search results count

### 🌐 Web Operations
- **🌐 Searching: [query]** - Web search in progress
- **🌐 Fetching: [domain]** - Fetching web content
- **🌐 X results** - Number of search results

### 🤖 Subagent Tasks
- **🤖 Subagent: [task]** - Subagent starting task
- **🤖✅ Subagent done** - Subagent completed

### 🔌 MCP (Model Context Protocol)
- **🔌 MCP: server → tool** - MCP tool being used
- **✅ MCP [server] done** - MCP operation complete

### 🗜️ Maintenance
- **🗜️ Compacting (manual)** - User-initiated compaction
- **🗜️ Auto-compacting** - Automatic context compaction

## 🎨 Fun Customizations

### Add Time Tracking

Modify any hook to include timestamps:
```bash
ccmenubar \"$(date '+%H:%M') - 🖥️ Running command\"
```

### Add Sound Effects

Add audio feedback for certain events:
```json
{
  "type": "command",
  "command": "ccmenubar \"✅ Done!\" && afplay /System/Library/Sounds/Glass.aiff"
}
```

### Add Project Context

Include project name in status:
```bash
project=$(basename \"$CLAUDE_PROJECT_DIR\"); ccmenubar \"📁 $project: Building...\"
```

### Add Progress Indicators

For long operations, cycle through animated indicators:
```bash
# In PreToolUse
ccmenubar \"⠋ Working...\"
# Then ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏ (spinner animation)
```

### Add Git Branch

Show current branch in status:
```bash
branch=$(cd \"$CLAUDE_PROJECT_DIR\" && git branch --show-current 2>/dev/null || echo \"no-git\")
ccmenubar \"🌿 $branch: $status\"
```

## 🚀 Advanced Features

### Smart Error Detection

The configuration intelligently detects different error types:
- Exit codes for shell commands
- Success/failure for file operations
- Permission requirements for tool use
- Network errors for web operations

### Context-Aware Messages

Messages adapt based on the actual data:
- Shows filenames being edited
- Displays search patterns
- Truncates long commands/queries
- Extracts MCP server names

### Performance Optimized

All hooks are designed to be lightweight:
- Use `head -c` for string truncation
- Minimal JSON parsing with `jq`
- Quick pattern matching with `sed`
- Error handling with fallbacks

## 🎮 Power User Tips

### 1. Create Hook Aliases

Add to your `.zshrc`:
```bash
alias claude-status='tail -f ~/.claude/projects/*/transcript.jsonl | jq -r .message 2>/dev/null | while read line; do ccmenubar \"📝 $line\"; done'
```

### 2. Log Everything

Add logging to any hook:
```bash
echo \"$(date): $tool_name\" >> ~/.claude/activity.log && ccmenubar \"⚙️ $tool_name\"
```

### 3. Custom Notifications

Use system notifications for important events:
```bash
osascript -e 'display notification \"Task complete!\" with title \"Claude Code\"' && ccmenubar \"✅ Done!\"
```

### 4. Conditional Updates

Show different messages based on file types:
```bash
case \"$file\" in
  *.py) ccmenubar \"🐍 Python: $file\" ;;
  *.js) ccmenubar \"📜 JavaScript: $file\" ;;
  *.md) ccmenubar \"📝 Markdown: $file\" ;;
  *) ccmenubar \"📄 File: $file\" ;;
esac
```

## 🔧 Installation

1. **Save the configuration** to `~/.claude/settings.json` for user-wide or `.claude/settings.json` in your project

2. **Install jq** if not already installed:
   ```bash
   brew install jq  # macOS
   apt-get install jq  # Ubuntu/Debian
   ```

3. **Test the hooks** by asking Claude to perform various operations and watch your menu bar!

## 🎯 Complete Status Reference

| Event | Status | Meaning |
|-------|--------|---------|
| 🎬 | Claude starting... | New session |
| ⏯️ | Resuming session | Continuing work |
| 🧹 | Fresh start! | Context cleared |
| 💭 | Processing: ... | Thinking about prompt |
| 🖥️ | $ command... | Running shell |
| ✅ | Done/OK/Saved | Success |
| ⚠️ | Exit: X | Non-zero exit |
| ❌ | Failed/Error | Operation failed |
| 📖 | Reading | File read |
| ✏️ | Editing | File edit |
| 📝 | Writing | File write |
| 🔍 | Grep/Search | Searching |
| 📊 | Found: X | Results count |
| 🌐 | Web operation | Internet access |
| 🤖 | Subagent | Delegated task |
| 🔌 | MCP | External tool |
| 🗜️ | Compacting | Memory management |
| ⏳ | Waiting | Needs input |
| 🔐 | Permission | Approval needed |
| ❗ | Attention | Important notice |
| 🏁 | Stopped | Task ended |

## 🎉 Have Fun!

This configuration makes working with Claude Code more engaging and informative. You'll always know what Claude is up to, and the friendly status messages make long coding sessions more enjoyable!

Feel free to customize the emojis and messages to match your style. Happy coding! 🚀✨
