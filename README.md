# Snake Game

A classic Snake game implemented using Rust and WebAssembly. The game runs as a web application in the browser, showcasing the performance benefits of WebAssembly for game logic.

## Features

- **Snake Movement**: Control the snake using arrow keys (Up, Down, Left, Right)
- **Wrapping Boundaries**: The snake wraps around the edges of the game board
- **Visual Feedback**: Head and body segments are color-coded (green head, light green body)
- **Smooth Animation**: 10 FPS game loop with canvas-based rendering
- **Random Spawn**: Snake spawns at a random position on the game board

## Tech Stack

- **Rust**: Game logic implementation
- **WebAssembly (WASM)**: Execute Rust code in the browser
- **wasm-bindgen** (v0.2.94): Bindings between Rust and JavaScript
- **wee_alloc** (v0.4.5): Small memory allocator optimized for WebAssembly
- **TypeScript**: Frontend implementation
- **Webpack**: Build tool and development server
- **Canvas API**: 2D rendering

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

This will create the `pkg/` directory containing the compiled WebAssembly module and TypeScript bindings.

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

The server will start on `http://localhost:3000`. Open this URL in your browser to play the game.

**Controls:**

- `Arrow Up`: Move snake up
- `Arrow Down`: Move snake down
- `Arrow Left`: Move snake left
- `Arrow Right`: Move snake right

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
│   └── lib.rs          # Rust game logic (World, Snake, Direction)
├── www/
│   ├── index.ts        # TypeScript entry point and game loop
│   ├── index.html      # HTML file with canvas element
│   ├── bootstrap.js    # WebAssembly initialization
│   ├── webpack.config.js # Webpack configuration
│   ├── tsconfig.json   # TypeScript configuration
│   ├── package.json    # Node.js dependencies
│   └── dist/           # Build output directory (production)
├── pkg/                # wasm-pack build artifacts (generated)
│   ├── snake_game_bg.wasm
│   ├── snake_game.js
│   └── snake_game.d.ts
├── Cargo.toml          # Rust project configuration
├── Cargo.lock          # Rust dependency lock file
└── README.md
```

## Game Architecture

### Rust Side (`src/lib.rs`)

- **`World`**: Main game state structure containing:
  - Game board dimensions (width × width)
  - Snake instance
  - Next cell calculation for direction changes
- **`Snake`**: Snake structure with body segments and current direction
- **`Direction`**: Enum for snake movement (Up, Down, Left, Right)
- **`SnakeCell`**: Represents a cell index in the game grid

### TypeScript Side (`www/index.ts`)

- Initializes WebAssembly module
- Sets up canvas rendering context
- Handles keyboard input events
- Implements game loop with 10 FPS
- Renders game grid and snake using Canvas API

## Development

### Modifying Rust Code

When you modify Rust code, you need to rebuild WebAssembly:

```bash
wasm-pack build --target web
```

The development server will automatically reload when you refresh the browser.

### Modifying TypeScript Code

Changes to TypeScript files will be automatically picked up by webpack-dev-server with hot module replacement.

## Optimization

The following optimizations are applied in release builds:

### Rust Compiler Optimizations (`Cargo.toml`)

- **Size optimization**: `opt-level = "z"` (optimize for size)
- **Link Time Optimization (LTO)**: `lto = true`
- **Codegen units**: `codegen-units = 1` (maximize optimization)
- **Panic handling**: `panic = "abort"` (minimize panic handling overhead)
- **Debug symbols**: `strip = true` (remove debug symbols)

### WebAssembly Optimizations

- **wasm-opt**: `-Oz` flag for maximum size optimization
- **Bulk memory**: `--enable-bulk-memory` for efficient memory operations

These optimizations significantly reduce the final WebAssembly binary size while maintaining performance.

## Performance Considerations

- **Memory Allocation**: Uses `wee_alloc` for efficient memory allocation in WebAssembly
- **Direct Memory Access**: Snake cells are accessed via raw pointers to avoid unnecessary copying
- **Canvas Rendering**: Efficient 2D canvas rendering with minimal redraws

## License

This project is licensed under the MIT License.
