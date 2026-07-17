module count_wsl (clk , dec, ld, z);
  input clk;
  input dec;
  input ld;

  output reg z;

  reg [5:0]count;

always @(negedge clk) begin
  if (ld) begin
   count <= 23;
   z <=0;
  end else begin
      if (dec)begin
        count <= count - 1;
      end
      if (count == 0)begin
        z <= 1;
      end
  end
end
endmodule