# Packages only some machines want. Enabled by `optional = true;` in host.nix,
# which bootstrap.sh asks about. Add CLI tools to systemPackages, GUI apps to casks.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dbeaver-bin
    jetbrains.idea
    opencode
    # nixpkgs installs shaders/configs into Contents/MacOS, but sioyek looks in
    # Contents/Resources; without the shaders it renders blank pages.
    (sioyek.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + lib.optionalString stdenv.hostPlatform.isDarwin ''
        app=$out/Applications/sioyek.app/Contents
        for f in shaders prefs.config keys.config tutorial.pdf; do
          [ -e "$app/Resources/$f" ] || ln -s "../MacOS/$f" "$app/Resources/$f"
        done
      '';
    }))
  ];

  # Merged with the casks in homebrew.nix. Without this module, `cleanup = "zap"`
  # uninstalls them on the next switch.
  homebrew.casks = [
    # "claude-code" # cask, not nixpkgs: tracks Anthropic's releases closer than nixpkgs
  ];
}
