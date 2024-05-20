module timer_show(
  input clk,
  input [5:0]hours,
  input [5:0]minutes,
  input [5:0]seconds,
  input [2:0] pos,
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
  // pos : 0->5分别是 sec_low, sec_high, min_low, ..., 但是与其在数码管上的实际位置不同
  // (hh::mm::ss) -> 左(3,2) 右(0,1) 右(2,3)
  assign flash_pos = (flash_pos > 3) ? (7-pos) :(3-pos);

  reg[7:0] flash = 0;
  always @(posedge clk_2Hz) begin
    flash <= ~flash;
  end
  wire [3:0] select_wei;
  assign select_wei = 1 << flash_pos;
  assign left_duan = (pos <= 3 && select_wei == left_wei) ?
    (flash & sm_left_duan) : sm_left_duan;
  assign right_duan = (pos > 3 && select_wei == right_wei) ?
    (flash & sm_right_duan) : sm_right_duan;
//------------------------获取段选信号和位选信号--------------------------------
  reg [15:0] left_data, right_data;
  wire [3:0] hours_high, hours_low, minutes_high, minutes_low, seconds_high, seconds_low;

  assign hours_high = hours/10;
  assign hours_low = hours%10;
  assign minutes_high = minutes/10;
  assign minutes_low = minutes%10;
  assign seconds_high = seconds/10;
  assign seconds_low = seconds%10;

  always @(posedge clk) begin
    left_data <= {hours_low,hours_high,{1'b0,flash_pos},{1'b0,pos}};  // TODO(SJ): just test pos
    right_data <= {seconds_low,seconds_high,minutes_low,minutes_high};
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