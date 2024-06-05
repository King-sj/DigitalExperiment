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
  reg[31:0] state;  //乐谱状态机
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
      if(state == 32'd114)
        state = 32'd0;
      else
        state = state + 1'b1;
   case(state)
    32'D0:pre_number = 0;
    32'D1:pre_number = 0;
    32'D2:pre_number = M_5;
    32'D3:pre_number = 0;
    32'D4:pre_number = M_5;
    32'D5:pre_number = M_5;
    32'D6:pre_number = M_1;
    32'D7:pre_number = 0;
    32'D8:pre_number = M_1;
    32'D9:pre_number = M_1;
    32'D10:pre_number = M_1;
    32'D11:pre_number = M_1;
    32'D12:pre_number = M_2; // 重复一次re
    32'D13:pre_number = M_2; // 重复一次re
    32'D14:pre_number = M_3; // 重复一次mi
    32'D15:pre_number = M_3; // 重复一次mi
    // Continue from previous numbering
    32'D16:pre_number = 0;
    32'D17:pre_number = 0; // 重复两次停顿
    32'D18:pre_number = M_5;
    32'D19:pre_number = 0;
    32'D20:pre_number = M_5;
    32'D21:pre_number = M_5;
    32'D22:pre_number = M_1;
    32'D23:pre_number = 0;
    32'D24:pre_number = M_1;
    32'D25:pre_number = M_1;
    32'D26:pre_number = M_2; // 重复一次re
    32'D27:pre_number = M_3; // 重复一次mi
    32'D28:pre_number = M_2; // 重复一次re
    32'D29:pre_number = M_1; // 重复一次do
    32'D30:pre_number = L_5; // 重复一次so
    32'D31:pre_number = L_5; // 重复一次so
    // Assume prior commands reached 32'D31, continue from 32'D32
    32'D32:pre_number = 0; // 停顿
    32'D33:pre_number = 0; // 重复停顿
    32'D34:pre_number = M_5; // 中音so
    32'D35:pre_number = M_5; // 重复中音so
    32'D36:pre_number = M_1; // 中音do
    32'D37:pre_number = M_1; // 重复中音do
    32'D38:pre_number = M_1; // 中音do
    32'D39:pre_number = M_1; // 重复中音do
    32'D40:pre_number = M_2; // 中音re
    32'D41:pre_number = M_2; // 重复中音re
    32'D42:pre_number = M_3; // 中音mi
    32'D43:pre_number = M_3; // 重复中音mi
    // Additional commands to follow sequence
    32'D44:pre_number = M_3; // 中音mi
    32'D45:pre_number = M_3; // 重复中音mi
    32'D46:pre_number = M_2; // 中音re
    32'D47:pre_number = M_2; // 重复中音re
    32'D48:pre_number = M_1; // 中音do
    32'D49:pre_number = M_1; // 重复中音do
    32'D50:pre_number = L_5; // 中音so
    32'D51:pre_number = L_5; // 重复中音so
    32'D52:pre_number = M_1; // 中音do
    32'D53:pre_number = M_1; // 重复中音do
    32'D54:pre_number = M_2; // 中音re
    32'D55:pre_number = M_2; // 重复中音re
    32'D56:pre_number = M_3; // 中音mi
    32'D57:pre_number = M_3; // 重复中音mi
    32'D58:pre_number = M_4; // 中音fa
    32'D59:pre_number = M_4; // 重复中音fa
    32'D60:pre_number = M_3; // 中音mi
    32'D61:pre_number = M_3; // 重复中音mi
    32'D62:pre_number = M_2; // 中音re
    32'D63:pre_number = M_2; // 重复中音re
    32'D64:pre_number = L_1; // 低音do
    32'D65:pre_number = M_2; // 重复中音re
    32'D66:pre_number = M_3; // 中音mi
    32'D67:pre_number = 0; // 停顿
    32'D68:pre_number = M_3; // 重复中音mi
    32'D69:pre_number = 0; // 停顿
    32'D70:pre_number = M_3; // 重复中音mi
    32'D71:pre_number = 0; // 停顿
    32'D72:pre_number = M_3; // 重复中音mi
    32'D73:pre_number = M_3; // 重复中音mi
    32'D74:pre_number = M_2; // 中音re
    32'D75:pre_number = M_3; // 中音mi
    32'D76:pre_number = M_2; // 中音re
    32'D77:pre_number = M_2; // 重复中音re
    32'D78:pre_number = M_1; // 中音do
    32'D79:pre_number = M_1; // 重复中音do
    32'D80:pre_number = M_1; // 中音do
    32'D81:pre_number = M_1; // 重复中音do
    32'D82:pre_number = L_5; // 中音so
    32'D83:pre_number = L_5; // 中音so
    32'D84:pre_number = M_1; // 中音do
    32'D85:pre_number = M_1; // 中音do
    32'D86:pre_number = M_2; // 中音re
    32'D87:pre_number = M_2; // 重复中音re
    32'D88:pre_number = M_3; // 中音mi
    32'D89:pre_number = M_3; // 重复中音mi
    32'D90:pre_number = M_4; // 中音fa
    32'D91:pre_number = M_4; // 重复中音fa
    32'D92:pre_number = M_3; // 中音mi
    32'D93:pre_number = M_3; // 重复中音mi
    32'D94:pre_number = M_2; // 中音re
    32'D95:pre_number = M_2; // 重复中音re
    32'D96:pre_number = L_1; // 低音do
    32'D97:pre_number = M_2; // 重复中音re
    32'D98:pre_number = M_3; // 中音mi
    32'D99:pre_number = 0; // 停顿
    32'D100:pre_number = M_3; // 重复中音mi
    32'D101:pre_number = 0; // 停顿
    32'D102:pre_number = M_3; // 重复中音mi
    32'D103:pre_number = 0; // 停顿
    32'D104:pre_number = M_3; // 重复中音mi
    32'D105:pre_number = M_3; // 重复中音mi
    32'D106:pre_number = M_2; // 中音re
    32'D107:pre_number = M_3; // 中音mi
    32'D108:pre_number = M_2; // 中音re
    32'D109:pre_number = M_2; // 重复中音re
    32'D110:pre_number = M_1; // 中音do
    32'D111:pre_number = M_1; // 重复中音do
    32'D112:pre_number = M_1; // 中音do
    32'D113:pre_number = M_1; // 重复中音do
    default: pre_number = 32'h0;
   endcase
   end
end
endmodule
