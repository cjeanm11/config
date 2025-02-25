#!/usr/bin/env bash

# Warn if not run as root
if [[ $EUID -ne 0 ]]; then
  RUN_AS_ROOT=false
  echo "Run with sudo for full functionality." | fold -s -w 80
else
  RUN_AS_ROOT=true
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Disable smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Set desktop background
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/System/Library/Desktop Pictures/Solid Colors/Stone.png"'

# Restart on freeze
if [[ "$RUN_AS_ROOT" = true ]]; then
  systemsetup -setrestartfreeze on
fi

###############################################################################
# Trackpad, Keyboard & Input                                                 #
###############################################################################

# Disable press-and-hold for keys, enable key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain InitialKeyRepeat -int 20
defaults write NSGlobalDomain KeyRepeat -int 1

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable spotlight shortcuts
defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array></dict></dict>"

###############################################################################
# Finder                                                                      #
###############################################################################

# Show hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Set Finder preferences
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder QLEnableTextSelection -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Remove empty trash warning
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Hide library folder and desktop icons
chflags nohidden ~/Library
defaults write com.apple.finder CreateDesktop -bool false

###############################################################################
# Dock & Hot Corners                                                          #
###############################################################################

# Set Dock preferences
defaults write com.apple.dock tilesize -int 45
defaults write com.apple.dock expose-animation-duration -float 0.15
defaults write com.apple.dock showhidden -bool true
defaults write com.apple.dock autohide -bool true

# Disable hot corners
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Set Activity Monitor preferences
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor ShowCategory -int 0

###############################################################################
# App Store                                                                   #
###############################################################################

# Disable in-app rating requests
defaults write com.apple.appstore InAppReviewEnabled -int 0

###############################################################################
# Kill/restart affected applications                                          #
###############################################################################

# Restart apps unless --no-restart is provided
if [[ ! ($* == *--no-restart*) ]]; then
  for app in "cfprefsd" "Dock" "Finder" "Mail" "SystemUIServer" "Terminal"; do
    killall "${app}" > /dev/null 2>&1
  done
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
fi

echo "Log out and log back in for changes to take effect."
