# Disable dunst so that it's not attempting to reach a non-existent dunst service
_final: prev: { betterlockscreen = prev.betterlockscreen.override { withDunst = false; }; }
