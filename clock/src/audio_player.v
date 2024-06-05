/**
 * @copyright ==================================================================
 *  Copyright (c) 2024-05-21.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the
 *  distribution.
 *  3. All advertising materials mentioning features or use of this software
 *  must display the following acknowledgement:
 *  This product includes software developed by the SJ Group. and
 *  its contributors.
 *  4. Neither the name of the Group nor the names of its contributors may
 *  be used to endorse or promote products derived from this software
 *  without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY SongJian, GROUP AND CONTRIBUTORS
 *  ===================================================================
 * @file audio_player.v
 * @author KSJ
 * @date 2024-05-21
 * @version 0.0.1
 * @brief 音乐播放器
*/
module audio_player(
input clk,
output beep, //蜂鸣器输出
output  sd
);
  reg  beep_r;
  reg[7:0] state;  //乐谱状态机
  reg[16:0]count,pre_number;
  reg[25:0]beat_time;
  assign sd=1'b1;
  parameter  //(G大调乐谱参数)
    L_1 = 18'd127552,  //低音1
    L_2 = 18'd113636,  //低音2
    L_3 = 18'd101236,  //低音3
    L_4 = 18'd95548,  //低音4
    L_5 = 18'd85136,  //低音5
    L_6 = 18'd75838,  //低音6
    L_7 = 18'd67567,  //低音7
    M_1 = 18'd63776,  //中音1
    M_2 = 18'd56818,  //中音2
    M_3 = 18'd50607,  //中音3
    M_4 = 18'd47778,  //中音4
    M_5 = 18'd42553,  //中音5
    M_6 = 18'd37936,  //中音6
    M_7 = 18'd33783;  //中音7
parameter  TIME = 25000000; //每种音阶持续时长为500ms
assign beep = beep_r;
always@(posedge clk) begin
  count <= count + 1'b1;
  if(count == pre_number) begin
    count <= 17'h0;
    beep_r <= !beep_r;  //实际上每个周期分别包括等时长的高电位和低电位，一高一低反复循环，形成不同频率的声音
  end
end

always @(posedge clk) begin
   if(beat_time < TIME)
      beat_time = beat_time + 1'b1;
   else begin
      beat_time = 26'd0;
      if(state == 8'd13)
        state = 8'd0;
      else
        state = state + 1'b1;
   case(state)

pre_number = 0;
pre_number = 0;
8'D11:pre_number = M_5;
pre_number = 0;
8'D11:pre_number = M_5;
8'D11:pre_number = M_5;
8'D7:pre_number = M_1;
pre_number = 0;
8'D7:pre_number = M_1;
8'D7:pre_number = M_1;
8'D7:pre_number = M_1;
8'D7:pre_number = M_1;
8'D8:pre_number = M_2; // 重复一次re
8'D8:pre_number = M_2; // 重复一次re
8'D9:pre_number = M_3; // 重复一次mi
8'D9:pre_number = M_3; // 重复一次mi

// 图片 2
pre_number = 0;
pre_number = 0; // 重复两次停顿
8'D11:pre_number = M_5;
pre_number = 0;
8'D11:pre_number = M_5;
8'D11:pre_number = M_5;
8'D7:pre_number = M_1;
pre_number = 0;
8'D7:pre_number = M_1;
8'D7:pre_number = M_1;
8'D8:pre_number = M_2; // 重复一次re
8'D9:pre_number = M_3; // 重复一次mi
8'D8:pre_number = M_2; // 重复一次re
8'D7:pre_number = M_1; // 重复一次do
8'D11:pre_number = M_5; // 重复一次so
8'D11:pre_number = M_5; // 重复一次so


    default: pre_number = 16'h0;
   endcase
   end
end
endmodule
