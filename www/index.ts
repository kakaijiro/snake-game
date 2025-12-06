import init, { World } from "snake_game";

init().then(() => {
  const CELL_SIZE = 20;
  const WORLD_WIDTH = 8;

  const snakeSpawnIndex = Date.now() % (WORLD_WIDTH * WORLD_WIDTH);
  const world = World.new(WORLD_WIDTH, snakeSpawnIndex);
  const worldWidth = world.width();

  // const canvas = <HTMLCanvasElement> document.getElementById("snake-canvas") ; // another way to type the canvas
  const canvas = document.getElementById("snake-canvas") as HTMLCanvasElement;
  const ctx = canvas.getContext("2d");

  canvas.height = worldWidth * CELL_SIZE;
  canvas.width = worldWidth * CELL_SIZE;

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

  function drawSnake() {
    const snakeIndex = world.snake_head();
    const col = snakeIndex % worldWidth;
    const row = Math.floor(snakeIndex / worldWidth);
    ctx.fillStyle = "#00ff00";

    ctx.beginPath();
    ctx.fillRect(col * CELL_SIZE, row * CELL_SIZE, CELL_SIZE, CELL_SIZE);
    ctx.stroke();
  }

  function paint() {
    drawWorld();
    drawSnake();
  }

  function update() {
    const fps = 10;
    setTimeout(() => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      drawWorld();
      drawSnake();
      world.update();

      // requestAnimationFrame is a browser API that calls the callback function before the next repaint
      requestAnimationFrame(update); // update()
    }, 1000 / fps);
  }

  paint();
  update();
});
