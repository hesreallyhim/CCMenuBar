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
			-- Load bundled icon (placed in Contents/Resources)
			set rPath to POSIX path of (path to resource "claude-logo.png")
			set img to (current application's NSImage's alloc()'s initWithContentsOfFile:rPath)
			
			if img is not missing value then
				img's setSize:(current application's NSMakeSize(16, 16))
				img's setTemplate:true -- Enable dark mode support
			end if
			
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
			
			-- Add default menu items
			rebuild_menu()
			
			-- Attach menu to status item
			statusItem's setMenu:statusMenu
			
			set isRunning to true
			
		on error errMsg
			display dialog "Error initializing status item: " & errMsg buttons {"OK"} default button 1
			quit
		end try
	end if
end run

-- Keep the app running
on idle
	return 30 -- Check every 30 seconds
end idle

-- Set the main status text
on set_status(newText)
	if statusItem is not missing value then
		(statusItem's button()'s setTitle:(" " & (newText as text)))
	else
		run
		if statusItem is not missing value then
			(statusItem's button()'s setTitle:(" " & (newText as text)))
		end if
	end if
end set_status

-- Add a todo item to the menu
on add_todo(todoText, todoStatus)
	try
		set todoItem to {text:todoText as text, status:todoStatus as text, timestamp:((current date) as string)}
		set end of todoItems to todoItem
		rebuild_menu()
	on error errMsg
		log "Error adding todo: " & errMsg
	end try
end add_todo

-- Clear all todos
on clear_todos()
	set todoItems to {}
	rebuild_menu()
end clear_todos

-- Add a recent file to the menu
on add_recent_file(filePath, fileAction)
	try
		-- Extract just the filename
		set fileName to do shell script "basename " & quoted form of (filePath as text)
		set fileItem to {name:fileName, path:filePath as text, action:fileAction as text, timestamp:((current date) as string)}
		
		-- Keep only last 10 files
		if (count of recentFiles) ≥ 10 then
			set recentFiles to items 2 thru -1 of recentFiles
		end if
		set end of recentFiles to fileItem
		rebuild_menu()
	on error errMsg
		log "Error adding recent file: " & errMsg
	end try
end add_recent_file

-- Clear recent files
on clear_recent_files()
	set recentFiles to {}
	rebuild_menu()
end clear_recent_files

-- Add a current task
on add_task(taskName, taskStatus)
	try
		set taskItem to {name:taskName as text, status:taskStatus as text}
		set end of currentTasks to taskItem
		rebuild_menu()
	on error errMsg
		log "Error adding task: " & errMsg
	end try
end add_task

-- Clear all tasks
on clear_tasks()
	set currentTasks to {}
	rebuild_menu()
end clear_tasks

-- Set a custom menu section
on set_menu_section(sectionName, itemsList)
	try
		-- Store custom section
		set menuItems to {}
		repeat with itemText in itemsList
			set end of menuItems to (itemText as text)
		end repeat
		rebuild_menu()
	on error errMsg
		log "Error setting menu section: " & errMsg
	end try
end set_menu_section

-- Clear custom menu items
on clear_menu()
	set menuItems to {}
	rebuild_menu()
end clear_menu

-- Rebuild the entire menu
on rebuild_menu()
	try
		-- Clear existing menu
		statusMenu's removeAllItems()
		
		-- Add header
		set headerItem to (current application's NSMenuItem's alloc()'s initWithTitle:"Claude Code Status" action:missing value keyEquivalent:"")
		headerItem's setEnabled:false
		statusMenu's addItem:headerItem
		statusMenu's addItem:(current application's NSMenuItem's separatorItem())
		
		-- Add current tasks section if any
		if (count of currentTasks) > 0 then
			set tasksHeader to (current application's NSMenuItem's alloc()'s initWithTitle:"📋 Current Tasks" action:missing value keyEquivalent:"")
			tasksHeader's setEnabled:false
			statusMenu's addItem:tasksHeader
			
			repeat with taskItem in currentTasks
				set taskText to "  " & (status of taskItem) & " " & (name of taskItem)
				set taskMenuItem to (current application's NSMenuItem's alloc()'s initWithTitle:taskText action:missing value keyEquivalent:"")
				statusMenu's addItem:taskMenuItem
			end repeat
			statusMenu's addItem:(current application's NSMenuItem's separatorItem())
		end if
		
		-- Add todos section if any
		if (count of todoItems) > 0 then
			set todoHeader to (current application's NSMenuItem's alloc()'s initWithTitle:"✅ Todo List" action:missing value keyEquivalent:"")
			todoHeader's setEnabled:false
			statusMenu's addItem:todoHeader
			
			repeat with todoItem in todoItems
				set todoText to "  " & (status of todoItem) & " " & (text of todoItem)
				set todoMenuItem to (current application's NSMenuItem's alloc()'s initWithTitle:todoText action:missing value keyEquivalent:"")
				statusMenu's addItem:todoMenuItem
			end repeat
			statusMenu's addItem:(current application's NSMenuItem's separatorItem())
		end if
		
		-- Add recent files section if any
		if (count of recentFiles) > 0 then
			set filesHeader to (current application's NSMenuItem's alloc()'s initWithTitle:"📁 Recent Files" action:missing value keyEquivalent:"")
			filesHeader's setEnabled:false
			statusMenu's addItem:filesHeader
			
			repeat with fileItem in recentFiles
				set fileText to "  " & (action of fileItem) & " " & (name of fileItem)
				set fileMenuItem to (current application's NSMenuItem's alloc()'s initWithTitle:fileText action:"openFile:" keyEquivalent:"")
				fileMenuItem's setRepresentedObject:(path of fileItem)
				fileMenuItem's setTarget:me
				statusMenu's addItem:fileMenuItem
			end repeat
			statusMenu's addItem:(current application's NSMenuItem's separatorItem())
		end if
		
		-- Add custom menu items if any
		if (count of menuItems) > 0 then
			set customHeader to (current application's NSMenuItem's alloc()'s initWithTitle:"📌 Info" action:missing value keyEquivalent:"")
			customHeader's setEnabled:false
			statusMenu's addItem:customHeader
			
			repeat with itemText in menuItems
				set customMenuItem to (current application's NSMenuItem's alloc()'s initWithTitle:("  " & itemText) action:missing value keyEquivalent:"")
				statusMenu's addItem:customMenuItem
			end repeat
			statusMenu's addItem:(current application's NSMenuItem's separatorItem())
		end if
		
		-- Add refresh item
		set refreshItem to (current application's NSMenuItem's alloc()'s initWithTitle:"🔄 Refresh" action:"refreshMenu:" keyEquivalent:"r")
		refreshItem's setTarget:me
		statusMenu's addItem:refreshItem
		
		-- Add separator before quit
		statusMenu's addItem:(current application's NSMenuItem's separatorItem())
		
		-- Add quit item
		set quitItem to (current application's NSMenuItem's alloc()'s initWithTitle:"Quit CCMenuBar" action:"terminate:" keyEquivalent:"q")
		statusMenu's addItem:quitItem
		
	on error errMsg
		log "Error rebuilding menu: " & errMsg
	end try
end rebuild_menu

-- Handle file opening (when clicking on a recent file)
on openFile:sender
	try
		set filePath to sender's representedObject() as text
		do shell script "open " & quoted form of filePath
	on error errMsg
		log "Error opening file: " & errMsg
	end try
end openFile:

-- Handle menu refresh
on refreshMenu:sender
	rebuild_menu()
end refreshMenu:

-- Clean up on quit
on quit
	if statusItem is not missing value then
		current application's NSStatusBar's systemStatusBar()'s removeStatusItem:statusItem
	end if
	continue quit
end quit
