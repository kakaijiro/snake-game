#!/usr/bin/env bash
set -euo pipefail

# Ensure rustup / cargo exist and a default toolchain is set
if ! command -v cargo >/dev/null 2>&1; then
  echo "Installing rustup (non-interactive)..."
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  # load cargo env in the current shell
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Ensure a default toolchain is installed
if ! rustup show > /dev/null 2>&1; then
  echo "Setting rustup default toolchain to stable..."
  rustup default stable
fi

# Install wasm-pack (try cargo install, fallback to prebuilt binary)
if ! command -v wasm-pack >/dev/null 2>&1; then
  echo "Installing wasm-pack via cargo..."
  if ! cargo install wasm-pack --locked; then
    echo "cargo install failed, trying prebuilt wasm-pack binary..."
    # Pick a known release version; update if you want a different one
    WPM_VER="v0.10.4"
    TMPDIR="$(mktemp -d)"
    wget -qO "$TMPDIR/wasm-pack.tar.gz" "https://github.com/rustwasm/wasm-pack/releases/download/$WPM_VER/wasm-pack-$WPM_VER-x86_64-unknown-linux-musl.tar.gz" || \
      wget -qO "$TMPDIR/wasm-pack.tar.gz" "https://github.com/rustwasm/wasm-pack/releases/download/$WPM_VER/wasm-pack-$WPM_VER-x86_64-unknown-linux-gnu.tar.gz"
    mkdir -p "$TMPDIR/wasm-pack"
    tar -xzf "$TMPDIR/wasm-pack.tar.gz" -C "$TMPDIR/wasm-pack"
    # locate binary and move it to ~/.cargo/bin
    mkdir -p "$HOME/.cargo/bin"
    if [ -f "$TMPDIR/wasm-pack/wasm-pack" ]; then
      cp "$TMPDIR/wasm-pack/wasm-pack" "$HOME/.cargo/bin/wasm-pack"
      chmod +x "$HOME/.cargo/bin/wasm-pack"
      export PATH="$HOME/.cargo/bin:$PATH"
    else
      echo "Failed to install wasm-pack: prebuilt binary not found in archive"
      exit 1
    fi
    rm -rf "$TMPDIR"
  fi
fi

# Ensure cargo bin is on PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Verify wasm-pack is available
if ! command -v wasm-pack >/dev/null 2>&1; then
  echo "Error: wasm-pack is not available after installation attempts"
  exit 1
fi

# Use stable toolchain and ensure wasm target is present
rustup default stable || true
rustup target add wasm32-unknown-unknown || true

# Build the WASM package
echo "Building WASM package..."
wasm-pack build --release --target web

# Build the frontend
echo "Building frontend..."
cd www

# Use pnpm if available, otherwise fall back to npm
if command -v pnpm >/dev/null 2>&1; then
  echo "Using pnpm..."
  pnpm install
  NODE_ENV=production pnpm run build
else
  echo "Using npm..."
  npm install
  NODE_ENV=production npm run build
fi