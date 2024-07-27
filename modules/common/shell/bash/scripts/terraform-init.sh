#!/usr/bin/env bash

export AWS_PROFILE="gs"

BUCKET_NAME_PART_1="t2"
BUCKET_NAME_PART_2="global"
BUCKET_NAME_PART_3="terraformstate"

PROJECT_ROOT=$(git rev-parse --show-toplevel)
WORKFLOW_FILE="${PROJECT_ROOT}/.github/workflows/terraform.yml"

if [ ! -f "$WORKFLOW_FILE" ]; then
    WORKFLOW_FILE="${PROJECT_ROOT}/.github/workflows/apply.yml"
fi

AWS_ACCOUNT_NUMBER=$(
    awk '/aws_account_number: .*/ {print $2}' "$WORKFLOW_FILE" | # Grab account number
        echo "$(
            read -r s
            s=${s//\'/}
            echo "$s"
        )" # Remove single quote if it exists
)

if [ -z "${AWS_ACCOUNT_NUMBER}" ]; then
    AWS_ACCOUNT_NUMBER=$(
        awk '/AWS_ACCOUNT_NUMBER: .*/ {print $2}' "$WORKFLOW_FILE" | # Grab account number
            echo "$(
                read -r s
                s=${s//\'/}
                echo "$s"
            )" # Remove single quote if it exists
    )
fi

REPOSITORY=$(
    git remote get-url origin |
        awk -F'/' -v OFS='/' '{print $(NF-1),$NF }' |
        echo "$(
            read -r s
            s=${s%.git}
            echo "$s"
        )" # Remove .git suffix if it exists
)
BRANCH=$(git branch --show-current)

terraform init \
    -backend-config="region=us-east-1" \
    -backend-config="bucket=${BUCKET_NAME_PART_1}${BUCKET_NAME_PART_2}${BUCKET_NAME_PART_3}" \
    -backend-config="workspace_key_prefix=accounts/${AWS_ACCOUNT_NUMBER}/${REPOSITORY}" \
    -backend-config="key=state.tfstate" \
    -backend-config="dynamodb_table=global-tf-state-lock" \
    -upgrade

terraform workspace select "$BRANCH"
