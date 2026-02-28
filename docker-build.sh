#!/bin/bash
set -e

echo '=========================================='
echo 'Building Qwen3-TTS Docker Image'
echo '=========================================='

# Stop existing container if running
if docker ps -q --filter name=qwen3-tts | grep -q .; then
    echo 'Stopping existing container...'
    docker stop qwen3-tts
fi

# Remove existing container
if docker ps -aq --filter name=qwen3-tts | grep -q .; then
    echo 'Removing existing container...'
    docker rm qwen3-tts
fi

# Build the image
echo 'Building Docker image...'
docker-compose build --no-cache

echo ''
echo '=========================================='
echo 'Build completed!'
echo '=========================================='
echo ''
echo 'To start the service, run:'
echo '  docker-compose up -d'
echo ''
echo 'To view logs:'
echo '  docker-compose logs -f'
echo ''
echo 'To test the API:'
echo '  curl http://localhost:8092/v1/audio/voices'
