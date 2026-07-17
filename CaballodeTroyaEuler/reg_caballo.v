module reg_caballo(
    input clk,
    input rst,
    input load_fc,
    input  [2:0] f_in, // fila del cursor
    input  [2:0] c_in, // columna del cursor
    output reg [2:0] f_out,
    output reg [2:0] c_out
);

    always @(posedge clk) begin
        if (rst) begin
            f_out <= 3'd0;
            c_out <= 3'd0;
        end else if (load_fc) begin
            f_out <= f_in;
            c_out <= c_in;
        end
    end

endmodule
