`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: None
// Engineer: SongJian
//
// Create Date: 2024/05/19 01:18:42
// Design Name:
// Module Name: smg_ip_model
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


//数码管 ip 核
module smg_ip_model(clk,data,sm_wei,sm_duan);
input clk;
input [15:0] data;
output [3:0] sm_wei;  //
output [7:0] sm_duan;  //

//分频
integer clk_cnt;
reg clk_1kHz;
always @(posedge clk) begin
  if(clk_cnt==32'd50000-1)
    begin clk_cnt <= 1'b0; clk_1kHz <= ~clk_1kHz;end
  else
    clk_cnt <= clk_cnt + 1'b1;
end

//----------------------------------------------------------
//位控制
reg [3:0]wei_ctrl=4'b1110;
always @(posedge clk_1kHz) begin
  wei_ctrl <= {wei_ctrl[2:0],wei_ctrl[3]};  // 循环移位
end

//段控制
reg [3:0]duan_ctrl;
always @(wei_ctrl) begin
case(wei_ctrl)
  4'b1110:duan_ctrl=data[3:0];
  4'b1101:duan_ctrl=data[7:4];
  4'b1011:duan_ctrl=data[11:8];
  4'b0111:duan_ctrl=data[15:12];
  default:duan_ctrl=4'hf;
endcase
end

//----------------------------------------------------------
//解码模块
reg [7:0]duan;
always @(duan_ctrl) begin
  case(duan_ctrl)
    4'h0:duan=8'b0011_1111;//0
    4'h1:duan=8'b0000_0110;//1
    4'h2:duan=8'b0101_1011;//2
    4'h3:duan=8'b0100_1111;//3
    4'h4:duan=8'b0110_0110;//4
    4'h5:duan=8'b0110_1101;//5
    4'h6:duan=8'b0111_1101;//6
    4'h7:duan=8'b0000_0111;//7
    4'h8:duan=8'b0111_1111;//8
    4'h9:duan=8'b0110_1111;//9
    // 4'ha:duan=8'b0111_0111;//a
    // 4'hb:duan=8'b0111_1100;//b
    // 4'hc:duan=8'b0011_1001;//c
    // 4'hd:duan=8'b0101_1110;//d
    // 4'he:duan=8'b0111_1000;//e
    // 4'hf:duan=8'b0111_0001;//f
    default : duan = 8'b0000_0000;//none
  endcase
end
//----------------------------------------------------------
assign sm_wei =~wei_ctrl;
assign sm_duan = duan;
endmodule
