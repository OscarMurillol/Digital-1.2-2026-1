module comp_arr (clk , addr, z);
  input clk;
  input [8:0]addr;
  output reg z;

always @(negedge clk) begin

      if (addr == 256) begin
        z <= 1;
      end
        else begin
          z <= 0;
      end
    
end
endmodule