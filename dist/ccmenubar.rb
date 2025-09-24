class Ccmenubar < Formula
  desc "Claude Code status tracker for macOS menu bar"
  version "1.0.0"
  homepage "https://github.com/hesreallyhim/ccmenubar"
  url "https://github.com/hesreallyhim/ccmenubar/archive/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"
  
  depends_on :macos
  depends_on "jq"
  
  def install
    # Install the CLI tool
    bin.install "ccmenubar_enhanced" => "ccmenubar"
    
    # Create the app bundle
    app_dir = prefix/"CCMenuBar.app"
    app_contents = app_dir/"Contents"
    app_macos = app_contents/"MacOS"
    app_resources = app_contents/"Resources"
    
    # Create app structure
    app_macos.mkpath
    app_resources.mkpath
    
    # Compile the AppleScript
    system "osacompile", "-o", app_dir, "CCMenuBar_Enhanced.scpt"
    
    # Copy resources
    app_resources.install "claude_logo.png" if File.exist?("claude_logo.png")
    
    # Install the app to Applications
    ln_sf app_dir, "/Applications/CCMenuBar.app"
    
    # Install Claude Code hooks example
    (share/"ccmenubar").install "claude_code_hooks_dropdown.json"
    
    # Install documentation
    doc.install "README.md"
  end
  
  def post_install
    ohai "CCMenuBar installed successfully!"
    ohai "To get started:"
    ohai "  1. Launch: open /Applications/CCMenuBar.app"
    ohai "  2. Set status: ccmenubar 'Hello World'"
    ohai "  3. Claude Code hooks example: #{share}/ccmenubar/claude_code_hooks_dropdown.json"
  end
  
  def caveats
    <<~EOS
      CCMenuBar has been installed and linked to /Applications.
      
      Quick start:
        ccmenubar --start           # Launch the app
        ccmenubar "Status text"     # Set status
        ccmenubar --help           # Get help
      
      To install Claude Code hooks:
        cp #{share}/ccmenubar/claude_code_hooks_dropdown.json ~/.claude/settings.json
      
      To add to login items:
        System Preferences > Users & Groups > Login Items > Add CCMenuBar.app
    EOS
  end
  
  test do
    assert_match "Usage", shell_output("#{bin}/ccmenubar --help")
  end
end
