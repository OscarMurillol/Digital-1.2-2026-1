module mux_ws (clk , SEL_TIM, out, rst);
  input clk;
  input rst;
  input [1:0]SEL_TIM;
  output reg [10:0]out;

always @(negedge clk) begin

      if (SEL_TIM == 0) begin
        out <= 11'd10;
      end

      if (SEL_TIM == 1) begin
        out <= 11'd20;
      end

      if (SEL_TIM == 2) begin
        out <= 11'd1250;
      end

      if (SEL_TIM == 3) begin
        out <= 11'd31;
      end

end
endmodule