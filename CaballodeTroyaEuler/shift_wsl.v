module shift_wsl(clk , in_RGB , o_RGB, sh , ld);
input clk;
input ld;
input sh;

input [23:0]in_RGB;
output reg [23:0]o_RGB;

always @(negedge clk) begin
    if (ld) begin
        o_RGB[23:0] <= in_RGB[23:0];
    end
    else begin
        if (sh) begin
            o_RGB[23:0] <= {o_RGB[22:0], 1'b0 };
        end
            else begin
                o_RGB   <= o_RGB;
            end
        
    end
end

endmodule