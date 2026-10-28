# nix-darwin

Declarative setup for an Apple Silicon MacBook: nix-darwin + home-manager + nix-homebrew,
on Determinate Nix.

## Layout

| File | What it owns |
|---|---|
| `host.nix` | Username, hostname, git name and email, time zone and whether to install optional packages (written by `bootstrap.sh`; gitignored, so it stays on the machine) |
| `flake.nix` | Inputs; the configuration is named after the hostname |
| `modules/system.nix` | Nix/GC, hostname, Touch ID sudo, time zone (from `host.nix`), system zsh |
| `modules/defaults.nix` | macOS defaults (Dock, Finder, keyboard, trackpad, ...) |
| `modules/packages.nix` | System-wide CLI tools |
| `modules/fonts.nix` | Fonts |
| `modules/homebrew.nix` | Homebrew itself (nix-homebrew) and GUI casks |
| `modules/optional.nix` | Packages only some machines want (claude-code); on when `optional = true` |
| `modules/home.nix` | Dotfiles: zsh, git, ssh, gpg, Docker/Colima, SDKMAN hook, LazyVim starter |
| `dotfiles/` | Plain files linked into `~` or read into `~/.zshrc`: `zsh/` (shell functions, one `*.zsh` each, linked live so edits apply without a switch), `visidatarc`, `omniwm-settings.toml` (copied only if missing) |
| `Makefile` | Common actions; run `make` for the list |

## Fresh install

```sh
xcode-select --install                 # provides git; wait for it to finish
git clone <this-repo> ~/nix-darwin
cd ~/nix-darwin
make bootstrap                         # or ./bootstrap.sh
```

`bootstrap.sh` is idempotent and runs, in order:

0. Asks for username (default: `whoami`), hostname, git name and email (e.g. your GitHub noreply
   address), time zone and whether to install the optional packages in `modules/optional.nix`, then
   writes `host.nix`
1. Xcode Command Line Tools
2. Rosetta (needed for amd64 images in Colima)
3. Determinate Nix
4. First `darwin-rebuild switch` (sets the hostname; installs Homebrew, casks, home-manager,
   and the uv tools listed in `uv-tools.txt` into `~/.local/bin`)
5. SDKMAN
6. SSH key at `~/.ssh/id_ed25519`, stored in the Keychain

Then:

- OmniWM's settings are seeded from `dotfiles/omniwm-settings.toml` on first install; after
  changing them in the app, `make omniwm` copies them back into the repo.
- Neovim gets the [LazyVim starter](https://github.com/LazyVim/starter): if `~/.config/nvim`
  is not a LazyVim config yet, a switch moves it and `~/.local/{share,state}/nvim` and
  `~/.cache/nvim` to `*.bak`, clones the starter and removes its `.git`. Plugins install on
  the first `nvim` launch. After that the config is yours and switches leave it alone.
- Grant OmniWM Accessibility (required) and Screen Recording (Overview thumbnails); bootstrap
  opens both Settings panes. Then log out and back in so "Displays have separate Spaces"
  (which OmniWM requires) takes effect. A launchd agent starts OmniWM at login.
- Add `~/.ssh/id_ed25519.pub` to your git host as both an authentication and a signing key.
- `sdk install java` (plus `sdk install maven` / `gradle` as needed).

## Renaming the machine

Re-run `./bootstrap.sh` (or edit `host.nix`), then switch; nix-darwin applies the new
hostname.

## Daily use

```sh
make switch    # apply changes
make diff      # what the next switch would change
make update    # bump nixpkgs/home-manager/nix-darwin, then `make switch`
make upgrade   # update casks and uv tools (never automatic)
make clean     # clear Nix/Homebrew/uv caches; `make gc` also drops generations older than 7 days
make           # everything else (rollback, uninstall, ...)
```

To turn optional packages on or off, set `optional` in `host.nix` (or re-run bootstrap),
then `make switch`. With it off, `cleanup = "zap"` removes their casks.

The Makefile builds the flake as `path:<repo>`, not from git, so the untracked `host.nix`
(and any new file) is seen without `git add`. Building by hand: `darwin-rebuild build --flake path:.`

## Conventions

- **Project tools stay per project.** Use a `flake.nix` + `.envrc` (`use flake`) via direnv,
  or `nix shell nixpkgs#<pkg>` for one-offs, instead of adding to `packages.nix`.
- **Homebrew is for GUI apps only**, and `cleanup = "zap"` removes any cask not listed in
  `homebrew.nix`. Add apps there, not with `brew install`.
- **BSD userland is untouched.** No GNU coreutils/sed/grep shadowing, so scripts and coding
  agents get standard macOS behaviour. `ls` is the system ls; `ll`/`la`/`lt` use eza.
- **Python** via `uv` (`uv python install`, `uv tool install ruff`); no global python.
- **Java** via SDKMAN; **JS/Svelte** via bun (node is kept for language servers/Prettier).

## Docker

Colima is not started at login. Create the VM once, then start/stop it as needed:

```sh
colima start --vm-type vz --vz-rosetta --cpu 4 --memory 8   # first time; settings are saved
colima start / colima stop                                 # afterwards
```

`docker compose` and `docker buildx` are wired up through `~/.docker/config.json`, and
`DOCKER_HOST`/`TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE` are set for Testcontainers.
Change the VM size: `colima stop && colima delete`, then create it again with new flags.

## GC

Determinate Nix owns `nix.conf` (`nix.enable = false`). A weekly launchd job
(Sunday 02:00) runs `nix-collect-garbage --delete-older-than 30d`.
