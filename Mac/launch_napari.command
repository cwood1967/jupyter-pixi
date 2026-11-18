#!/bin/bash
set -euo pipefail

GIT_SOURCE="https://github.com/cwood1967/jupyter-pixi.git"
TARGET_DIR="$HOME/Desktop/jupyter-pixi"

export PATH="$HOME/.pixi/bin:$PATH"
if ! command -v pixi >/dev/null 2>&1; then
  echo "pixi not found - installing..."
  curl -fsSL https://pixi.sh/install.sh | sh
fi
if ! command -v pixi >/dev/null 2>&1; then
  echo "Failed to install pixi. Install it manually from https://pixi.sh, then re-run this file."
  read -n 1 -s -r -p "Press any key to exit..."
  exit 1
fi

echo "$TARGET_DIR"
if [ -d "$TARGET_DIR/.git" ]; then
  echo "Updating existing env..."
  git -C "$TARGET_DIR" fetch origin && git -C "$TARGET_DIR" reset --hard origin/main
else
  if [ -d "$TARGET_DIR" ]; then
    echo "Removing incomplete install from $TARGET_DIR"
    rm -rf "$TARGET_DIR"
  fi
  echo "Cloning"
  git clone "$GIT_SOURCE" "$TARGET_DIR"
fi

cd "$TARGET_DIR"
# Keep the environment out of the (Desktop) checkout: detached envs live in
# pixi's cache dir. Written to .pixi/config.toml, which git reset leaves alone.
pixi config set --local detached-environments true
# default env = CPU torch (PyPI arm64/MPS build on macOS). --frozen installs
# exactly what pixi.lock pins, without re-solving.
echo "Installing the environment"
pixi install --frozen
echo "Launching"
pixi run --frozen napari
