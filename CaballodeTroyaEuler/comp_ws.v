module comp_ws (clk , mux_out,count, z);
  input clk;
  input [10:0]mux_out;
  input [10:0]count;
  output reg z;

always @(negedge clk) begin

      if (count == mux_out) begin
        z <= 1;
      end
        else begin
          z <= 0;
      end

end
endmodule