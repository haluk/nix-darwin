{ user, ... }:

{
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "WhenScrolling";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.swipescrolldirection" = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      ApplePressAndHoldEnabled = false;
      AppleKeyboardUIMode = 3;
      NSWindowShouldDragOnGesture = true;
      NSAutomaticWindowAnimationsEnabled = false;
      NSScrollAnimationEnabled = true;
      AppleICUForce24HourTime = true;
      _HIHideMenuBar = false;
      NSWindowResizeTime = 0.001; # sheets (save/print dialogs) appear instantly
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.15;
      tilesize = 36;
      mineffect = "scale";
      launchanim = false;
      show-recents = false;
      mru-spaces = false;
      orientation = "bottom";
      minimize-to-application = true;
      showhidden = true;
      static-only = false;
      expose-group-apps = true;
      # Minimal Dock: replaces every default icon on each rebuild.
      # Finder and Trash are pinned by macOS and always present.
      persistent-apps = [ ];
      persistent-others = [
        { folder = { path = "/Users/${user}/Downloads"; arrangement = "date-added"; }; }
      ];
    };

    finder = {
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv"; # Column view (good for navigation)
      FXDefaultSearchScope = "SCcf"; # Search current folder
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      QuitMenuItem = true;
      FXRemoveOldTrashItems = true; # empty Trash items after 30 days
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
    };

    LaunchServices.LSQuarantine = false; # no "downloaded from the internet" prompt

    screencapture.location = "/Users/${user}/Pictures/Screenshots";

    loginwindow.GuestEnabled = false;

    # Inverted name: false = "Displays have separate Spaces" ON, which OmniWM requires
    # (it pauses otherwise). Takes effect after logout.
    spaces.spans-displays = false;

    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      GloballyEnabled = false;
    };

    ActivityMonitor = {
      ShowCategory = 100; # All Processes
      SortColumn = "CPUUsage";
      SortDirection = 0; # Descending
    };

    CustomUserPreferences = {
      NSGlobalDomain = {
        WebKitDeveloperExtras = true;
        # Animation tweaks with no typed nix-darwin option
        NSBrowserColumnAnimationSpeedMultiplier = 0.0; # Finder column view
        QLPanelAnimationDuration = 0.0; # Quick Look
        NSToolbarFullScreenAnimationDuration = 0.0; # title bar reveal in full screen
        NSDocumentRevisionsWindowTransformAnimation = false; # Browse All Versions
      };
      "com.apple.finder".DisableAllAnimations = true;
      # What System Settings' "Automatically hide and show the menu bar" reads;
      # keep in sync with _HIHideMenuBar. 0=Always 1=Desktop only 2=Full screen only 3=Never
      "com.apple.controlcenter".AutoHideMenuBarOption = 3;
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };

  system.keyboard = { enableKeyMapping = true; remapCapsLockToEscape = true; };

  system.startup.chime = false;

}
