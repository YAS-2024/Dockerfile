# 使用するNVIDIAのCUDA Dockerイメージ 
FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu20.04

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive

# OSパッケージのインストール
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    git \
    curl \
    unzip \
    file \
    xz-utils \
    sudo \
    python3 \
    python3-pip \
    lsb-release \
    gnupg \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Neo4jのインストール手順に従い、公式のリポジトリからインストール
RUN wget -O - https://debian.neo4j.com/neotechnology.gpg.key | gpg --dearmor -o /usr/share/keyrings/neo4j.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/neo4j.gpg] https://debian.neo4j.com stable 4.4" > /etc/apt/sources.list.d/neo4j.list \
    && apt-get update \
    && apt-get install -y neo4j

# CUDAの環境変数設定
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/cuda/bin:$PATH

# 日本語フォントのインストール
ENV NOTO_DIR /usr/share/fonts/opentype/notosans
RUN mkdir -p ${NOTO_DIR} && \
    wget -q https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip -O noto.zip && \
    unzip ./noto.zip -d ${NOTO_DIR}/ && \
    chmod a+r ${NOTO_DIR}/NotoSans* && \
    rm ./noto.zip

# nvidia-container-runtimeのインストール
RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list \
    && apt-get update && apt-get install -y nvidia-container-runtime \
    && rm -rf /var/lib/apt/lists/*

# Pythonパッケージのインストールのためのrequirements.txtをコピー
COPY requirements.txt /tmp/
RUN pip3 install --no-cache-dir -U pip setuptools wheel && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt

# ワーキングディレクトリの設定
WORKDIR /workspace

# コンテナ起動時のデフォルトコマンド
CMD ["bash"]