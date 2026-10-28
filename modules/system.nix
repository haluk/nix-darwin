{ self, user, hostname, timeZone, ... }:

{
  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}"; # home-manager needs this; login shell stays macOS's /bin/zsh
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Determinate Nix manages the Nix installation and /etc/nix/nix.conf itself.
  # Extra settings go in /etc/nix/nix.custom.conf.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  # Garbage collection (nix.gc is unavailable with nix.enable = false)
  launchd.daemons.nix-gc.serviceConfig = {
    ProgramArguments = [
      "/nix/var/nix/profiles/default/bin/nix-collect-garbage"
      "--delete-older-than"
      "30d"
    ];
    StartCalendarInterval = [{ Weekday = 0; Hour = 2; Minute = 0; }];
    StandardErrorPath = "/var/log/nix-gc.log";
  };

  system.stateVersion = 7;

  # Applied to the system on every switch; the flake output is named after it
  # too, so a plain `darwin-rebuild switch --flake .` finds the right config.
  networking.computerName = hostname;
  networking.hostName = hostname;
  networking.localHostName = hostname;

  # Security
  security.pam.services.sudo_local = { touchIdAuth = true; reattach = true; };

  # No sshd host keys in /etc/ssh: Remote Login stays off, and macOS creates
  # them itself if it is ever turned on. User keys live in ~/.ssh (bootstrap.sh).
  services.openssh.hostKeys = [ ];

  # Time zone
  time.timeZone = timeZone; # from host.nix, asked by bootstrap.sh

  # home-manager owns completion setup; avoid running compinit twice
  programs.zsh = { enable = true; enableCompletion = false; };
}
