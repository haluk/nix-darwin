#!/usr/bin/env bash
# Bootstrap a fresh Mac with this nix-darwin config. Safe to re-run.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX=/nix/var/nix/profiles/default/bin/nix

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

[[ $(uname -m) == arm64 ]] || { echo "This config targets Apple Silicon only." >&2; exit 1; }
[[ $EUID -ne 0 ]] || { echo "Run as your user, not root; sudo is used where needed." >&2; exit 1; }

step "0/6 Machine identity"
current_host=$(hostname -s) # e.g. "My-MacBook-Pro" from "My-MacBook-Pro.local"
read -rp "Username [$(whoami)]: " USERNAME
USERNAME=${USERNAME:-$(whoami)}
if [[ $USERNAME != "$(whoami)" ]]; then
  echo "Log in as '$USERNAME' and run this again (dotfiles, SDKMAN and SSH keys go to the current user)." >&2
  exit 1
fi
while :; do
  read -rp "Hostname [$current_host]: " HOST
  HOST=${HOST:-$current_host}
  HOST=${HOST%.local} # accept the full `hostname` output too
  # Must be a valid LocalHostName: letters, digits and inner hyphens, max 63 chars
  [[ $HOST =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$ ]] && break
  echo "Use only letters, digits and hyphens (not at the start or end)."
done
# Re-runs default to this machine's current answers (host.nix), else to what the Mac knows
host_value() { [[ -f $REPO/host.nix ]] && sed -n "s/^ *$1 = \"\(.*\)\";.*/\1/p" "$REPO/host.nix" || true; }
name_default=$(host_value fullName)
name_default=${name_default:-$(git config --global user.name 2>/dev/null || id -F)}
while :; do
  read -rp "Full name for git commits [$name_default]: " NAME
  NAME=${NAME:-$name_default}
  [[ -n $NAME && $NAME != *[\"\\]* ]] && break
  echo "Enter a name (no quotes or backslashes)."
done
email_default=$(host_value email)
email_default=${email_default:-$(git config --global user.email 2>/dev/null || true)}
while :; do
  read -rp "Git email (e.g. your GitHub noreply address)${email_default:+ [$email_default]}: " EMAIL
  EMAIL=${EMAIL:-$email_default}
  [[ $EMAIL == ?*@?* && $EMAIL != *[\"\\\ ]* ]] && break
  echo "Enter an email address."
done
tz_default=$(host_value timeZone)
tz_default=${tz_default:-$(readlink /etc/localtime | sed 's|.*/zoneinfo/||')}
while :; do
  read -rp "Time zone [$tz_default]: " TZ_NAME
  TZ_NAME=${TZ_NAME:-$tz_default}
  [[ -f /usr/share/zoneinfo/$TZ_NAME && $TZ_NAME != *..* ]] && break
  echo "Use a name from /usr/share/zoneinfo, e.g. Europe/Istanbul or America/Chicago."
done
if grep -q 'optional = true' "$REPO/host.nix" 2>/dev/null; then opt_default=y; else opt_default=n; fi
read -rp "Install optional packages from modules/optional.nix (claude-code, ...)? [y/n, default $opt_default]: " OPTIONAL
[[ ${OPTIONAL:-$opt_default} == [yY]* ]] && OPTIONAL=true || OPTIONAL=false
cat > "$REPO/host.nix" <<NIX
# Written by bootstrap.sh; edit by hand or re-run the script to change.
# Gitignored: this machine's identity stays out of the repo.
{
  user = "$USERNAME";
  hostname = "$HOST";
  fullName = "$NAME"; # git commits
  email = "$EMAIL"; # git commits
  timeZone = "$TZ_NAME";
  optional = $OPTIONAL; # install modules/optional.nix
}
NIX

step "1/6 Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  read -rp "Finish the installer dialog, then press Enter... "
fi

step "2/6 Rosetta (for amd64 containers in Colima)"
if [[ ! -f /Library/Apple/usr/share/rosetta/rosetta ]]; then
  softwareupdate --install-rosetta --agree-to-license
fi

step "3/6 Determinate Nix"
if [[ ! -x $NIX ]]; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi
# shellcheck source=/dev/null
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

step "4/6 nix-darwin switch (sets the hostname; installs Homebrew, casks, home-manager, uv tools)"
if [[ -x /run/current-system/sw/bin/darwin-rebuild ]]; then
  sudo -H /run/current-system/sw/bin/darwin-rebuild switch --flake "path:$REPO#$HOST"
else
  # nix-darwin refuses to overwrite shell rc files the Nix installer edited
  for f in /etc/bashrc /etc/zshrc /etc/zshenv; do
    if [[ -f $f && ! -L $f ]]; then sudo mv "$f" "$f.before-nix-darwin"; fi
  done
  sudo -H "$NIX" run nix-darwin/master#darwin-rebuild -- switch --flake "path:$REPO#$HOST"
fi

step "5/6 SDKMAN (Java, Maven, Gradle)"
if [[ ! -d $HOME/.sdkman ]]; then
  # rcupdate=false: home-manager owns ~/.zshrc and already sources sdkman-init.sh
  # SDKMAN needs Bash 4+; this shell's PATH predates nix-darwin, so `bash` is still macOS's 3.2
  curl -s "https://get.sdkman.io?rcupdate=false" | /run/current-system/sw/bin/bash
fi

step "6/6 SSH key (git commit signing and remotes)"
if [[ ! -f $HOME/.ssh/id_ed25519 ]]; then
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$HOME/.ssh/id_ed25519"
  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
fi

# macOS only lets the user grant these; open the panes so it is two clicks
open -a OmniWM
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

cat <<EOF

Done. Remaining manual steps:
  1. In the System Settings windows that just opened, turn on OmniWM under
     Accessibility (required) and Screen & System Audio Recording (Overview thumbnails).
  2. Log out and back in ("Displays have separate Spaces" needs it; OmniWM then
     starts at login on its own).
  3. Add ~/.ssh/id_ed25519.pub to your git host (as an authentication AND a signing key).
  4. Install a JDK: sdk install java   (see: sdk list java)
  5. Docker, when you need it (the first start saves these settings; later just \`colima start\`):
       colima start --vm-type vz --vz-rosetta --cpu 4 --memory 8
       docker run --rm hello-world
EOF
