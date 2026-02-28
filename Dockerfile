FROM vllm/vllm-openai:v0.16.0

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 設置版本（跳過 git 檢測）
ENV VLLM_OMNI_VERSION_OVERRIDE=0.1.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ffmpeg libsndfile1 libsndfile1-dev sox libsox-fmt-all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app/vllm-omni/

WORKDIR /app/vllm-omni

# 安裝依賴和 vllm-omni
RUN pip install --no-cache-dir -r requirements/cuda.txt && \
    pip install --no-cache-dir soundfile librosa && \
    pip install --no-cache-dir .

COPY qwen3_tts_ultra_light.yaml /app/config.yaml
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV CUDA_VISIBLE_DEVICES=0
ENV HF_HOME=/app/model

EXPOSE 8092

ENTRYPOINT ["/app/entrypoint.sh"]
