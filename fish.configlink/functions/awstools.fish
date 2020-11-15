#!/usr/bin/local/fish

function awstools --description "AWS bindings"
    function unsetaws --description "Clear AWS credentials environment variables"
        set -e AWS_ACCESS_KEY_ID
        set -e AWS_SECRET_ACCESS_KEY
    end
end
