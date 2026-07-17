module count_arr (clk , inc, rst, addr);
  input clk;
  input inc;
  input rst;

  output reg [8:0]addr;

always @(negedge clk) begin
  if (rst) begin
   addr <= 0;
  end else begin
      if (inc)
        addr <= addr + 1;
     end
end
endmodule