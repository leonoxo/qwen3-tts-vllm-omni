# Qwen3-TTS vLLM-Omni Docker Deployment

基於 vLLM-Omni 的 Qwen3-TTS Docker 部署方案，支持 OpenAI API 格式和串流輸出。

## 功能特點

- OpenAI API 兼容的 TTS 端點
- 真正的串流輸出（~7ms 首字節延遲）
- Docker 一鍵部署
- 支持 Qwen3-TTS-1.7B 模型
- 模型名稱：Qwen/Qwen3-TTS-1.7B

## 系統需求

- NVIDIA GPU（建議 16GB+ VRAM）
- Docker 20.10+
- nvidia-container-toolkit
- CUDA 12.0+
- 磁盤空間：25GB+（映像 21.2GB + 模型 4.3GB）

## 快速開始

### 方式一：使用預構建映像（推薦）

```bash
# 1. 克隆倉庫
git clone https://github.com/leonoxo/qwen3-tts-vllm-omni.git
cd qwen3-tts-vllm-omni

# 2. 下載模型權重（約 4.3GB）
pip install huggingface_hub
huggingface-cli download Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice \
  --local-dir ./model/Qwen3-TTS-12Hz-1.7B-CustomVoice

# 3. 拉取預構建映像
docker pull leonoxo/qwen3-tts:vllm-omni

# 4. 啟動服務
docker compose up -d

# 5. 查看日誌
docker logs -f qwen3-tts
```

### 方式二：自行構建映像

```bash
# 1. 克隆倉庫
git clone https://github.com/leonoxo/qwen3-tts-vllm-omni.git
cd qwen3-tts-vllm-omni

# 2. 下載模型權重
huggingface-cli download Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice \
  --local-dir ./model/Qwen3-TTS-12Hz-1.7B-CustomVoice

# 3. 構建映像（約 10-15 分鐘）
docker compose build

# 4. 啟動服務
docker compose up -d
```

## API 使用說明

### 基本請求（非串流）

```bash
curl http://localhost:8092/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen/Qwen3-TTS-1.7B",
    "input": "你好，這是一個測試。",
    "voice": "default",
    "response_format": "wav"
  }' --output test.wav
```

### 串流請求（Python）

```python
import httpx
import soundfile as sf
import numpy as np

# 串流生成語音
with httpx.stream(
    "POST",
    "http://localhost:8092/v1/audio/speech",
    json={
        "model": "Qwen/Qwen3-TTS-1.7B",
        "input": "你好，這是一個串流測試。",
        "voice": "default",
        "response_format": "pcm",
        "stream": True
    },
    timeout=60.0
) as response:
    audio_data = b""
    for chunk in response.iter_bytes():
        audio_data += chunk
        print(f"Received {len(audio_data)} bytes")

    # 轉換 PCM 為 WAV（採樣率 24000）
    audio_array = np.frombuffer(audio_data, dtype=np.int16)
    sf.write("output.wav", audio_array, 24000)
```

### OpenAI SDK 示例

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8092/v1",
    api_key="not-needed"
)

response = client.audio.speech.create(
    model="Qwen/Qwen3-TTS-1.7B",
    input="你好，這是使用 OpenAI SDK 的測試。",
    voice="default",
    response_format="wav"
)

response.stream_to_file("output.wav")
```

## API 參數

| 參數 | 類型 | 必填 | 說明 | 默認值 |
|------|------|------|------|--------|
| model | string | 是 | 模型名稱 | Qwen/Qwen3-TTS-1.7B |
| input | string | 是 | 要合成的文字 | - |
| voice | string | 否 | 聲音風格 | default |
| response_format | string | 否 | 輸出格式 (wav/pcm/mp3) | wav |
| stream | boolean | 否 | 是否串流輸出 | false |

## 配置文件

### docker-compose.yml

```yaml
services:
  qwen3-tts:
    image: leonoxo/qwen3-tts:vllm-omni
    container_name: qwen3-tts
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - CUDA_VISIBLE_DEVICES=0
    ports:
      - 8092:8092
    volumes:
      - ./model:/app/model:ro
    ipc: host
    restart: unless-stopped
```

## 故障排除

### 容器無法啟動

```bash
# 檢查 GPU
nvidia-smi

# 檢查 Docker GPU 支持
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

### 串流報錯

串流模式必須使用 `response_format: "pcm"`

### 查看日誌

```bash
docker logs -f qwen3-tts
```

## 性能指標

- 首字節延遲：~7ms
- 映像大小：21.2GB
- 模型大小：4.3GB
- 最小 GPU 顯存：~5GB

## 相關鏈接

- [Qwen3-TTS 模型](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)
- [Docker Hub](https://hub.docker.com/r/leonoxo/qwen3-tts)

## License

Apache 2.0
