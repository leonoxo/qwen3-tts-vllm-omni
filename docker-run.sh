#!/bin/bash

cd /mnt/vllm-omni

echo 'Starting Qwen3-TTS Docker container...'
docker-compose up -d

echo ''
echo 'Waiting for service to start. This may take 2-3 minutes...'
sleep 30

echo 'Checking service status...'
for i in 1 2 3 4 5 6 7 8 9 10; do
    if curl -s http://localhost:8092/v1/audio/voices > /dev/null 2>&1; then
        echo 'Service is ready!'
        echo ''
        echo 'Test command:'
        echo '  curl http://localhost:8092/v1/audio/voices'
        exit 0
    fi
    echo -n '.'
    sleep 5
done

echo ''
echo 'Service may still be loading. Check logs with:'
echo '  docker-compose logs -f'
