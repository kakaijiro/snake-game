import init, { World, Direction } from "snake_game";
import { rnd } from "./utils/rnd";

init().then((wasm: any) => {
  const CELL_SIZE = 20;
  const WORLD_WIDTH = 5;

  const snakeSpawnIndex = rnd(WORLD_WIDTH * WORLD_WIDTH);
  const world = World.new(WORLD_WIDTH, snakeSpawnIndex);
  const worldWidth = world.width();

  // const canvas = <HTMLCanvasElement> document.getElementById("snake-canvas") ; // another way to type the canvas
  const canvas = document.getElementById("snake-canvas") as HTMLCanvasElement;
  const ctx = canvas.getContext("2d");

  canvas.height = worldWidth * CELL_SIZE;
  canvas.width = worldWidth * CELL_SIZE;

  const gameStatus = document.getElementById("game-status") as HTMLDivElement;
  const gameBtn = document.getElementById("game-btn") as HTMLButtonElement;
  gameBtn.addEventListener("click", () => {
    const status = world.game_status();

    if (status === undefined) {
      gameBtn.textContent = "Playing...";
      world.start_game();
      play();
    } else {
      location.reload();
    }
  });

  // the way to get the snake cells (the pointer to the first element of the vector):
  // const snakeCellPtr = world.snake_cells();
  const snakeLength = world.snake_length();
  // const snakeCells = new Uint32Array(
  //   wasm.memory.buffer,
  //   snakeCellPtr,
  //   snakeLength
  // );

  for (let i = 0; i < snakeLength; i++) {
    document.addEventListener("keydown", (e) => {
      switch (e.code) {
        case "ArrowUp":
          world.change_snake_direction(Direction.Up);
          break;
        case "ArrowDown":
          world.change_snake_direction(Direction.Down);
          break;
        case "ArrowRight":
          world.change_snake_direction(Direction.Right);
          break;
        case "ArrowLeft":
          world.change_snake_direction(Direction.Left);
          break;
      }
    });
  }

  function drawWorld() {
    ctx.beginPath();

    for (let x = 0; x < worldWidth + 1; x++) {
      ctx.moveTo(x * CELL_SIZE, 0);
      ctx.lineTo(x * CELL_SIZE, worldWidth * CELL_SIZE);
    }
    for (let y = 0; y < worldWidth + 1; y++) {
      ctx.moveTo(0, y * CELL_SIZE);
      ctx.lineTo(worldWidth * CELL_SIZE, y * CELL_SIZE);
    }

    ctx.stroke();
  }

  function drawReward() {
    const rewardCellIndex = world.reward_cell();
    const col = rewardCellIndex % worldWidth;
    const row = Math.floor(rewardCellIndex / worldWidth);

    ctx.fillStyle = "#fd7e14";
    ctx.beginPath();
    ctx.fillRect(col * CELL_SIZE, row * CELL_SIZE, CELL_SIZE, CELL_SIZE);
    ctx.stroke();
  }

  function drawSnake() {
    const snakeCells = new Uint32Array(
      wasm.memory.buffer,
      world.snake_cells(),
      world.snake_length()
    );

    snakeCells.forEach((cellIndex, index) => {
      const col = cellIndex % worldWidth;
      const row = Math.floor(cellIndex / worldWidth);
      ctx.fillStyle = index === 0 ? "#51cf66" : "#b2f2bb";

      ctx.beginPath();
      ctx.fillRect(col * CELL_SIZE, row * CELL_SIZE, CELL_SIZE, CELL_SIZE);
    });

    ctx.stroke();
  }

  function drawGameStatus() {
    gameStatus.textContent = world.game_status_text();
  }

  function paint() {
    drawWorld();
    drawSnake();
    drawReward();
    drawGameStatus();
  }

  function play() {
    const fps = 2;
    setTimeout(() => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      drawWorld();
      drawSnake();
      drawReward();
      world.step();

      // requestAnimationFrame is a browser API that calls the callback function before the next repaint
      requestAnimationFrame(play); // update()
    }, 1000 / fps);
  }

  paint();
});
