use wasm_bindgen::prelude::*;
use wee_alloc::WeeAlloc;

#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[wasm_bindgen(module = "/www/utils/rnd.ts")]
extern {
    fn rnd(max: usize) -> usize;
}

#[wasm_bindgen]
#[derive(PartialEq)]
pub enum Direction {
    Up,
    Down,
    Right,
    Left
}

#[wasm_bindgen]
#[derive(Clone, Copy)]
pub enum GameStatus {
    Won,
    Lost,
    Played,
}

#[derive(PartialEq, Clone, Copy)]
pub struct SnakeCell(usize);

struct Snake {
    body: Vec<SnakeCell>,
    direction: Direction
}

impl Snake {
    pub fn new(spawn_index: usize, size: usize) -> Snake {
        let mut body = vec!();

        for i in 0..size {
            body.push(SnakeCell(spawn_index - i));
        }

        Snake {
            body,
            direction: Direction::Right,
        }
    }
}

#[wasm_bindgen]
pub struct World {
    width: usize,
    size: usize,
    snake: Snake,
    next_cell: Option<SnakeCell>,
    reward_cell: Option<usize>,
    status: Option<GameStatus>,
    points: usize,
}

#[wasm_bindgen]
impl World {
    pub fn new(width: usize, spawn_index: usize) -> World {

        let snake = Snake::new(spawn_index, 3);
        let size = width * width;
        

        World {
            width,
            size,
            reward_cell: World::generate_reward_cell(size, &snake.body),
            snake,
            next_cell: Option::None,
            status: Option::None,
            points: 0,
        }
    }

    pub fn width(&self) -> usize {
        self.width
    }

    pub fn points(&self) -> usize {
        self.points
    }

    // this function is used in the constractor, therefore it is designed like a static method.
    fn generate_reward_cell(max: usize, snake_body: &Vec<SnakeCell>) -> Option<usize> {
        let mut reward_cell;
        loop {
            reward_cell = rnd(max);
            if !snake_body.contains(&SnakeCell(reward_cell)) {break;}
        }
        Option::Some(reward_cell)
    }

    pub fn reward_cell(&self) -> Option<usize> {
        self.reward_cell
    }

    pub fn size(&self) -> usize {
        self.size
    }

    pub fn snake_head(&self) -> usize {
        self.snake.body[0].0
    }

    pub fn start_game(&mut self) {
        self.status = Option::Some(GameStatus::Played);
    }

    pub fn game_status(&self) -> Option<GameStatus> {
        self.status
    }

    pub fn game_status_text(&self) -> String {
        match self.status {
            Some(GameStatus::Won) => "Won".to_string(),
            Some(GameStatus::Lost) => "Lost".to_string(),
            Some(GameStatus::Played) => "Playing...".to_string(),
            None => "No status".to_string(),
        }
    }

    pub fn change_snake_direction(&mut self, direction: Direction){
        let next_cell = self.generate_next_snake_cell(&direction);

        // unenable to move in the opposite direction
        if self.snake.body[1].0 == next_cell.0 {return;} 
        self.next_cell = Option::Some(next_cell);
        self.snake.direction = direction;
    }

    pub fn snake_length(&self) -> usize {
        self.snake.body.len()
    }

    // we cannot return a reference to Javascript, because of borrowing rules, as follows:
    //
    // pub fn snake_cells(&self) -> &Vec<SnakeCell> {
    //     self.snake.body
    // }
    //
    // instead, we return a pointer to the first element of the vector
    // *const is a raw read-only pointer that the borrowing rules don't apply to
    // However, this pointer is not guaranteed to be valid after the next call to snake_cells(), so we need to be careful not to use it after that.
    pub fn snake_cells(&self) -> *const SnakeCell {
        self.snake.body.as_ptr()
    }

    pub fn step(&mut self) {
        match self.status {
            Option::Some(GameStatus::Played) => {
                let temp = self.snake.body.clone();
                
                match self.next_cell {
                    Option::Some(cell) => {
                        self.snake.body[0] = cell;
                        self.next_cell = Option::None;
                    },
                    Option::None => {
                        self.snake.body[0] = self.generate_next_snake_cell(&self.snake.direction);
                    }
                }
                
                for i in 1..self.snake_length() {
                    self.snake.body[i] = temp[i - 1];
                }

                if self.snake.body[1..self.snake_length()].contains(&self.snake.body[0]) {
                    self.status = Option::Some(GameStatus::Lost);
                }
                
                if self.reward_cell == Option::Some(self.snake_head()) {
                    if self.snake_length() < self.size {
                        self.points += 1;
                        self.reward_cell = World::generate_reward_cell(self.size, &self.snake.body);
                    } else {
                        self.reward_cell = Option::None;
                        self.status = Option::Some(GameStatus::Won);
                    }
                    self.snake.body.push(self.snake.body[1]);
                }
            },
            _ => {}
        }
    }

    fn generate_next_snake_cell(&self, direction: &Direction) -> SnakeCell {
        let snake_index = self.snake_head();
        let row = snake_index / self.width;

        return match direction {
            Direction::Right => {
                // SnakeCell(row * self.width + (snake_index + 1) % self.width)
                let threshold = (row + 1) * self.width;
                if snake_index + 1 == threshold {
                    SnakeCell(threshold - self.width)
                } else {
                    SnakeCell(snake_index + 1)
                }
            },
            Direction::Left => {
                // SnakeCell(row * self.width + (snake_index - 1) % self.width)
                let threshold = row * self.width;
                if snake_index == threshold {
                    SnakeCell(threshold + self.width -1)
                } else {
                    SnakeCell(snake_index - 1)
                }
            },
            Direction::Up => {
                // SnakeCell((snake_index - self.width) % self.size)
                let threshold = snake_index - row * self.width;
                if snake_index == threshold {
                    SnakeCell(self.size - self.width + threshold)
                } else {
                    SnakeCell(snake_index - self.width)
                }
            },
            Direction::Down => {
                // SnakeCell((snake_index + self.width) % self.size)
                let threshold = snake_index + (self.width - row) * self.width;
                if snake_index + self.width == threshold {
                    SnakeCell(threshold - (row + 1) * self.width)
                } else {
                    SnakeCell(snake_index + self.width)
                }
            },
        };
    }
}