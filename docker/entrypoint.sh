#!/usr/bin/env bash
set -euo pipefail

VENV_PATH="${VENV_PATH:-/opt/venv}"
WORKDIR_PATH="${WORKDIR_PATH:-/workspace}"
SENTINEL="$VENV_PATH/.deps_installed"

cd "$WORKDIR_PATH"

if [[ ! -d "$VENV_PATH" ]]; then
  python3 -m venv "$VENV_PATH"
fi

export PATH="$VENV_PATH/bin:$PATH"

if [[ ! -f "$SENTINEL" ]]; then
  pip install --upgrade pip setuptools wheel

  # Matches repo's script/setup_env.sh (CUDA 11.8 wheels)
  pip install torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cu118
  # natten needs a CUDA wheel; building from source requires a full CUDA toolchain (nvcc) which this runtime image doesn't include.
  # Try the wheel index matching torch==2.0.1 first, then fall back to the torch==2.0.0 wheel index.
  # Some environments hit TLS verification issues against the wheel host; treat it as trusted so we don't fall back to an sdist build.
  pip install natten==0.14.6 \
    --trusted-host shi-labs.com \
    -f https://shi-labs.com/natten/wheels/cu118/torch2.0.1/index.html \
    || pip install natten==0.14.6 \
      --trusted-host shi-labs.com \
      -f https://shi-labs.com/natten/wheels/cu118/torch2.0.0/index.html

  if [[ -f requirements.txt ]]; then
    pip install -r requirements.txt
  fi

  # If you also want nuplan-devkit in the same container, mount/clone it and install manually:
  #   pip install -e /path/to/nuplan-devkit && pip install -r /path/to/nuplan-devkit/requirements.txt

  date > "$SENTINEL"
fi

exec "$@"
