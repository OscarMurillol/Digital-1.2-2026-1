module tablero_temp(
    input  [2:0]  f,
    input  [2:0]  c,
    input  [63:0] tablero,
    input  [63:0] pos_movi,
    input  [2:0]  caballo_f,
    input  [2:0]  caballo_c,
    input  [2:0]  cursor_f,
    input  [2:0]  cursor_c,
    output reg [2:0] codigo
);

    localparam VACIO   = 3'd0;
    localparam OCUPADA = 3'd1;
    localparam POSIBLE = 3'd2;
    localparam CABALLO = 3'd3;
    localparam PUNTERO = 3'd4;

    wire [5:0] indice = {f, c};

    always @(*) begin
        if (f == cursor_f && c == cursor_c)
            codigo = PUNTERO;
        else if (f == caballo_f && c == caballo_c)
            codigo = CABALLO;
        else if (tablero[indice])
            codigo = OCUPADA;
        else if (pos_movi[indice])
            codigo = POSIBLE;
        else
            codigo = VACIO;
    end

endmodule
