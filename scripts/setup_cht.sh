#!/bin/sh

echo "downloading cheatsheet"
curl https://cht.sh/:cht.sh > ~/.local/bin/cht.sh
chmod 755 ~/.local/bin/cht.sh
echo "cht.sh ✓"
