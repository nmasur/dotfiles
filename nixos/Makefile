# Show these options
default:
	@echo "sudo make bootstrap -- Install from scratch"
	@echo "make channels       -- Set intended software channels"
	@echo "make system         -- Update system config"
	@echo "make home           -- Update home config"

# Bootstrap from nothing
bootstrap:
	nix-channel --add https://nixos.org/channels/nixos-unstable
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable
	nix-channel --update
	nixos-rebuild switch -I nixos-config=./configuration.nix

# Use intended software channels
channels:
	doas nix-channel --add https://nixos.org/channels/nixos-unstable
	doas nix-channel --add https://nixos.org/channels/nixpkgs-unstable
	doas nix-channel --update

# Update the system
system:
	doas nixos-rebuild switch -I nixos-config=./configuration.nix

# Update the user environment
home:
	home-manager switch -f ./home.nix
