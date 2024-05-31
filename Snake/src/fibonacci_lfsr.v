/**
 * @copyright ==================================================================
 *  Copyright (c) 2024-05-30.
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
 * @file fibonacci_lfsr.v
 * @author KSJ
 * @date 2024-05-30
 * @version
 * @brief 伪随机数生成器
*/
module fibonacci_lfsr(clk, random_out);
  parameter WIDTH = 16;
  input clk;
  output reg [WIDTH-1:0] random_out={WIDTH{1'b1}};
  wire feedback;
  assign feedback = random_out[WIDTH-1] ^ random_out[14] ^ random_out[13] ^ random_out[11];

  always @(posedge clk) begin
    random_out <= {random_out[WIDTH-2:0], feedback};
  end
endmodule
