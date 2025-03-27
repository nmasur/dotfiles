#!/bin/sh

# Stop all containers
if [ "$(docker ps -a -q)" ]; then
    echo "Stopping docker containers..."
    docker stop "$(docker ps -a -q)"
else
    echo "No running docker containers."
fi

# Remove all stopped containers
if [ "$(docker ps -a -q)" ]; then
    echo "Removing docker containers..."
    docker rm "$(docker ps -a -q)"
else
    echo "No stopped docker containers."
fi

# Remove all untagged images
if docker images | grep -q "^<none>"; then
    docker rmi "$(docker images | grep "^<none>" | awk '{print $3}')"
else
    echo "No untagged docker images."
fi

echo "Cleaned up docker."
