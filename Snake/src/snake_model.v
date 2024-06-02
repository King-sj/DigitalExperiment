module snake_model(
  clk,reset,left,right,up,down,pix_x,pix_y,
  color,food_x,food_y
);
parameter speed = 5,
  width = 640,
  height = 480,
  MAX_LEN = 30,
  RAD = 10,
  FLASH_CLOCK=10000000;  // 游戏刷新周期 (100MHZ/FLASH_CLOCK)
input clk;
input reset;
input left;
input right;
input up;
input down;

input signed [15:0] pix_x;
input signed [15:0] pix_y;


output reg [11:0]color;

reg signed [15:0] dir[1:0];  // 方向 {0,1},...,
output reg signed [15:0] food_x;
output reg signed [15:0] food_y;
//-------------------------------------------
reg signed [15:0] snake_pos[MAX_LEN:0][1:0]; // 0:x, 1:y
reg [15:0] snake_len = 1;
//---------------------分频-------------------------------------------
reg clk_game = 0;
reg [32:0] clk_counter;
always @(posedge clk) begin
  if (clk_counter == FLASH_CLOCK/2-1) begin
    clk_counter<=0;
    clk_game<=~clk_game;
  end else clk_counter <= clk_counter+1;
end
//-----------------------dir-------------------------------
always @(posedge clk or negedge reset) begin
  if (~reset) begin
    dir[0] <= 0;
    dir[1] <= 1;
  end else begin
    if(left || right || up || down) begin
      if (left) begin
        if(dir[0] != 1 && dir[1] != 0)
        dir[0] <= -1;
      end else if (right) begin
        if(dir[0] != -1 && dir[1] != 0)
        dir[0] <= 1;
      end else begin
        dir[0] <= 0;
      end
      if (up) begin
        if(dir[0] != 0 && dir[1] != 1)
        dir[1] <= -1;
      end else if (down) begin
        if(dir[0] != 0 && dir[1] != -1)
        dir[1] <= 1;
      end else begin
        dir[1] <= 0;
      end
    end
  end
end
function in_circle;
  input signed [31:0] s_x;
  input signed [31:0] s_y;
  input signed [31:0] p_x;
  input signed [31:0] p_y;
  begin
    in_circle = ((s_x-p_x)*(s_x-p_x)+(s_y-p_y)*(s_y-p_y) < RAD*RAD);
  end
endfunction

function in_snake;
  input signed[15:0] x;
  input signed[15:0] y;
  integer k;
  begin
    in_snake=0;
    for (k=0;k < MAX_LEN; k=k+1) begin
      if (k < snake_len && in_circle(snake_pos[k][0],snake_pos[k][1], x, y)) begin
        in_snake=1;
      end
    end
  end
endfunction
//--------------------------random-----------------------------------------
wire [15:0] rand;
fibonacci_lfsr lfsr(.clk(clk), .random_out(rand));
function [15:0] next_rand;
  input [15:0] rand;
  begin
    next_rand = {rand[14:0], rand[15] ^ rand[2]};
  end
endfunction
//--------------------------move-------------------------------------
reg [31:0] snake_cnt=0;
wire [31:0] snake_idx;
assign snake_idx = MAX_LEN-snake_cnt-1;
always @(posedge clk, negedge reset) begin:move
  integer k;
  if (!reset) begin
    snake_cnt<=0;
    for (k=0; k < MAX_LEN; k = k+1)begin
      snake_pos[k][0] <= width/2;
      snake_pos[k][1] <= height/2-2*k*RAD;
    end
  end else begin
    if (snake_cnt == FLASH_CLOCK) begin  // 每隔10 ms 移动一次
      snake_cnt <= 0;
    end else begin
      snake_cnt <= snake_cnt + 1;
    end
    // 间隔与初始值无关，只与速度有关
    if (snake_cnt < MAX_LEN) begin
      if (snake_idx == 0) begin
        snake_pos[0][0] <= (snake_pos[0][0] + speed*dir[0] + width) % width;
        snake_pos[0][1] <= (snake_pos[0][1] + speed*dir[1] + height) % height;
      end else begin
        snake_pos[snake_idx][0] <= snake_pos[snake_idx-1][0];
        snake_pos[snake_idx][1] <= snake_pos[snake_idx-1][1];
      end
    end
  end
end
//------------------------eat----------------------------------
always @(posedge clk_game, negedge reset) begin:eat
  integer k;
  if (!reset) begin
    food_x <= 100;
    food_y <= 100;
    snake_len <= 5;
  end else if(in_circle(snake_pos[0][0],snake_pos[0][1],food_x,food_y)) begin
    // 吃到食物了
    food_x <= (rand * width) >> 16;  // 假设rand是16位宽
    food_y <= ((next_rand(rand) * height) >> 16);

    if (snake_len < MAX_LEN) begin
      snake_len <= snake_len + 1;
    end
  end
end

//--------------------------show----------------------------------------
always @(posedge clk) begin
  if (food_x < 0 || food_y < 0 || food_x >= width || food_y >= height) begin
    color <= 12'h0f0;
  end
  else if (in_snake(pix_x,pix_y)) begin
    color <= 12'h0ff;
  end else if(in_circle(pix_x,pix_y,food_x,food_y)) begin
    color <= 12'hf00;
  end else begin
    color <= 12'hfff;
  end
end
endmodule
