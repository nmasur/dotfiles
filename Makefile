nix:
	git add -A
	doas nixos-rebuild switch --flake .
