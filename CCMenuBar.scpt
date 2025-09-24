use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property statusItem : missing value

on run
	set bundle to current application's NSBundle's mainBundle()
	set p to bundle's pathForResource:ofType_("claude-logo", "png")
	if p = missing value then error "claude-logo.png not found in Contents/Resources"
	
	set img to (current application's NSImage's alloc()'s initWithContentsOfFile:p)
	img's setSize:(current application's NSMakeSize(16, 16))
	img's setTemplate:false -- keep the original color
	
	set bar to current application's NSStatusBar's systemStatusBar()
	set statusItem to bar's statusItemWithLength:(current application's NSVariableStatusItemLength)
	(statusItem's button()'s setImage:img)
	(statusItem's button()'s setTitle:" CLAUDE")
	(statusItem's button()'s setFont:(current application's NSFont's systemFontOfSize:12))
end run

on set_status(newText)
	(statusItem's button()'s setTitle:(" " & (newText as text)))
end set_status
