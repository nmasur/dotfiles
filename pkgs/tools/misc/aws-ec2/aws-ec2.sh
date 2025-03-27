#!/usr/bin/env bash

# Retrieve list of AWS instances
# Use enter to jump into their sessions with SSM

# Specify AWS_PROFILE and AWS_REGION before running this script

aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" |
    jq -r \
        '.Reservations[]
        | .Instances[]
        | .InstanceId + " - " +
        (.PrivateIpAddress // "n/a") + " - " +
        (.PublicIpAddress // "n/a") + " - " +
        (.Tags // [] | from_entries | .Name // "n/a")' |
    fzf \
        --height 100% \
        --layout reverse \
        --header $'Press Enter to start SSM session\nInstance ID - Private IP - Public IP - Name' \
        --preview "aws ec2 describe-instances --instance-ids \"\$(echo {} | cut -d' ' -f1)\" | jq -r '.Reservations[].Instances[0]'" \
        --bind "enter:become(aws ssm start-session --target \$(echo {} | cut -d' ' -f1))"
