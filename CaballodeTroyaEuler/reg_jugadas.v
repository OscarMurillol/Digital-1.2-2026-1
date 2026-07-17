module regjugadas(
    input clk,
    input rst,
    input add_jugadas,
    input [2:0] f,
    input [2:0] c,
    output [63:0] tablero_flat,
    output reg [6:0] casillas_pisadas
);

    reg [63:0] tablero;

    assign tablero_flat = tablero;

    wire [5:0] indice = {f, c};

    always @(posedge clk) begin
        if (rst) begin
            tablero <= 64'd0;
            casillas_pisadas <= 7'd0;
        end else if (add_jugadas) begin
            tablero[indice] <= 1'b1;
            if (!tablero[indice])
                casillas_pisadas <= casillas_pisadas + 7'd1;
        end
    end

endmodule
