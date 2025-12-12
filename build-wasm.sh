#!/usr/bin/env bash
set -euo pipefail

# Use stable toolchain and ensure wasm target is present
rustup default stable
rustup target add wasm32-unknown-unknown

# Ensure cargo bin is on PATH so cargo-installed binaries (wasm-bindgen / wasm-pack) are usable
export PATH="$HOME/.cargo/bin:$PATH"

# Install wasm-pack (this will also install wasm-bindgen via wasm-pack as needed)
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# Build the wasm package
wasm-pack build --release --target web

# Build the frontend
cd www
npm install
NODE_ENV=production npm run build

