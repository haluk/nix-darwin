{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    cascadia-code # Ghostty
    nerd-fonts.roboto-mono
    nerd-fonts.symbols-only
    source-code-pro
    fira-sans
    (google-fonts.override { fonts = [ "RedditMono" ]; }) # not packaged on its own
    symbola # Emacs' last-resort fallback font; `doom doctor` checks for it (unfree)
  ];

  # fc-list for `doom doctor` (font checks). Nix's fontconfig reads
  # /etc/fonts/fonts.conf, which macOS lacks; point it at the macOS font
  # folders (nix-darwin installs fonts.packages into /Library/Fonts/Nix Fonts).
  environment.systemPackages = [ pkgs.fontconfig ];
  environment.etc."fonts/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <include>${pkgs.fontconfig.out}/etc/fonts/fonts.conf</include>
      <dir>/System/Library/Fonts</dir>
      <dir>/Library/Fonts</dir>
      <dir>~/Library/Fonts</dir>
    </fontconfig>
  '';
}
