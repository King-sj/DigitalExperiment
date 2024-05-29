module tablet_show(
  input clk,
  input [31:0]tablet_cnt,
  input [31:0]bottle_cnt,
  input [2:0] pos,
  input set_mod,
  output [3:0] left_wei,  // 左边的数码管
  output [7:0] left_duan,  //
  output [3:0] right_wei,  //
  output [7:0] right_duan
);
  wire [7:0] sm_left_duan;
  wire [7:0] sm_right_duan;
//---------------------分频(2HZ)-------------------------------------------
  reg clk_2Hz = 0;  // 1HZ
  reg [32:0] counter_2Hz=0;
  always @(posedge clk) begin
    if (counter_2Hz == 50000000/2-1) begin
      counter_2Hz<=0;
      clk_2Hz<=~clk_2Hz;
    end else counter_2Hz <= counter_2Hz+1;
  end
//-----------------------闪烁---------------------------------
  wire [2:0] flash_pos;
  assign flash_pos = (pos > 3) ? (7-pos) :(3-pos);
  reg[7:0] flash = 0;
  always @(posedge clk_2Hz) begin
    if (set_mod) begin
      flash <= ~flash;
    end else begin
      flash <= ~(8'd0);
    end
  end
  wire [3:0] select_wei;
  assign select_wei = 1 << flash_pos;
  assign left_duan = (pos > 3 && select_wei == left_wei) ?
    (flash & sm_left_duan) : sm_left_duan;
  assign right_duan = (pos <= 3 && select_wei == right_wei) ?
    (flash & sm_right_duan) : sm_right_duan;
//------------------------获取段选信号和位选信号--------------------------------
  reg [15:0] left_data, right_data;
  wire [3:0] bottle_hundreds, bottle_tens, bottle_units;
  wire [3:0] tablet_hundreds, tablet_tens, tablet_units;
  // 解码每个计数的各个位
  assign bottle_hundreds  = (bottle_cnt / 100) % 10;
  assign bottle_tens      = (bottle_cnt / 10) % 10;
  assign bottle_units     = bottle_cnt % 10;

  assign tablet_hundreds  = (tablet_cnt / 100) % 10;
  assign tablet_tens      = (tablet_cnt / 10) % 10;
  assign tablet_units     = tablet_cnt % 10;
  always @(posedge clk) begin
    left_data <= {
      bottle_units,bottle_tens,
      bottle_hundreds,4'Hf
    };
    right_data <= {
      tablet_units,tablet_tens,
      tablet_hundreds,4'Hf
    };
  end
  smg_ip_model smg_left(
    .clk(clk), .data(left_data),
    .sm_wei(left_wei), .sm_duan(sm_left_duan)  // 位选信号不用处理，直接输出即可
  );
  smg_ip_model smg_right(
    .clk(clk), .data(right_data),
    .sm_wei(right_wei), .sm_duan(sm_right_duan)
  );
endmodule