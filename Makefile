bootstrap:
	./scripts/bootstrap
	./scripts/setup_symlinks

all:
	./scripts/bootstrap
	./scripts/setup_symlinks
	./scripts/setup_fish
	./scripts/brews
	./scripts/update_rust_analyzer
	./scripts/rust
	./scripts/cargos
	./scripts/setup_cheatsheet
	./scripts/setup_ytfzf

fish: bootstrap
	./scripts/setup_fish

macos: bootstrap
	./scripts/configure_macos

brews: bootstrap
	./scripts/brews

casks: bootstrap
	./scripts/casks

rust:
	./scripts/update_rust_analyzer
	./scripts/rust

cargos: rust
	./scripts/rust

programs:
	./scripts/setup_cheatsheet
	./scripts/setup_ytfzf

python: brews
	npm install -g pyright

nix:
	git add -A
	doas nixos-rebuild switch --flake .
