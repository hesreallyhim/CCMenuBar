use AppleScript version "2.8"
use framework "AppKit"
use framework "Foundation"
use scripting additions

property statusItem : missing value
property isRunning : false
property appVersion : "1.0.0"

on run
    -- Only initialize if not already running
    if not isRunning then
        try
            -- Load bundled icon (placed in Contents/Resources)
            set rPath to POSIX path of (path to resource "claude_logo.png")
            set img to (current application's NSImage's alloc()'s initWithContentsOfFile:rPath)
            
            if img is not missing value then
                img's setSize:(current application's NSMakeSize(16, 16))
                img's setTemplate:true -- Enable dark mode support
            end if
            
            -- Create the menu-bar item (icon + text)
            set bar to current application's NSStatusBar's systemStatusBar()
            set statusItem to bar's statusItemWithLength:(current application's NSVariableStatusItemLength)
            
            if img is not missing value then
                (statusItem's button()'s setImage:img)
            end if
            
            (statusItem's button()'s setTitle:" CLAUDE")
            (statusItem's button()'s setFont:(current application's NSFont's systemFontOfSize:12))
            
            set isRunning to true
            
        on error errMsg
            display dialog "Error initializing status item: " & errMsg buttons {"OK"} default button 1
            quit
        end try
    end if
end run

-- Keep the app running
on idle
    -- Return number of seconds until next idle call
    return 30 -- Check every 30 seconds
end idle

-- Called from shell: osascript -e "tell application \"CCMenuBar\" to set_status(\"Test\")"
on set_status(newText)
    if statusItem is not missing value then
        (statusItem's button()'s setTitle:(" " & (newText as text)))
    else
        -- If not initialized, run first then set status
        run
        if statusItem is not missing value then
            (statusItem's button()'s setTitle:(" " & (newText as text)))
        end if
    end if
end set_status

-- Clean up on quit
on quit
    if statusItem is not missing value then
        current application's NSStatusBar's systemStatusBar()'s removeStatusItem:statusItem
    end if
    continue quit
end quit
