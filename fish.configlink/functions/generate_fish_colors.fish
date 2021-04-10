# This function creates an output file of just the printf values for
# modifying the shell colors. This output file is used to load the
# current colors into my shell much faster than running the function on
# prompt.

function generate_fish_colors --description "Create fish colors file"
    theme_gruvbox dark > $DOTS/fish.configlink/fish_colors
end
