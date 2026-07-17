module pos_mov (
    input clk,
    input rst,
    input cal_mov_va,               // Señal de init
    input [2:0] c,                  // Pos actual c
    input [2:0] f,                  //f
    input [63:0] jugadas,           // Matrix

    output reg done,
    output q_m,                     // 0 y done=1 significa que ya no quedan movimientos
    output reg [63:0] pos_movi      // Matriz aplanada de salida con jugadas posibles
);
    
    assign q_m = |pos_movi;// or para cada bit, de tal forma que si todos son pos_mov = 0000 q_m =0
    
    integer i, j;//esto es necesario pal for
    
    
    reg jugadas_2d [7:0][7:0];
    reg pos_movi_2d [7:0][7:0];

    wire signed [3:0] f_actual = {1'b0, f};
    wire signed [3:0] c_actual = {1'b0, c};

    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                jugadas_2d[i][j] = jugadas[(i * 8) + j];
                pos_movi[(i * 8) + j] = pos_movi_2d[i][j];
            end
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                for (j = 0; j < 8; j = j + 1) begin
                    pos_movi_2d[i][j] <= 1'b1;
                end
            end
            done <= 1'b0;
        end
        else if (cal_mov_va) begin
            for (i = 0; i < 8; i = i + 1) begin
                for (j = 0; j < 8; j = j + 1) begin

                    //  "L" del caballo
                    if ( ((i - f_actual == 1 || f_actual - i == 1) && (j - c_actual == 2 || c_actual - j == 2)) ||
                        ((i - f_actual == 2 || f_actual - i == 2) && (j - c_actual == 1 || c_actual - j == 1)) ) begin

                        // Si la casilla destino está libre (es 0 en la matriz jugadas)
                        if (jugadas_2d[i][j] == 1'b0) begin
                            pos_movi_2d[i][j] <= 1'b1;
                        end else begin
                            pos_movi_2d[i][j] <= 1'b0; // Ya fue jugada
                        end

                    end else begin
                        pos_movi_2d[i][j] <= 1'b0; // No es un movimiento válido 
                    end
                end
            end
            done <= 1'b1; // Indicamos que el cálculo terminó en este flanco de reloj
        end
        else begin
            done <= 1'b0; // Mantiene la señal abajo si no se está solicitando cálculo
        end
    end

endmodule
