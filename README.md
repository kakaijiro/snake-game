# Snake Game

A Snake game implemented using Rust and WebAssembly. It runs as a web application in the browser.

## Tech Stack

- **Rust**: Game logic implementation
- **WebAssembly (WASM)**: Execute Rust code in the browser
- **wasm-bindgen**: Bindings between Rust and JavaScript
- **TypeScript**: Frontend implementation
- **Webpack**: Build tool and development server

## Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) (latest stable version)
- [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/)
- [Node.js](https://nodejs.org/) (v16 or higher recommended)
- [pnpm](https://pnpm.io/) (recommended) or npm

### Installation

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install wasm-pack
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# Install pnpm (skip if using npm)
npm install -g pnpm
```

## Setup

1. Clone the repository:

```bash
git clone <repository-url>
cd snake_game
```

2. Build Rust dependencies and generate WebAssembly:

```bash
wasm-pack build --target web
```

3. Install frontend dependencies:

```bash
cd www
pnpm install
```

## Build and Run

### Development Mode

Start the development server (with hot reload):

```bash
cd www
pnpm dev
```

Open `http://localhost:3000` in your browser.

### Production Build

```bash
cd www
pnpm build
```

Build artifacts will be output to the `www/public/` directory.

## Project Structure

```
snake_game/
├── src/
│   └── lib.rs          # Rust game logic
├── www/
│   ├── index.ts        # TypeScript entry point
│   ├── index.html      # HTML file
│   ├── bootstrap.js    # WebAssembly initialization
│   ├── webpack.config.js # Webpack configuration
│   └── public/         # Build output directory
├── pkg/                # wasm-pack build artifacts
├── Cargo.toml          # Rust project configuration
└── README.md
```

## Development

### Modifying Rust Code

When you modify Rust code, you need to rebuild WebAssembly:

```bash
wasm-pack build --target web
```

### Optimization

The following optimizations are applied in release builds:

- Size optimization (`opt-level = "z"`)
- Link Time Optimization (LTO)
- Debug symbol stripping
- wasm-opt optimization (`-Oz`)

## License

This project is licensed under the MIT License.
