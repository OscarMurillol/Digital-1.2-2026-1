module count_ws (clk , count, inc, rst);
  input clk;
  input inc;
  input rst;
  output reg [10:0] count;

always @(negedge clk) begin
  if (rst) begin
   count <= 0;
  end else begin
      if (inc)
        count <= count + 1;
  end
end
endmodule