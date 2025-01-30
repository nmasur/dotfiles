#!/usr/bin/env bash

# Yoinked from https://github.com/JJGO/dotfiles
# Adapted from https://github.com/sdushantha/bin

set -x
TEXT_FILE="/tmp/ocr.txt"
IMAGE_FILE="/tmp/ocr.png"

function notify-send() {
    /usr/bin/osascript -e "display notification \"$2\" with title \"OCR\""
}

PATH="/usr/local/bin/:$PATH"

# Take screenshot by selecting the area
/usr/sbin/screencapture -i "$IMAGE_FILE"

# Get the exit code of the previous command.
# So in this case, it is the screenshot command. If it did not exit with an
# exit code 0, then it means the user canceled the process of taking a
# screenshot by doing something like pressing the escape key
STATUS=$?

# If the user pressed the escape key or did something to terminate the proccess
# taking a screenshot, then just exit
[ $STATUS -ne 0 ] && exit 1

# Do the magic (∩^o^)⊃━☆ﾟ.*･｡ﾟ
# Notice how I have removing the extension .txt from the file path. This is
# because tesseract adds .txt to the given file path anyways. So if we were to
# specify /tmp/ocr.txt as the file path, tesseract would out the text to
# /tmp/ocr.txt.txt
cd /tmp || {
    echo "Failed to jump to directory."
    exit 1
}
tesseract "$IMAGE_FILE" "${TEXT_FILE//\.txt/}"

# Check if the text was detected by checking number
# of lines in the file
LINES=$(wc -l <$TEXT_FILE)
if [ "$LINES" -eq 0 ]; then
    notify-send "ocr" "no text was detected"
    exit 1
fi

# Copy text to clipboard
# xclip -selection clip < "$TEXT_FILE"
/usr/bin/pbcopy <"$TEXT_FILE"

# Send a notification with the text that was grabbed using OCR
notify-send "ocr" "$(cat $TEXT_FILE)"

# Clean up
# "Always leave the area better than you found it"
#                       - My first grade teacher
rm "$TEXT_FILE"
rm "$IMAGE_FILE"
