# CCMenuBar — Simple macOS Menu Bar Status Widget

This repo contains:
- `CCMenuBar.scpt` — AppleScriptObjC source for the menu-bar app
- `claude-logo.png` — icon shown in the menu bar
- `ccmenubar.sh` — shell helper used by hooks and from your terminal
- `settings.json` — ready-to-use Claude Code hooks configuration (feel free to customize)

---

## Setup (3–5 minutes)

### 1) Build the app
1. Open **Script Editor** → **File → Open…** → select `CCMenuBar.scpt`.
2. **File → Export…** → **File Format: Application** → check **Stay open after run handler** → save as `CCMenuBar.app`.  
   (Claude Code hooks live in `settings.json`; app and hooks settings are separate files.)  [oai_citation:0‡Claude Docs](https://docs.claude.com/en/docs/claude-code/settings?utm_source=chatgpt.com)

### 2) Add the icon
- Finder → right-click `CCMenuBar.app` → **Show Package Contents** → `Contents/Resources/`.
- Copy `claude-logo.png` into `Resources/`.  
  The script loads it from the bundle at runtime; the status item itself is created via AppKit’s `NSStatusItem`.  [oai_citation:1‡Apple Developer](https://developer.apple.com/documentation/appkit/nsstatusitem?utm_source=chatgpt.com)

### 3) Make the helper available in your shell
- Ensure the helper is executable and sourced:
  ```bash
  chmod +x ./ccmenubar.sh
  echo 'source /absolute/path/to/ccmenubar.sh' >> ~/.zshrc   # or ~/.bashrc

	•	Open a new shell and test:

ccmenubar "🟡 Idle"
ccmenubar "🟢 Running: Example"
ccmenubar "✅ DONE"



⸻

Claude Code hook integration

This repo includes a settings.json that wires up three hooks:
	•	PreToolUse → ccmenubar "🟢 Running: <tool_name>"
	•	Notification → ccmenubar "❗ ATTN!"
	•	Stop → ccmenubar "✅ DONE"

Claude Code looks for settings here (use either):
	•	User: ~/.claude/settings.json
	•	Project: .claude/settings.json (commit to share with teammates)  ￼

Install the provided settings

Pick one:

A. Project-local (recommended for repos):

mkdir -p .claude
cp settings.json .claude/settings.json

B. User-level:

mkdir -p ~/.claude
cp settings.json ~/.claude/settings.json

The file references the public schema to enable editor validation & autocomplete.  ￼

Requirements
	•	ccmenubar on your $PATH (or edit command to a full path).
	•	jq installed if you keep the PreToolUse variant that parses tool_name with jq. (You can swap to a Python inline parser if preferred.)
	•	Valid JSON (no trailing commas).
	•	Optional: add "timeout": 10 to each hook entry to avoid blocking.  ￼

Event references

Hook events supported include PreToolUse, Notification, and Stop; hooks receive JSON on stdin (your config already parses .tool_name for PreToolUse).  ￼

⸻

Appendix: Provided settings.json

Already in the repo; shown here for clarity.

{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "tool=$(echo \"$(cat)\" | jq -r .tool_name); ccmenubar \"🟢 Running: $tool\""
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "ccmenubar \"❗ ATTN!\""
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "ccmenubar \"✅ DONE\""
          }
        ]
      }
    ]
  }
}

Tip: if you don’t want a jq dependency, replace the PreToolUse command with:
tool=$(echo \"$(cat)\" | python3 -c 'import sys,json; print(json.load(sys.stdin).get(\"tool_name\",\"\"))'); ccmenubar \"🟢 Running: $tool\"  ￼

⸻

Troubleshooting
	•	If no update appears, confirm CCMenuBar.app is running (the app must stay open), the helper is sourced in your shell, and the settings file is in one of the recognized locations.  ￼
	•	Validate your JSON against the published schema to catch typos early.  ￼
