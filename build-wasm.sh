#!/usr/bin/env bash
set -euo pipefail
# Fail early on any command failure

# If wasm-pack exists, use it
if command -v wasm-pack >/dev/null 2>&1; then
  echo "wasm-pack already installed: $(wasm-pack --version)"
else
  echo "Installing wasm-pack via cargo..."
  # Use cargo install (requires Rust/cargo, which your log shows is installed)
  if cargo install wasm-pack --locked; then
    echo "wasm-pack installed via cargo."
  else
    echo "cargo install failed — falling back to downloading prebuilt binary..."
    # Example download fallback (adjust version/platform if needed)
    WASM_PACK_VER="v0.13.1"
    TMPDIR="$(mktemp -d)"
    ARCHIVE="wasm-pack-${WASM_PACK_VER}-x86_64-unknown-linux-musl.tar.gz"
    URL="https://github.com/rustwasm/wasm-pack/releases/download/${WASM_PACK_VER}/${ARCHIVE}"
    curl -sSL "$URL" -o "${TMPDIR}/${ARCHIVE}"
    tar -xzf "${TMPDIR}/${ARCHIVE}" -C "${TMPDIR}"
    mkdir -p "${HOME}/.cargo/bin"
    mv "${TMPDIR}/wasm-pack" "${HOME}/.cargo/bin/wasm-pack"
    chmod +x "${HOME}/.cargo/bin/wasm-pack"
    echo "wasm-pack installed to ${HOME}/.cargo/bin"
    rm -rf "${TMPDIR}"
  fi
fi

# Continue with your existing wasm build steps, e.g.:
# wasm-pack build --target web --out-dir ../www/public/pkg
# (keep whatever commands you had following the install)