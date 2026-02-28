#!/bin/bash

cd /mnt/vllm-omni

echo 'Stopping Qwen3-TTS Docker container...'
docker-compose down

echo 'Container stopped'
