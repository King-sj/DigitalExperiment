module Ktime(
  input one_hz_clk,
  input reset,
  input set_mod,
  input [5:0]set_hours,
  input [5:0]set_minutes,
  input [5:0]set_seconds,
  output[5:0] seconds,
  output[5:0] minutes,
  output[5:0] hours
);
  wire sec_carry, min_carry;
  counter sec_counter (
    .clk(one_hz_clk), .reset(reset), .enable(1'b1),
    .set(set_mod),.set_count(set_seconds),.count(seconds), .carry_out(sec_carry)
  );
  counter min_counter (
    .clk(one_hz_clk), .reset(reset), .enable(sec_carry),
    .set(set_mod),.set_count(set_minutes),.count(minutes), .carry_out(min_carry)
  );
  defparam hour_counter.MAX_COUNT = 23;
  counter hour_counter(
    .clk(one_hz_clk), .reset(reset), .enable(min_carry),
    .set(set_mod),.set_count(set_hours), .count(hours)
  );
endmodule