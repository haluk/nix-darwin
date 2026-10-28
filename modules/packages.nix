{ pkgs, ... }:

{
  # Tools configured in home.nix (zsh, starship, zoxide, atuin, fzf, carapace,
  # bat, direnv, eza, git, difftastic, gnupg) are installed by home-manager.
  # Project-specific tools (compilers, SDKs, databases) belong in a per-project
  # flake/direnv or `nix shell nixpkgs#<pkg>`, not here.
  environment.systemPackages = with pkgs; [
    # Shells & Terminals
    nushell
    ghostty-bin

    # Editors & Version Control
    emacs
    (hunspell.withDicts (d: [ d.en_US ])) # Doom's spell module; the wrapper sets DICPATH
    pngpaste # Doom's org +dragndrop: paste clipboard images into org files
    plantuml # Doom's plantuml module; bundles its own JRE, separate from SDKMAN
    graphviz # dot: PlantUML renders most diagram types with it
    neovim
    lazygit
    lazydocker
    gitleaks

    # Doom Emacs language modules (`doom doctor` checks for these)
    pandoc # markdown preview, and org's +pandoc export
    cljfmt # clojure
    sbcl # common-lisp
    racket # racket: raco, drracket; `raco fmt` is installed by home.nix
    ocamlPackages.ocaml # ocaml: one package set so the tools match the compiler
    ocamlPackages.ocamlformat
    ocamlPackages.dune_3
    ocamlPackages.utop
    ocamlPackages.ocp-indent
    ocamlPackages.merlin

    # Development & Build Tools
    bun
    nodejs
    js-beautify # Doom's web module: formats JS/CSS/HTML
    stylelint # Doom's web module: lints CSS (uses the project's .stylelintrc)
    uv
    just
    cmake
    gnumake # Apple's make is 3.81 (2006); GNU make 4.x is a compatible superset
    mkcert
    editorconfig-core-c
    tree-sitter
    openssl
    watchexec

    # Container
    colima
    docker
    docker-compose
    docker-buildx
    docker-credential-helpers
    dockfmt # Dockerfile formatter; Doom's docker module uses it

    # Search, Filtering & Navigation
    ripgrep
    fd
    jq
    yq-go
    sd
    yazi

    # System Monitoring & Info
    fastfetch
    btop
    procs
    dust
    duf

    # Files & Archives (macOS tar is bsdtar: handles zip/tar.gz/tar.xz/tar.zst)
    _7zz # 7z/rar
    unar # rar for zsh's `extract` (its 7z case uses the 7za shim in dotfiles/zsh)
    zstd
    rsync # macOS ships the limited openrsync
    coreutils-prefixed # GNU tools as gls, gdate, ...; Doom's dired uses gls
    dos2unix
    shellcheck
    shfmt
    hyperfine
    tokei

    # Security & Networking
    age
    sops
    moreutils
    xh
    nmap
  ];
}
