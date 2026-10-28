{ user, ... }: {
  # nix-homebrew installs and owns Homebrew itself; no manual install needed
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true; # adopt an existing /opt/homebrew if one is already there
    # Its integration runs `brew shellenv` in /etc/zshrc, i.e. in every interactive
    # shell, which moves Homebrew ahead of SDKMAN/carapace in nested shells only.
    # A PATH that depends on nesting made `doom doctor` warn in new terminals.
    enableZshIntegration = false;
  };

  # Once per login shell instead; nested shells inherit the result unchanged
  programs.zsh.loginShellInit = ''eval "$(brew shellenv 2>/dev/null || true)"'';

  homebrew = {
    enable = true;
    # Nothing updates behind your back: run `brew update && brew upgrade` when you choose to.
    global.autoUpdate = false;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap"; # anything not listed below is uninstalled
    };
    casks = [
      "omniwm" # cask, not nixpkgs: fixed /Applications path keeps the Accessibility permission across updates
      "google-chrome"
    ];
  };
}
