# CCMenuBar - Claude Code Status Tracker for macOS 🚀

A lightweight, **open-source** macOS menu bar app that displays Claude Code's real-time status. Perfect for keeping track of what Claude is doing while you work!

## 🎓 Learn By Installing

**We encourage you to download, read, and understand the code before installing!** This project is designed to be educational - every script is commented and explained. By reading through the installation process, you'll learn about:

- AppleScript application development
- macOS menu bar apps
- Shell scripting and CLI tools  
- Claude Code hooks system
- Software distribution methods

## 📚 Understanding the Files

Before installing, take a moment to explore what each file does:

### Core Files (Read these first!)

1. **`CCMenuBar_Enhanced.applescript`** (or `.scpt`)
   - The heart of the app - an AppleScript that creates the menu bar interface
   - **Format options**:
     - `.applescript` - Plain text, readable in any editor (great for learning!)
     - `.scpt` - Compiled binary, smaller and faster (for distribution)
   - **What you'll learn**: How macOS menu bar apps work, AppleScript UI programming

2. **`ccmenubar_enhanced`** (Shell script)
   - Command-line wrapper that communicates with the app
   - **What you'll learn**: How to control macOS apps from the terminal, shell scripting

3. **`install.sh`** 
   - The installation script - **READ THIS BEFORE RUNNING!**
   - Shows exactly what gets installed and where
   - **What you'll learn**: macOS app installation, dependency management

### Configuration Files

4. **`claude_code_hooks_dropdown.json`**
   - Claude Code hooks configuration
   - **What you'll learn**: How Claude Code hooks work, JSON event handling

5. **`claude_logo.png`**
   - Menu bar icon (16x16 pixels)
   - **What you'll learn**: macOS icon requirements

## 🔍 Installation Options (From Educational to Convenient)

### Option 1: Manual Installation (Most Educational!) 📖

**This is the recommended approach for learning!**

```bash
# 1. Clone and explore the repository
git clone https://github.com/yourusername/ccmenubar.git
cd ccmenubar

# 2. Read the installation script to understand what it does
cat install.sh
less install.sh  # Read it carefully!

# 3. Read the AppleScript to understand the app
cat CCMenuBar_Enhanced.applescript

# 4. Manually build the app (learn by doing!)
# Open Script Editor
open -a "Script Editor" CCMenuBar_Enhanced.applescript

# In Script Editor:
# - File → Export
# - Format: Application  
# - ☑️ Stay open after run handler
# - Save to: /Applications

# 5. Install the CLI tool manually
sudo cp ccmenubar_enhanced /usr/local/bin/ccmenubar
sudo chmod +x /usr/local/bin/ccmenubar

# 6. Add the icon
cp claude_logo.png /Applications/CCMenuBar.app/Contents/Resources/

# 7. Test it out!
ccmenubar --start
ccmenubar "Hello World!"
```

### Option 2: Guided Installation (Educational with Automation) 🎯

**Read the script first, then run it:**

```bash
# 1. Download and examine the installer
curl -O https://raw.githubusercontent.com/yourusername/ccmenubar/main/install.sh

# 2. READ THE SCRIPT! This is important!
cat install.sh | less

# 3. Make it executable and run (only after understanding it)
chmod +x install.sh
./install.sh
```

### Option 3: Quick Install (After You've Learned) ⚡

**Only use this after you understand what's being installed:**

```bash
# One-line installer (examine the URL first!)
curl -sL https://raw.githubusercontent.com/yourusername/ccmenubar/main/install.sh | bash
```

## 📖 How It Works (Technical Details)

### The AppleScript Application

The app uses AppleScript with Objective-C bridge to create a native macOS menu bar item:

```applescript
-- Key concepts demonstrated:
use framework "AppKit"  -- Access to macOS UI elements
use framework "Foundation"  -- Core macOS functionality

-- Creates NSStatusItem (menu bar item)
set statusItem to bar's statusItemWithLength:(NSVariableStatusItemLength)

-- Creates NSMenu (dropdown menu)
set statusMenu to NSMenu's alloc()'s init()
```

### File Format Options

You might see the AppleScript in different formats:

| Extension | Format | When to Use | Pros | Cons |
|-----------|--------|-------------|------|------|
| `.applescript` | Plain text | Learning, editing | Human-readable, version control friendly | Larger, needs compilation |
| `.scpt` | Compiled binary | Distribution | Smaller, faster execution | Not readable in text editors |
| `.scptd` | Bundle | With resources | Can include files | More complex |
| `.app` | Application | Final product | Double-clickable | Largest size |

### The Shell Wrapper

The `ccmenubar` command uses `osascript` to communicate with the app:

```bash
# How it sends commands to the app:
osascript -e "tell application \"CCMenuBar\" to set_status(\"$text\")"

# This demonstrates inter-process communication on macOS
```

### Claude Code Hooks

The hooks configuration shows event-driven programming:

```json
{
  "PreToolUse": [{
    "matcher": "Write|Edit",  // Regex pattern matching
    "hooks": [{
      "type": "command",
      "command": "ccmenubar --add-file \"$file\" \"✏️\""  // Shell execution
    }]
  }]
}
```

## 🛠️ Build Your Own Version

We encourage you to modify and improve CCMenuBar! Here's how:

### 1. Fork the Repository
- Make your own copy to experiment with

### 2. Modify the AppleScript
- Change colors, fonts, menu items
- Add new features
- Learn by breaking things!

### 3. Customize the Hooks
- Create your own status messages
- Add sound effects
- Integrate with other tools

### 4. Share Your Improvements
- Submit pull requests
- Share your customizations
- Help others learn!

## 🔒 Security & Trust

### Why Read the Code?

1. **Understand what you're installing** - Never run scripts you don't understand
2. **Learn from the implementation** - See how macOS apps work
3. **Verify safety** - Ensure no malicious code
4. **Customize for your needs** - Modify with confidence

### What the Installer Does:

1. **Checks dependencies** (Homebrew, jq)
2. **Compiles AppleScript** to .app
3. **Copies CLI tool** to /usr/local/bin  
4. **Sets up Claude Code** hooks in ~/.claude
5. **Optionally adds to login items**

### What It Doesn't Do:

- ❌ No network requests (except downloading from GitHub)
- ❌ No data collection
- ❌ No modification of system files
- ❌ No background processes beyond the menu bar app

## 🎯 Learning Resources

### Understanding the Code:

1. **AppleScript**
   - [AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/)
   - Look for comments in our `.applescript` file

2. **Shell Scripting**
   - Read `ccmenubar_enhanced` - it's well commented
   - Try modifying the commands

3. **Claude Code Hooks**
   - [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/hooks)
   - Experiment with different hook events

### Try These Exercises:

1. **Change the menu bar icon** - Replace claude_logo.png
2. **Add a new menu item** - Modify rebuild_menu() in AppleScript
3. **Create custom hook** - Add your own status messages
4. **Add sound effects** - Use `afplay` command in hooks
5. **Track different events** - Monitor file changes, git commits, etc.

## 💡 Tips for Learners

### Before Installing:

- [ ] Read `install.sh` completely
- [ ] Understand what each file does
- [ ] Check file permissions being set
- [ ] Note where files are installed
- [ ] Understand how to uninstall

### Good Learning Practice:

```bash
# Don't just run commands - understand them first!

# Bad:
curl -sL some-url | bash  # Don't do this blindly!

# Good:
curl -O some-url          # Download first
cat script.sh             # Read it
# Understand what it does
./script.sh               # Then run it
```

### Debugging:

```bash
# If something goes wrong:
ccmenubar --status        # Check if app is running
ps aux | grep CCMenuBar   # Check process
cat ~/.claude/settings.json  # Check hooks
open /Applications/CCMenuBar.app  # Try manual launch
```

## 🤝 Contributing

This is an educational project! We welcome:

- **Questions** - Open an issue if you don't understand something
- **Improvements** - Submit PRs with better comments/documentation
- **Examples** - Share your custom configurations
- **Tutorials** - Write guides for specific features

## 📜 License

MIT License - Learn from it, modify it, share it!

## 🎉 Final Thoughts

**Remember**: The best way to learn is by understanding what you're installing. Take your time, read the code, experiment, and have fun! Every expert was once a beginner who took the time to understand how things work.

If you just want it to work quickly, that's fine too - but we encourage you to come back and explore the code when you have time. You might be surprised how much you can learn from a simple menu bar app!

---

*"Give someone a program, and frustrate them for a day. Teach someone to program, and frustrate them for a lifetime."* 😄

**Happy Learning & Coding!** 🚀✨
