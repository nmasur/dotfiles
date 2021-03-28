function envs --description 'Set from a bash environment variables file'
    set -gx (cat $argv | tr "=" " " | string split ' ')
end
