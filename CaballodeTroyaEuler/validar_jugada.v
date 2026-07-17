module validar_jugada(
    input  [2:0]  f_s,
    input  [2:0]  c_s,
    input  [63:0] pos_movi,
    input  [63:0] tablero,
    output        ju_valida
);

    wire [5:0] indice = {f_s, c_s};

    assign ju_valida = pos_movi[indice] & ~tablero[indice];

endmodule
