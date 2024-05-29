// 去除抖动
module debounce(
  input clk,  // 100MHz
  input reset,
  input noisy_signal,
  output reg clean_signal
);

  reg [20:0] counter;
  reg stable_signal;

  always @(posedge clk, negedge reset) begin
    if (~reset) begin
      counter <= 0;
      clean_signal <= 0;
      stable_signal <= 0;
    end else begin
      if (noisy_signal == stable_signal) begin
        // 当输入信号与当前稳定信号相同时，增加计数器
        if (counter < 2000000)  // 等待大约20ms
          counter <= counter + 1;
        else
          clean_signal <= stable_signal;  // 更新输出信号
      end else begin
        // 如果输入信号改变，重置计数器并更新稳定信号
        counter <= 0;
        stable_signal <= noisy_signal;
      end
    end
  end
endmodule;