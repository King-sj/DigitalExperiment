module score_show(
  input clk,
  input [15:0]lcnt,
  input [15:0]rcnt,
  input game_over,
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
  reg[7:0] flash = 0;
  always @(posedge clk_2Hz) begin
    if (game_over) begin
      flash <= ~flash;
    end else begin
      flash <= ~(8'd0);
    end
  end
  assign left_duan = (flash & sm_left_duan) ;
  assign right_duan = (flash & sm_right_duan) ;
//------------------------获取段选信号和位选信号--------------------------------
  reg [15:0] left_data, right_data;
  wire [3:0] lcnt_thousands,lcnt_hundreds, lcnt_tens, lcnt_units;
  wire [3:0] rcnt_thousands,rcnt_hundreds, rcnt_tens, rcnt_units;
  // 解码每个计数的各个位
  assign lcnt_thousands  = (lcnt / 1000) % 10;
  assign lcnt_hundreds  = (lcnt / 100) % 10;
  assign lcnt_tens      = (lcnt / 10) % 10;
  assign lcnt_units     = lcnt % 10;

  assign rcnt_thousands  = (rcnt / 1000) % 10;
  assign rcnt_hundreds  = (rcnt / 100) % 10;
  assign rcnt_tens      = (rcnt / 10) % 10;
  assign rcnt_units     = rcnt % 10;
  always @(posedge clk) begin
    left_data <= {
      lcnt_units,lcnt_tens,
      lcnt_hundreds,lcnt_thousands
    };
    right_data <= {
      rcnt_units,rcnt_tens,
      rcnt_hundreds,rcnt_thousands
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