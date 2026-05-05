FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    VENV_PATH=/opt/venv \
    WORKDIR_PATH=/workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    git \
    ca-certificates \
    build-essential \
    pkg-config \
    libgl1 \
    libglib2.0-0 \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv "$VENV_PATH" && "$VENV_PATH/bin/pip" install --upgrade pip setuptools wheel

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR $WORKDIR_PATH

ENV PATH="$VENV_PATH/bin:$PATH"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
