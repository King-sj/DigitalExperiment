module tabletFillingMachine(
  input clk,
  input reset,
  input set,
  input fill,
  input left,
  input right,
  input up,
  input down,
  output [3:0] left_wei,  // 左边的数码管
  output [7:0] left_duan,  //
  output [3:0] right_wei,  //
  output [7:0] right_duan,
  output beep,
  output sd
);
// 状态定义
reg[1:0] IDLE = 2'b00, SETTING = 2'b01, WORKING = 2'b10, ALARM = 2'b11;
reg[1:0] state = 2'b10;
//
reg[31:0] TABLET_CNT_SUM = 32'd20, CAPACITY = 32'd9;
reg[31:0] tablet_cnt = 32'd0, bottle_cnt = 32'd0;
//-----------------除抖动--------------------------------
wire fill_clean;
debounce db_fill(
  .clk(clk), .reset(reset), .noisy_signal(fill),
  .clean_signal(fill_clean)
);
wire left_clean, right_clean, up_clean, down_clean;
debounce db_left(
  .clk(clk),
  .reset(reset),
  .noisy_signal(left),
  .clean_signal(left_clean)
);
debounce db_right(
  .clk(clk),
  .reset(reset),
  .noisy_signal(right),
  .clean_signal(right_clean)
);
debounce db_up(
  .clk(clk),
  .reset(reset),
  .noisy_signal(up),
  .clean_signal(up_clean)
);
debounce db_down(
  .clk(clk),
  .reset(reset),
  .noisy_signal(down),
  .clean_signal(down_clean)
);
//----------------状态转换-----------------------------------
always @(posedge clk, negedge reset) begin
  if (~reset) begin
    state <= WORKING;
  end else begin
    if ((tablet_cnt + bottle_cnt * CAPACITY >= TABLET_CNT_SUM) ||
        (CAPACITY > 999) || (TABLET_CNT_SUM > 99) ||
        (tablet_cnt > 999) || (bottle_cnt > 999)
    ) begin
        state <= ALARM;
    end else if (set) begin
        state <= SETTING;  // 状态转换
    end else begin
        state <= WORKING;
    end
  end
end
//---------------------------------------------------
reg fill_pre = 0;
always @(posedge clk, negedge reset) begin
  if (~reset) begin
    tablet_cnt <= 0;
    bottle_cnt <= 0;
  end else if (state == WORKING) begin
    fill_pre <= fill_clean;
    if (fill_clean && !fill_pre) begin
      if (tablet_cnt == CAPACITY) begin
        bottle_cnt <= bottle_cnt + 1;
        tablet_cnt <= 0;
      end else begin
        tablet_cnt <= tablet_cnt + 1;
      end
    end
  end
end
//------------------------设置----------------------------------
reg[2:0] pos;
reg left_pre, right_pre, up_pre, down_pre;
always @(posedge clk, negedge reset) begin
  if (~reset) begin
    pos <= 0;
  end else if (state == SETTING) begin
    left_pre <= left_clean;
    right_pre <= right_clean;
    up_pre <= up_clean;
    down_pre <= down_clean;
    if (left_clean && !left_pre) begin
      pos <= pos+1;
    end else if (right_clean && !right_pre) begin
      pos <= pos-1;
    end else if (up_clean && !up_pre) begin
      case(pos)
        3'd0: TABLET_CNT_SUM <= TABLET_CNT_SUM+1;
        3'd1: TABLET_CNT_SUM <= TABLET_CNT_SUM+10;
        3'd2: TABLET_CNT_SUM <= TABLET_CNT_SUM+100;
        // 3'd3: TABLET_CNT_SUM <= TABLET_CNT_SUM+1000;
        3'd4: CAPACITY <= CAPACITY + 1;
        3'd5: CAPACITY <= CAPACITY + 10;
        3'd6: CAPACITY <= CAPACITY + 100;
        // 3'd7: CAPACITY <= CAPACITY + 1000;
        default:;
      endcase
    end else if (down_clean && !down_pre) begin
      case(pos)
        3'd0: TABLET_CNT_SUM <= TABLET_CNT_SUM-1;
        3'd1: TABLET_CNT_SUM <= TABLET_CNT_SUM-10;
        3'd2: TABLET_CNT_SUM <= TABLET_CNT_SUM-100;
        // 3'd3: TABLET_CNT_SUM <= TABLET_CNT_SUM-1000;
        3'd4: CAPACITY <= CAPACITY - 1;
        3'd5: CAPACITY <= CAPACITY - 10;
        3'd6: CAPACITY <= CAPACITY - 100;
        // 3'd7: CAPACITY <= CAPACITY - 1000;
      endcase
    end
  end
end
//-----------------------显示--------------------------------
wire[31:0]tablet_cnt_show, bottle_cnt_show;
assign tablet_cnt_show = set ? TABLET_CNT_SUM : tablet_cnt;
assign bottle_cnt_show = set ? CAPACITY : bottle_cnt;
tablet_show shower(
  .clk(clk),
  .tablet_cnt(tablet_cnt_show),
  .bottle_cnt(bottle_cnt_show),
  .pos(pos),
  .set_mod(set),
  .left_wei(left_wei),  // 左边的数码管
  .left_duan(left_duan),  //
  .right_wei(right_wei),  //
  .right_duan(right_duan)
);
//---------------------------音频-------------------------------------------
wire beep_w;
assign beep = (state == ALARM) & beep_w;
audio_player audio(
  .clk(clk),
  .beep(beep_w),
  .sd(sd)
);
endmodule