#!/usr/bin/env bash
set -euo pipefail

# Ensure cargo bin is on PATH so cargo-installed binaries (wasm-bindgen / wasm-pack) are usable
export PATH="$HOME/.cargo/bin:$PATH"

# Use stable toolchain and ensure wasm target is present (skip if already set)
rustup default stable || true
rustup target add wasm32-unknown-unknown || true

# Install wasm-pack if not already installed
if ! command -v wasm-pack &> /dev/null; then
    echo "Installing wasm-pack..."
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Verify wasm-pack is available
if ! command -v wasm-pack &> /dev/null; then
    echo "Error: wasm-pack is not available"
    exit 1
fi

echo "Building WASM package..."
# Build the wasm package
wasm-pack build --release --target web

# Build the frontend
echo "Building frontend..."
cd www

# Use pnpm if available, otherwise fall back to npm
if command -v pnpm &> /dev/null; then
    echo "Using pnpm..."
    pnpm install
    NODE_ENV=production pnpm run build
else
    echo "Using npm..."
    npm install
    NODE_ENV=production npm run build
fi

