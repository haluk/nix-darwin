# Packages only some machines want. Enabled by `optional = true;` in host.nix,
# which bootstrap.sh asks about. Add CLI tools to systemPackages, GUI apps to casks.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];

  # Merged with the casks in homebrew.nix. Without this module, `cleanup = "zap"`
  # uninstalls them on the next switch.
  homebrew.casks = [
    "claude-code" # cask, not nixpkgs: tracks Anthropic's releases closer than nixpkgs
  ];
}
