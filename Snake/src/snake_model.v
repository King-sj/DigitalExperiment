module snake_model(
  clk,reset,left,right,up,down,pix_x,pix_y,
  color
);
parameter speed = 1,
  width = 640,
  height = 480,
  MAX_LEN = 15,
  RAD = 10;
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
reg signed [15:0] food_x;
reg signed [15:0] food_y;
//-------------------------------------------
reg signed [15:0] snake_pos[MAX_LEN:0][1:0]; // 0:x, 1:y
reg [15:0] snake_len = 1;
//---------------------分频(100HZ)-------------------------------------------
reg clk_100Hz = 0;
reg [32:0] clk_counter;
always @(posedge clk or negedge reset) begin
  if (~reset) begin
    clk_100Hz<=0;
    clk_counter<=0;
  end else begin
    if (clk_counter == 1000000/2-1) begin
      clk_counter<=0;
      clk_100Hz<=~clk_100Hz;
    end else clk_counter <= clk_counter+1;
  end
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
  input signed [15:0] s_x;
  input signed [15:0] s_y;
  input signed [15:0] p_x;
  input signed [15:0] p_y;
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
wire signed [15:0] rand;
fibonacci_lfsr lfsr(.clk(clk), .random_out(rand));
function signed[15:0] next_rand;
  input signed[15:0] rand;
  begin
    next_rand = {rand[14:0], rand[15] ^ rand[2]};
  end
endfunction
//--------------------------move-------------------------------------
wire eaten;
assign eaten =in_circle(snake_pos[snake_len-1][0],snake_pos[snake_len-1][1],food_x,food_y);
always @(posedge clk_100Hz) begin:move
  integer k;
  if (!reset) begin
    snake_pos[0][0] <= width/2;
    snake_pos[0][1] <= height/2;
    food_x <= RAD+{rand}%(width-2*RAD);
    food_y <= RAD+{next_rand(rand)}%(height-2*RAD);
  end else if(eaten) begin
    // 吃到食物了
    food_x <= RAD+{rand}%(width-2*RAD);
    food_y <= RAD+{next_rand(rand)}%(height-2*RAD);
    if (snake_len < MAX_LEN-1) begin
      snake_len <= snake_len + 1;
    end
    for (k = 0;k < MAX_LEN;k=k+1)begin
      if (k == snake_len) begin
        snake_pos[k][0] <= (snake_pos[k-1][0] + speed*dir[0] + width) % width;
        snake_pos[k][1] <= (snake_pos[k-1][1] + speed*dir[1] + height) % height;
      end
    end

  end else begin
    for (k = 0;k < MAX_LEN;k=k+1)begin
      if (k < snake_len-1) begin
        snake_pos[k][0] <= snake_pos[k+1][0];
        snake_pos[k][1] <= snake_pos[k+1][1];
      end else if (k == snake_len-1) begin
        snake_pos[k][0] <= (snake_pos[k][0] + speed*dir[0] + width) % width;
        snake_pos[k][1] <= (snake_pos[k][1] + speed*dir[1] + height) % height;
      end
    end
  end
end

//--------------------------show----------------------------------------
always @(posedge clk) begin
  if (in_snake(pix_x,pix_y)) begin
    color <= 12'h0ff;
  end else if(in_circle(pix_x,pix_y,food_x,food_y)) begin
    color <= 12'hf00;
  end else begin
    color <= 12'hfff;
  end
end
endmodule
