# 🎯 CCMenuBar Pro - Quick Reference Card

## 📦 Files Delivered

1. **`CCMenuBar_Pro.scpt`** - Pro AppleScript with dropdown menu
2. **`ccmenubar_pro`** - Pro shell wrapper with menu commands
3. **`claude_code_hooks_dropdown.json`** - Hooks that use menu features
4. **`demo_pro.sh`** - Interactive demo of all features
5. **`README_CCMenuBar_Pro.md`** - Complete documentation

## 🚀 Quick Setup

```bash
# 1. Build app in Script Editor (remember: "Stay open" ✓)
# 2. Install wrapper
sudo cp ccmenubar_pro /usr/local/bin/ccmenubar
sudo chmod +x /usr/local/bin/ccmenubar

# 3. Start app
ccmenubar --start

# 4. Run demo to see everything!
bash demo_pro.sh
```

## 📝 Essential Commands

### Status Bar
```bash
ccmenubar "🚀 Status text"
```

### Dropdown Menu - Todos
```bash
ccmenubar --add-todo "Fix bug" "⬜"      # Add pending todo
ccmenubar --add-todo "Done task" "✅"    # Add completed todo
ccmenubar --clear-todos                   # Clear all todos
```

### Dropdown Menu - Files (Clickable!)
```bash
ccmenubar --add-file "/path/to/file.py" "✏️"  # Add file to menu
ccmenubar --clear-files                        # Clear files
```

### Dropdown Menu - Tasks
```bash
ccmenubar --add-task "Compiling" "⚙️"    # Add current task
ccmenubar --clear-tasks                   # Clear tasks
```

### Dropdown Menu - Info
```bash
ccmenubar --menu-items "Files: 10" "Tests: OK"  # Add info items
ccmenubar --clear-menu                          # Clear info
```

## 🎨 Emoji Reference

### Todo Status
⬜ = Pending | ✅ = Done | ⏳ = In Progress | ❌ = Blocked | ❗ = Urgent

### File Actions  
📄 = Generic | ✏️ = Editing | 📖 = Reading | 📝 = Writing | 🧪 = Testing

### Task Status
🔄 = Running | ⚙️ = Processing | 🧪 = Testing | ✅ = Complete | ⚠️ = Warning

## 🤖 Claude Code Hook Example

```json
{
  "PreToolUse": [{
    "matcher": "Write|Edit",
    "hooks": [{
      "type": "command",
      "command": "file=$(echo \"$(cat)\" | jq -r '.tool_input.file_path'); ccmenubar \"✏️ Editing...\" && ccmenubar --add-file \"$file\" \"✏️\""
    }]
  }]
}
```

## 💡 Power User Tips

1. **Files are clickable!** - Click any file in the Recent Files menu to open it
2. **Auto-clear on start** - Add `ccmenubar --clear-all` to SessionStart hook
3. **Track everything** - Use different emoji to categorize actions visually
4. **Combine commands** - Chain with `&&` for multiple actions
5. **Use the demo** - Run `demo_pro.sh` to see all features in action

## 🎮 What You Can Track

- **Todo Lists** from Claude's suggestions
- **Files** Claude is working on (click to open!)
- **Current Tasks** in progress
- **Statistics** like file counts, test results
- **Git Info** like branch, changes
- **Time Tracking** for operations
- **Errors & Warnings** for debugging
- **Custom Info** - anything you want!

## 🚀 The Power of Dropdown Menus

With the pro version, your menu bar becomes an interactive dashboard:

```
Before: 🤖 CLAUDE: Building...     (just text)
After:  🤖 CLAUDE: Building... ▼    (click for dropdown!)
         ├─ Todo: Fix auth bug
         ├─ File: main.py (click to open!)
         ├─ Task: Running tests
         └─ Info: Coverage: 95%
```

Enjoy your new interactive Claude Code dashboard! 🎉
