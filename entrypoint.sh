#!/bin/bash
set -e
echo 'Starting Qwen3-TTS vLLM-Omni Server...'
echo 'Config: /app/config.yaml'
echo 'Model: /app/model/Qwen3-TTS-12Hz-1.7B-CustomVoice'
echo 'Port: 8092'
exec vllm-omni serve /app/model/Qwen3-TTS-12Hz-1.7B-CustomVoice \
    --stage-configs-path /app/config.yaml \
    --omni \
    --port 8092 \
    --host 0.0.0.0 \
    --trust-remote-code \
    --enforce-eager \
    --served-model-name Qwen/Qwen3-TTS-1.7B
