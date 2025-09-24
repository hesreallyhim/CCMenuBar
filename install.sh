#!/bin/bash

# CCMenuBar One-Click Installer
# This script automatically installs and configures CCMenuBar

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/hesreallyhim/ccmenubar"  # Change this to your repo
APP_NAME="CCMenuBar"
APP_DIR="/Applications"
INSTALL_DIR="/usr/local/bin"
TEMP_DIR="/tmp/ccmenubar-install-$$"

# Functions
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_header() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║     CCMenuBar One-Click Installer     ║"
    echo "║    Claude Code Status Bar for macOS   ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
}

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This installer is for macOS only"
        exit 1
    fi
}

check_dependencies() {
    local missing_deps=()
    
    # Check for required tools
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if ! command -v osacompile &> /dev/null; then
        print_error "AppleScript compiler not found. Are you on macOS?"
        exit 1
    fi
    
    # Install missing dependencies
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        
        # Check if Homebrew is installed
        if command -v brew &> /dev/null; then
            print_status "Installing dependencies via Homebrew..."
            brew install "${missing_deps[@]}"
        else
            print_warning "Homebrew not found. Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install "${missing_deps[@]}"
        fi
    fi
}

download_files() {
    print_status "Downloading CCMenuBar files..."
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Clone repository or download files
    if [[ -n "$REPO_URL" ]]; then
        git clone --depth 1 "$REPO_URL" . 2>/dev/null || {
            print_warning "Couldn't clone repo, downloading individual files..."
            # Fallback to curl for individual files
            curl -sL "$REPO_URL/raw/main/CCMenuBar_Enhanced.scpt" -o CCMenuBar_Enhanced.scpt
            curl -sL "$REPO_URL/raw/main/ccmenubar_enhanced" -o ccmenubar_enhanced
            curl -sL "$REPO_URL/raw/main/claude_logo.png" -o claude_logo.png
            curl -sL "$REPO_URL/raw/main/claude_code_hooks_dropdown.json" -o claude_code_hooks_dropdown.json
        }
    fi
}

compile_app() {
    print_status "Compiling CCMenuBar application..."
    
    # Create a temporary script that will be compiled
    cat > "$TEMP_DIR/CCMenuBar_temp.scpt" << 'APPLESCRIPT'
use AppleScript version "2.8"
use framework "AppKit"
use framework "Foundation"
use scripting additions

property statusItem : missing value
property statusMenu : missing value
property isRunning : false
property menuItems : {}
property todoItems : {}
property recentFiles : {}
property currentTasks : {}

on run
	if not isRunning then
		try
			-- Create default icon if no PNG found
			set img to missing value
			try
				set rPath to POSIX path of (path to resource "claude_logo.png")
				set img to (current application's NSImage's alloc()'s initWithContentsOfFile:rPath)
				if img is not missing value then
					img's setSize:(current application's NSMakeSize(16, 16))
					img's setTemplate:true
				end if
			end try
			
			-- Create the menu-bar item
			set bar to current application's NSStatusBar's systemStatusBar()
			set statusItem to bar's statusItemWithLength:(current application's NSVariableStatusItemLength)
			
			if img is not missing value then
				(statusItem's button()'s setImage:img)
			end if
			
			(statusItem's button()'s setTitle:" CLAUDE")
			(statusItem's button()'s setFont:(current application's NSFont's systemFontOfSize:12))
			
			-- Create the dropdown menu
			set statusMenu to current application's NSMenu's alloc()'s init()
			statusMenu's setAutoenablesItems:false
			
			rebuild_menu()
			statusItem's setMenu:statusMenu
			set isRunning to true
			
		on error errMsg
			display dialog "Error: " & errMsg buttons {"OK"} default button 1
			quit
		end try
	end if
end run

on idle
	return 30
end idle

on set_status(newText)
	if statusItem is not missing value then
		(statusItem's button()'s setTitle:(" " & (newText as text)))
	end if
end set_status

on rebuild_menu()
	try
		statusMenu's removeAllItems()
		
		set headerItem to (current application's NSMenuItem's alloc()'s initWithTitle:"Claude Code Status" action:missing value keyEquivalent:"")
		headerItem's setEnabled:false
		statusMenu's addItem:headerItem
		statusMenu's addItem:(current application's NSMenuItem's separatorItem())
		
		set quitItem to (current application's NSMenuItem's alloc()'s initWithTitle:"Quit CCMenuBar" action:"terminate:" keyEquivalent:"q")
		statusMenu's addItem:quitItem
	end try
end rebuild_menu

on quit
	if statusItem is not missing value then
		current application's NSStatusBar's systemStatusBar()'s removeStatusItem:statusItem
	end if
	continue quit
end quit
APPLESCRIPT
    
    # Compile the application
    osacompile -o "$APP_DIR/$APP_NAME.app" "$TEMP_DIR/CCMenuBar_temp.scpt" -s
    
    # Make it stay-open
    defaults write "$APP_DIR/$APP_NAME.app/Contents/Info.plist" LSUIElement -bool true
    defaults write "$APP_DIR/$APP_NAME.app/Contents/Info.plist" LSBackgroundOnly -bool false
    
    # Copy icon if exists
    if [ -f "$TEMP_DIR/claude_logo.png" ]; then
        cp "$TEMP_DIR/claude_logo.png" "$APP_DIR/$APP_NAME.app/Contents/Resources/"
        print_status "Icon installed"
    fi
}

install_cli() {
    print_status "Installing command-line tool..."
    
    # Create CLI wrapper
    cat > "$TEMP_DIR/ccmenubar" << 'SHELL'
#!/bin/bash
APP_NAME="CCMenuBar"

is_running() {
    osascript -e "tell application \"System Events\" to (name of processes) contains \"$APP_NAME\"" 2>/dev/null
}

ensure_running() {
    if is_running | grep -q "false"; then
        open -a "$APP_NAME" 2>/dev/null || {
            echo "Error: CCMenuBar.app not found. Please run installer again." >&2
            exit 1
        }
        sleep 1
    fi
}

case "$1" in
    --start)
        open -a "$APP_NAME"
        echo "CCMenuBar started"
        ;;
    --quit)
        osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null
        echo "CCMenuBar stopped"
        ;;
    --help)
        echo "Usage: ccmenubar \"status text\""
        echo "       ccmenubar --start    (launch app)"
        echo "       ccmenubar --quit     (quit app)"
        ;;
    "")
        echo "Usage: ccmenubar \"status text\""
        ;;
    *)
        ensure_running
        text="${1//\"/\\\"}"
        osascript -e "tell application \"$APP_NAME\" to set_status(\"$text\")" 2>/dev/null || {
            echo "Error: Failed to set status. Is CCMenuBar running?" >&2
            exit 1
        }
        ;;
esac
SHELL
    
    chmod +x "$TEMP_DIR/ccmenubar"
    
    # Install with appropriate permissions
    if [ -w "$INSTALL_DIR" ]; then
        cp "$TEMP_DIR/ccmenubar" "$INSTALL_DIR/"
    else
        print_warning "Need admin privileges to install CLI tool..."
        sudo cp "$TEMP_DIR/ccmenubar" "$INSTALL_DIR/"
    fi
}

setup_claude_code() {
    print_status "Setting up Claude Code integration..."
    
    # Create Claude settings directory if needed
    mkdir -p "$HOME/.claude"
    
    # Check if settings already exist
    if [ -f "$HOME/.claude/settings.json" ]; then
        print_warning "Claude Code settings already exist. Creating backup..."
        cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.backup.$(date +%s)"
    fi
    
    # Install hooks configuration
    if [ -f "$TEMP_DIR/claude_code_hooks_dropdown.json" ]; then
        cp "$TEMP_DIR/claude_code_hooks_dropdown.json" "$HOME/.claude/settings.json"
        print_status "Claude Code hooks installed"
    else
        # Create minimal hooks config
        cat > "$HOME/.claude/settings.json" << 'JSON'
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "ccmenubar \"⚙️ Working...\""
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "ccmenubar \"✅ Done!\""
      }]
    }]
  }
}
JSON
    fi
}

launch_app() {
    print_status "Launching CCMenuBar..."
    open "$APP_DIR/$APP_NAME.app"
    sleep 2
    
    # Test the CLI
    if ccmenubar "🎉 Installation Complete!" 2>/dev/null; then
        print_status "CLI tool working!"
    else
        print_warning "CLI tool installed but couldn't set initial status"
    fi
}

add_to_login_items() {
    print_status "Would you like CCMenuBar to start automatically at login?"
    read -p "Add to login items? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/CCMenuBar.app\", hidden:false}" 2>/dev/null
        print_status "Added to login items"
    fi
}

cleanup() {
    print_status "Cleaning up..."
    rm -rf "$TEMP_DIR"
}

uninstall() {
    print_warning "Uninstalling CCMenuBar..."
    
    # Quit app if running
    osascript -e "tell application \"CCMenuBar\" to quit" 2>/dev/null
    
    # Remove files
    rm -rf "$APP_DIR/$APP_NAME.app"
    rm -f "$INSTALL_DIR/ccmenubar"
    
    # Remove from login items
    osascript -e "tell application \"System Events\" to delete login item \"CCMenuBar\"" 2>/dev/null
    
    print_status "CCMenuBar uninstalled"
}

# Main installation flow
main() {
    print_header
    
    # Check for uninstall flag
    if [[ "$1" == "--uninstall" ]]; then
        uninstall
        exit 0
    fi
    
    print_status "Starting installation..."
    
    check_macos
    check_dependencies
    download_files
    compile_app
    install_cli
    setup_claude_code
    launch_app
    add_to_login_items
    cleanup
    
    echo ""
    print_status "🎉 Installation complete!"
    echo ""
    echo "Quick Start:"
    echo "  • CCMenuBar is now running in your menu bar"
    echo "  • Set status: ccmenubar \"Your status here\""
    echo "  • Get help: ccmenubar --help"
    echo ""
    echo "To uninstall: curl -sL [installer-url] | bash -s -- --uninstall"
    echo ""
}

# Handle errors
trap 'print_error "Installation failed. Cleaning up..."; cleanup; exit 1' ERR

# Run main installation
main "$@"
