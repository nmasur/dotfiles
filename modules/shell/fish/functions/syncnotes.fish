set current_dir $PWD
cd $NOTES_PATH
git pull
git add -A
git commit -m autosync
git push
cd $current_dir
