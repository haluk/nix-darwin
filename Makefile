# path:, not the git default: it sees the untracked, per-machine host.nix
FLAKE := path:$(CURDIR)
REBUILD := sudo -H darwin-rebuild # -H: root uses its own HOME, not yours

.DEFAULT_GOAL := help
.PHONY: help bootstrap switch build diff check update upgrade tools rollback generations omniwm clean gc uninstall

help: ## Show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  \033[1;34m%-12s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Set up a fresh Mac (asks for user, hostname, optional packages)
	./bootstrap.sh

switch: ## Apply the configuration
	$(REBUILD) switch --flake $(FLAKE)

build: ## Build without activating (catches errors before a switch)
	darwin-rebuild build --flake $(FLAKE)

diff: build ## Show package changes the next switch would make
	nix store diff-closures /run/current-system ./result

check: ## Evaluate the flake
	nix flake check $(FLAKE)

update: ## Bump flake inputs (nixpkgs, nix-darwin, home-manager); then `make switch`
	nix flake update --flake $(FLAKE)

upgrade: ## Upgrade Homebrew casks, uv tools and tmux plugins (never automatic)
	brew update && brew upgrade
	uv tool upgrade --all
	~/.config/tmux/plugins/tpm/bin/update_plugins all

tools: ## Install uv-tools.txt and `raco fmt` (`make switch` does this too)
	grep -v -e '^#' -e '^$$' uv-tools.txt | while read -r spec; do uv tool install $$spec; done
	raco pkg install --auto --batch --user --skip-installed fmt

omniwm: ## Copy OmniWM's current settings into dotfiles/ (to commit)
	cp ~/.config/omniwm/settings.toml dotfiles/omniwm-settings.toml

rollback: ## Switch back to the previous generation
	$(REBUILD) --rollback

generations: ## List system generations
	$(REBUILD) --list-generations

clean: ## Clear caches (Nix store garbage, Homebrew, uv); keeps generations
	nix store gc
	brew cleanup --prune=all
	uv cache clean

gc: ## Delete generations older than 7 days, then clean
	sudo nix-collect-garbage --delete-older-than 7d
	nix-collect-garbage --delete-older-than 7d
	$(MAKE) clean

uninstall: ## Remove nix-darwin and Nix itself (asks first)
	@printf 'This removes nix-darwin, home-manager links and Nix (/nix). Homebrew and its apps stay.\nType "uninstall" to continue: '; \
	read answer; [ "$$answer" = uninstall ] || { echo Aborted.; exit 1; }
	sudo darwin-uninstaller
	sudo /nix/nix-installer uninstall
