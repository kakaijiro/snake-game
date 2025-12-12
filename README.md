# Snake Game

A classic Snake game implemented using Rust and WebAssembly. The game runs as a web application in the browser, showcasing the performance benefits of WebAssembly for game logic.

## Features

- **Snake Movement**: Control the snake using arrow keys (Up, Down, Left, Right)
- **Wrapping Boundaries**: The snake wraps around the edges of the game board
- **Visual Feedback**: Head and body segments are color-coded (dark purple head, light purple body)
- **Reward System**: Collect orange reward cells to grow the snake and earn points
- **Points Tracking**: Score increases by 1 point for each reward collected
- **Game Status**: Track your progress with status indicators (No status/Playing.../Won/Lost)
- **Start Button**: Click "Play" to begin the game (changes to "Playing..." during gameplay, then "Play Again" when game ends)
- **Win Condition**: Fill the entire board (64 cells) to win the game
- **Smooth Animation**: 2 FPS game loop with canvas-based rendering
- **Random Spawn**: Snake spawns at a random position on the game board (8×8 grid)

## Tech Stack

- **Rust**: Game logic implementation
- **WebAssembly (WASM)**: Execute Rust code in the browser
- **wasm-bindgen** (v0.2.94): Bindings between Rust and JavaScript
- **wee_alloc** (v0.4.5): Small memory allocator optimized for WebAssembly
- **TypeScript**: Frontend implementation
- **Webpack**: Build tool and development server
- **Express**: Production server with compression
- **Canvas API**: 2D rendering

## Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) (latest stable version)
- [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/)
- [Node.js](https://nodejs.org/) (v16 or higher recommended)
- [pnpm](https://pnpm.io/) (package manager)

### Installation

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install wasm-pack
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# Install pnpm (if not already installed)
npm install -g pnpm
```

## Setup

1. Clone the repository:

```bash
git clone https://github.com/kakaijiro/snake-game.git
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

4. Install server dependencies (for production):

```bash
cd ..
pnpm install
```

## Build and Run

### Development Mode

Start the development server (with hot reload):

```bash
cd www
pnpm dev
```

The server will start on `http://localhost:3000` and automatically open in your browser. The webpack dev server provides hot module replacement for instant updates.

**How to Play:**

1. Click the "Play" button to start the game
2. Use arrow keys to control the snake:
   - `Arrow Up`: Move snake up
   - `Arrow Down`: Move snake down
   - `Arrow Left`: Move snake left
   - `Arrow Right`: Move snake right
3. Collect orange reward cells to grow your snake and earn points
4. Fill the entire board (64 cells) to win the game
5. Avoid colliding with yourself (game over condition)
6. Watch your points increase in the top-left corner as you collect rewards

### Production Build

Build the frontend:

```bash
cd www
pnpm build
```

Build artifacts will be output to the `www/public/` directory.

Start the production server:

```bash
# From the root directory
pnpm start
```

The Express server will start on port 3000 (or the port specified in the `PORT` environment variable) with compression enabled.

## Project Structure

```
snake_game/
├── src/
│   └── lib.rs          # Rust game logic (World, Snake, Direction)
├── www/
│   ├── index.ts        # TypeScript entry point and game loop
│   ├── index.html      # HTML file with canvas and game UI
│   ├── bootstrap.js     # Webpack entry point (imports index.ts)
│   ├── webpack.config.js # Webpack configuration
│   ├── tsconfig.json   # TypeScript configuration
│   ├── package.json    # Frontend dependencies
│   ├── utils/          # Utility functions (rnd.ts for random number generation)
│   └── public/         # Build output directory (production)
├── server/
│   └── index.js        # Express server for production deployment
├── pkg/                # wasm-pack build artifacts (generated)
│   ├── snake_game_bg.wasm
│   ├── snake_game.js
│   ├── snake_game.d.ts
│   └── package.json
├── Cargo.toml          # Rust project configuration
├── Cargo.lock          # Rust dependency lock file
├── package.json        # Root package.json (server dependencies)
└── README.md
```

## Game Mechanics

- **Board Size**: 8×8 grid (64 cells total)
- **Snake Initial Size**: 3 segments
- **Movement Speed**: 2 FPS (2 moves per second)
- **Reward Spawning**: Orange reward cells spawn randomly, avoiding snake body
- **Growth**: Snake grows by one segment each time it eats a reward
- **Points System**: Earn 1 point for each reward collected (displayed in top-left)
- **Win Condition**: Fill the entire board (reach 64 segments)
- **Collision Detection**: Game ends if snake collides with itself
- **Boundary Wrapping**: Snake wraps around edges instead of hitting walls
- **Direction Prevention**: Cannot move in the opposite direction of current movement

## Game Architecture

### Rust Side (`src/lib.rs`)

- **`World`**: Main game state structure containing:
  - Game board dimensions (8×8 grid)
  - Snake instance with initial size of 3 segments
  - Reward cell position (orange food)
  - Game status tracking (Won/Lost/Played/None)
  - Points counter (increments when snake eats reward)
  - Next cell calculation for direction changes
- **`Snake`**: Snake structure with body segments and current direction
- **`Direction`**: Enum for snake movement (Up, Down, Left, Right)
- **`GameStatus`**: Enum for game state (Won, Lost, Played)
- **`SnakeCell`**: Represents a cell index in the game grid (wraps usize)
- **Memory Management**: Uses `wee_alloc` for efficient WebAssembly memory allocation
- **External Functions**: Calls TypeScript `rnd()` function for random number generation

### TypeScript Side (`www/index.ts`)

- Initializes WebAssembly module via `init()` function
- Sets up canvas rendering context (20px cell size)
- Configures 8×8 game world (64 cells total)
- Handles keyboard input events for snake control (Arrow keys)
- Implements game loop with 2 FPS using `setTimeout` and `requestAnimationFrame`
- Renders game grid, snake (dark purple head `#5f3dc4`, light purple body `#b197fc`), and orange reward cells (`#fd7e14`) using Canvas API
- Manages game status display ("No status"/"Playing..."/"Won"/"Lost")
- Updates points display when rewards are collected
- Handles Play button state changes ("Play" → "Playing..." → "Play Again")
- Accesses WebAssembly memory directly via `wasm.memory.buffer` to read snake cells efficiently

### Utility Functions (`www/utils/rnd.ts`)

- Provides random number generation function used by Rust code
- Called via `wasm-bindgen` extern function binding

## Development

### Modifying Rust Code

When you modify Rust code, you need to rebuild WebAssembly:

```bash
wasm-pack build --target web
```

The development server will automatically reload when you refresh the browser. Note that WebAssembly modules are not hot-reloaded, so you'll need to manually refresh after rebuilding.

### Modifying TypeScript Code

Changes to TypeScript files will be automatically picked up by webpack-dev-server with hot module replacement (HMR). The browser will update without a full page reload.

### Modifying HTML/CSS

Changes to `index.html` and inline styles will be picked up by webpack-dev-server. For CSS changes, you may need to refresh the page.

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
- **Direct Memory Access**: Snake cells are accessed via raw pointers (`*const SnakeCell`) to avoid unnecessary copying between Rust and JavaScript
- **Canvas Rendering**: Efficient 2D canvas rendering with minimal redraws (only clears and redraws on game step)
- **Memory Buffer Caching**: TypeScript code caches `Uint32Array` views of WebAssembly memory for efficient access
- **Game Loop**: Uses `setTimeout` with `requestAnimationFrame` for smooth 2 FPS animation

## Deployment

### Heroku Deployment

The project includes configuration for Heroku deployment:

1. Build the frontend:

   ```bash
   pnpm build
   ```

2. The `heroku-prebuild` script automatically installs frontend dependencies
3. The `start` script runs the Express server
4. Set the `PORT` environment variable (Heroku sets this automatically)

### Environment Variables

- `PORT`: Server port (defaults to 3000)

## Troubleshooting

### WebAssembly Module Not Loading

- Ensure `wasm-pack build --target web` has been run successfully
- Check browser console for import errors
- Verify `pkg/` directory contains all required files

### Build Errors

- Make sure Rust toolchain is up to date: `rustup update`
- Ensure `wasm-pack` is installed and up to date
- Check that all dependencies are installed: `pnpm install` in both root and `www/` directories

### Development Server Issues

- Clear browser cache if changes aren't appearing
- Restart the dev server if WebAssembly changes aren't reflected
- Check that port 3000 is not already in use

## License

This project is licensed under the MIT License.

## Live Demo

- You can see the live demo [here](https://snaking-game-86ea257b2384.herokuapp.com/).

## Repository

- **GitHub**: [https://github.com/kakaijiro/snake-game](https://github.com/kakaijiro/snake-game)
