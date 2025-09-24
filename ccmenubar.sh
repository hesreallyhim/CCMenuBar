# Put in ~/.zshrc or ~/.bashrc, then:  source ~/.zshrc
CCMenuBar() {
  local app="CCMenuBar"           # your exported .app’s name (without .app)
  local msg="$*"
  msg=${msg//\"/\\\"}             # escape double quotes for osascript


  # If not running, launch it (non-blocking) and wait up to ~3s
  # UNCOMMENT THE FOLLOWING LINES TO AUTOMATICALLY
  # START THE MENUBAR WHEN TRIGGERED, IF NOT ALREADY RUNNING
  # if ! pgrep -x "$app" >/dev/null; then
  #   open -a "$app" >/dev/null 2>&1
  #   for _ in 1 2 3 4 5 6; do
  #     pgrep -x "$app" >/dev/null && break
  #     sleep 0.5
  #   done
  # fi

  # If running, send the status; otherwise warn
  if pgrep -x "$app" >/dev/null; then
    osascript -e "tell application \"$app\" to set_status \"${msg}\""
  else
    echo "Warning: $app is not running (launch may have failed)" >&2
    return 1
  fi
}
