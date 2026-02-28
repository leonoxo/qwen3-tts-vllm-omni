#!/bin/bash
# Qwen3-TTS vLLM-Omni 启动脚本

set -e

echo 🚀 Starting Qwen3-TTS with vLLM-Omni...

# 激活虚拟环境
source /mnt/vllm-omni/venv/bin/activate

# 清理旧进程
echo 🧹 Cleaning up old processes...
pkill -f 'vllm-omni serve' || true
sleep 2

# 启动服务
echo 🎙️ Starting TTS service on port 8092...
nohup vllm-omni serve Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice   --stage-configs-path /mnt/vllm-omni/qwen3_tts_optimized.yaml   --omni   --port 8092   --host 0.0.0.0   --trust-remote-code   --enforce-eager   > /mnt/vllm-omni/vllm-omni.log 2>&1 &

echo ✅ Service started!
echo 
echo 📊 Service Info:
echo  - API URL: http://172.27.173.11:8092
echo  - Health Check: http://172.27.173.11:8092/health
echo  - Voices: http://172.27.173.11:8092/v1/audio/voices
echo  - Logs: tail -f /mnt/vllm-omni/vllm-omni.log
echo 
echo 📝 Example Request:
echo '  curl -X POST http://172.27.173.11:8092/v1/audio/speech \'
echo '    -H Content-Type: application/json \'
echo '    -d '\''{input:Hello,voice:vivian,response_format:wav}'\'' \'
echo '    --output output.wav'
echo 
echo ⏳ Waiting for service to be ready...
sleep 5

# 检查服务状态
if curl -s http://localhost:8092/health > /dev/null; then
    echo ✅ Service is healthy!
else
    echo ⚠️ Service starting, check logs: tail -f /mnt/vllm-omni/vllm-omni.log
fi
