{ user, fullName, email, eza-themes, ... }: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak"; # move pre-existing dotfiles aside instead of failing

  home-manager.users.${user} = { config, lib, pkgs, ... }:
    let
      colimaSock = "${config.home.homeDirectory}/.colima/default/docker.sock";
      dockerPluginDirs = builtins.toJSON [
        "${pkgs.docker-compose}/libexec/docker/cli-plugins"
        "${pkgs.docker-buildx}/libexec/docker/cli-plugins"
      ];
    in
    {
      # Set once at first install, never bump: it pins home-manager's defaults
      # for stateful things, it is not the version you are running.
      home.stateVersion = "26.11";

      home.sessionVariables = {
        SDKMAN_DIR = "${config.home.homeDirectory}/.sdkman";
        # Docker CLI and Testcontainers talk to Colima's socket
        DOCKER_HOST = "unix://${colimaSock}";
        TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";
        EDITOR = "nvim";
        VISUAL = "nvim";
        PYTHONBREAKPOINT = "ipdb.set_trace";
        # Colored man pages: bat highlights the man syntax; col strips the backspace
        # overstrikes, and MANROFFOPT keeps groff from emitting them in the first place
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
        # -R lets less show colors; lesspipe only highlights (with bat) when it is set
        LESS = "-R";
      };

      # `uv tool install` puts its executables here (tools listed in uv-tools.txt)
      home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

      # Start OmniWM at login (replaces its own "Launch at login" toggle). A per-user
      # agent in ~/Library/LaunchAgents, so other accounts on this Mac don't get it.
      launchd.agents.omniwm = {
        enable = true;
        config = {
          ProgramArguments = [ "/usr/bin/open" "-a" "OmniWM" ];
          RunAtLoad = true;
        };
      };

      home.file."Pictures/Screenshots/.keep".text = "";
      home.file.".visidatarc".source = ../dotfiles/visidatarc;

      # Shell functions, one *.zsh file each, sourced by every new shell. Linked live
      # into the repo checkout (not copied to the read-only store), so files edited or
      # added in either place apply to the next shell without a switch. Assumes the
      # repo is cloned at ~/nix-darwin.
      xdg.configFile."zsh/functions".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-darwin/dotfiles/zsh";

      # One Dark from eza's official theme collection (flake input tracking main)
      xdg.configFile."eza/theme.yml".source = "${eza-themes}/themes/one_dark.yml";

      programs = {
        zsh = {
          enable = true;
          shellAliases = {
            ll = "eza -l";
            la = "eza -la";
            lt = "eza --tree";
            lg = "lazygit";
            vim = "nvim";
          };
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          # oh-my-zsh's extract plugin on its own (no framework): `extract`/`x` unpacks
          # any archive, with completion. Its .7z/.rar cases need unar (packages.nix).
          plugins = [{
            name = "extract";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/extract";
          }];
          # SDKMAN itself is installed by bootstrap.sh (it is not managed by Nix)
          initContent = ''
            [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
            for f in ~/.config/zsh/functions/*.zsh(N); do source "$f"; done
            unset f
            # Fancy `ls` for humans only: coding agents (Claude Code sets CLAUDECODE) keep
            # the system ls, whose flags (-t, -S, ...) eza does not accept
            [[ -z "$CLAUDECODE" ]] && alias ls='eza --group-directories-first'
            # `doom doctor` always warned "Your $PATH has changed": Doom's env file ends
            # exec-path with exec-directory (trailing slash), Emacs' startup value without
            # it. Emacs takes that last entry from EMACSPATH, so give it the slash too.
            # Globbed because the dir name holds the build's darwin version.
            emacs_libexec=(${pkgs.emacs}/libexec/emacs/*/*(N/))
            (( $#emacs_libexec )) && export EMACSPATH="$emacs_libexec[1]/"
            unset emacs_libexec
          '';
        };
        # less shows archive listings, PDFs, docs, ... instead of binary (sets LESSOPEN)
        lesspipe.enable = true;
        starship = {
          enable = true;
          # Starship's "Nerd Font Symbols" preset (shipped in the package, so it follows
          # starship upgrades), with λ as the prompt character
          settings = lib.recursiveUpdate
            (builtins.fromTOML (builtins.readFile
              "${pkgs.starship}/share/starship/presets/nerd-font-symbols.toml"))
            {
              character = {
                success_symbol = "[λ](bold blue)";
                error_symbol = "[λ](bold red)";
                vimcmd_symbol = "[λ](bold green)";
              };
            };
        };
        zoxide.enable = true;
        atuin.enable = true;
        # Atuin owns Ctrl-R; fzf keeps Ctrl-T (files) and Alt-C (cd)
        fzf = { enable = true; historyWidget.command = ""; };
        carapace.enable = true;
        bat.enable = true;
        direnv = { enable = true; nix-direnv.enable = true; };
        # The app itself is ghostty-bin in packages.nix (linked into /Applications)
        ghostty = {
          enable = true;
          package = null;
          settings = {
            theme = "Atom One Dark";
            # Ghostty bundles the Nerd Font symbols, so the unpatched font is enough
            font-family = "Cascadia Code";
            font-size = 14;
            font-thicken = true;
            # Cascadia's coding ligatures live in calt, not just liga
            font-feature = [ "-calt" "-liga" "-dlig" ];

            # OmniWM tiles the window: no title bar, no native fullscreen
            window-decoration = "none";
            window-padding-x = 4;
            window-padding-y = 4;
            window-padding-balance = true;
            window-save-state = "never";

            # st-like: steady block cursor, quit with the last window, no prompts
            cursor-style = "block";
            cursor-style-blink = false;
            shell-integration-features = "no-cursor";
            mouse-hide-while-typing = true;
            confirm-close-surface = false;
            quit-after-last-window-closed = true;

            # Option is Alt (US layout; OmniWM grabs its own Option hotkeys first)
            macos-option-as-alt = true;

            # Every window attaches to the "main" tmux session, creating it if needed.
            # Via a login shell, so the tmux server (and the plugin scripts it runs)
            # gets the Nix/Homebrew PATH, not just /usr/bin:/bin.
            command = "/bin/zsh -lc 'exec tmux new-session -A -s main'";

            copy-on-select = "clipboard";
            clipboard-write = "allow";
            # Reading the clipboard via OSC 52 is opt-in per request (ssh, remote tools)
            clipboard-read = "ask";

            # Nix owns the app bundle, so the built-in updater must stay off
            auto-update = "off";
          };
        };

        # The rest of the config, theme and plugin list are in dotfiles/tmux.conf;
        # the plugins themselves come from TPM (home.activation.tmuxPlugins)
        tmux = {
          enable = true;
          terminal = "tmux-256color";
          mouse = true;
          keyMode = "vi";
          baseIndex = 1;
          escapeTime = 10;
          historyLimit = 100000;
          focusEvents = true;
          clock24 = true;
          # prefix h/j/k/l moves between panes, H/J/K/L resizes them
          customPaneNavigationAndResize = true;
          resizeAmount = 5;
          extraConfig = builtins.readFile ../dotfiles/tmux.conf;
        };

        # The `ls` alias is set in zsh initContent so coding agents keep the system ls
        eza = {
          enable = true;
          enableZshIntegration = false;
          git = true;
          icons = "auto";
        };

        git = {
          enable = true;
          settings = {
            user.name = fullName; # from host.nix, asked by bootstrap.sh
            user.email = email; # from host.nix, asked by bootstrap.sh
            init.defaultBranch = "main";
            pull.rebase = true;
            rebase.autoStash = true;
            push.autoSetupRemote = true;
            fetch.prune = true;
          };
          # Sign commits with the SSH key (created by bootstrap.sh); no GPG key needed
          signing = {
            format = "ssh";
            key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
            signByDefault = true;
          };
          ignores = [ ".DS_Store" ".direnv/" ".envrc.local" ];
        };
        difftastic = { enable = true; git.enable = true; };

        ssh = {
          enable = true;
          package = null; # keep Apple's ssh for Keychain integration
          enableDefaultConfig = false;
          settings."*" = {
            AddKeysToAgent = "yes";
            UseKeychain = "yes";
          };
        };

        # GPG for encrypting/signing files; the agent caches your passphrase and
        # pinentry-mac shows the passphrase prompt as a native macOS dialog.
        gpg.enable = true;
      };

      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry_mac;
        defaultCacheTtl = 3600;
      };

      # OmniWM rewrites its settings when you change them in the app, so seed a
      # writable copy once instead of linking a read-only file. To carry later
      # changes to new machines, copy the file back into dotfiles/.
      home.activation.omniwmSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cfg="$HOME/.config/omniwm/settings.toml"
        if [[ ! -e $cfg ]]; then
          run install -D -m 644 ${../dotfiles/omniwm-settings.toml} "$cfg"
        fi
      '';

      # LazyVim starter, installed the way its docs say: back up any existing Neovim
      # files to *.bak, clone github.com/LazyVim/starter, drop its .git so it can go in
      # your own repo. Skipped once ~/.config/nvim is a LazyVim config; plugins install
      # on the first `nvim` launch.
      home.activation.lazyvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        nvim_cfg="$HOME/.config/nvim"
        if ! grep -qs LazyVim/LazyVim "$nvim_cfg/lua/config/lazy.lua"; then
          for dir in "$nvim_cfg" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
            if [[ -e $dir ]]; then
              bak="$dir.bak"
              [[ -e $bak ]] && bak="$dir.bak-$(date +%Y%m%d-%H%M%S)" # keep an older backup
              run mv "$dir" "$bak"
            fi
          done
          run mkdir -p "$HOME/.config"
          if run ${lib.getExe pkgs.git} clone --quiet https://github.com/LazyVim/starter "$nvim_cfg"; then
            run rm -rf "$nvim_cfg/.git"
          else
            warnEcho "Cloning the LazyVim starter failed (offline?); re-run make switch"
          fi
        fi
      '';

      # PyPI CLI tools: Nix packages them poorly, uv keeps each in its own venv.
      # Already-installed tools are skipped; `make upgrade` updates them.
      home.activation.uvTools = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        lib.concatMapStrings (spec: ''
          run ${lib.getExe pkgs.uv} tool install ${spec} \
            || warnEcho "uv tool install ${spec} failed (offline?); retry with: make tools"
        '') (builtins.filter (l: l != "" && !lib.hasPrefix "#" l)
          (lib.splitString "\n" (builtins.readFile ../uv-tools.txt)))
      );

      # TPM and the plugins listed in dotfiles/tmux.conf, cloned the way TPM names
      # them ('user/repo#branch' -> plugins/repo). TPM's install_plugins can't do
      # this: it needs a running tmux server that has loaded TPM. Installed ones are
      # skipped; `make upgrade` updates them.
      home.activation.tmuxPlugins = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        export PATH="${lib.makeBinPath [ pkgs.git ]}:$PATH"
        while read -r spec; do
          repo=''${spec%%#*}
          dir="$HOME/.config/tmux/plugins/''${repo##*/}"
          [[ -d $dir ]] && continue
          branch=()
          [[ $spec == *#* ]] && branch=(--branch "''${spec#*#}")
          run git clone --quiet --single-branch --recursive "''${branch[@]}" \
              "https://github.com/$repo" "$dir" 2>/dev/null \
            || warnEcho "Cloning tmux plugin $repo failed (offline?); re-run make switch"
        done < <(sed -nE "s/^set -g @plugin '([^']+)'.*/\1/p" ${../dotfiles/tmux.conf})
      '';

      # `raco fmt` (Doom's racket formatter) is a Racket package, not in nixpkgs.
      # User-scope, so a new Racket version reinstalls it; installed ones are skipped.
      home.activation.racketFmt = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${pkgs.racket}/bin/raco pkg install --auto --batch --user --skip-installed fmt \
          || warnEcho "raco pkg install fmt failed (offline?); retry with: make tools"
      '';

      # Fonts copied from the Nix store keep a 1970 mtime, so fontconfig would
      # trust its stale cache and miss newly added fonts (fc-list, doom doctor).
      home.activation.fontconfigCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${pkgs.fontconfig.bin}/bin/fc-cache -f
      '';

      # ~/.docker/config.json must stay writable (docker login, colima contexts),
      # so merge our keys into it instead of symlinking a read-only file.
      home.activation.dockerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cfg="$HOME/.docker/config.json"
        current=$([[ -s $cfg ]] && cat "$cfg" || echo '{}')
        new=$(${lib.getExe pkgs.jq} --argjson dirs ${lib.escapeShellArg dockerPluginDirs} \
          '.cliPluginsExtraDirs = $dirs | .credsStore = "osxkeychain"' <<<"$current")
        if [[ $new != "$current" ]]; then
          run mkdir -p "$HOME/.docker"
          [[ -v DRY_RUN ]] || printf '%s\n' "$new" > "$cfg"
        fi
      '';
    };
}
