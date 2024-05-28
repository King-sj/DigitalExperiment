module counter(
  input clk,
  input reset,
  input enable,
  input set,
  input [31:0] set_count,
  output reg [31:0] count,
  output reg carry_out
);
  parameter MAX_COUNT = 59; // 默认最大计数值为 59

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      count <= 0;
      carry_out <= 0;
    end  else if (set) begin
      count <= set_count;
      carry_out <= 0;
    end else if (enable) begin
      if (count == MAX_COUNT) begin
        count <= 0;
        carry_out <= 0;
      end else begin
        count <= count + 1;
        if(count == MAX_COUNT-1) begin  // 提前触发
           carry_out <= 1;
        end else begin
          carry_out <= 0;
        end
      end
    end else begin
      carry_out <= 0;
    end
  end
endmodule