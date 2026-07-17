module mc(
    input clk,
    input rst,
    input enter,
    input ju_valida,
    input q_m,
    input done_calc,
    input [6:0] casillas_pisadas,
    output reg cal_mov_va,
    output reg add_jugadas,
    output reg load_fc,
    output reg win,
    output reg lose
);

    localparam INICIO = 3'd0;
    localparam CALC   = 3'd1;
    localparam EVALUA = 3'd2;
    localparam ESPERA = 3'd3;
    localparam APLICA = 3'd4;
    localparam GANO   = 3'd5;
    localparam PERDIO = 3'd6;

    reg [2:0] estado = INICIO;

    always @(posedge clk) begin
        if (rst) begin
            estado      <= INICIO;
            cal_mov_va  <= 0;
            add_jugadas <= 0;
            load_fc     <= 0;
            win         <= 0;
            lose        <= 0;
        end else begin
            cal_mov_va  <= 0;
            add_jugadas <= 0;
            load_fc     <= 0;
            win         <= 0;
            lose        <= 0;

            case (estado)

                INICIO: begin
                    add_jugadas <= 1;
                    load_fc     <= 1;
                    estado      <= CALC;
                end

                CALC: begin
                    cal_mov_va <= 1;
                    if (done_calc)
                        estado <= EVALUA;
                end

                EVALUA: begin
                    if (casillas_pisadas >= 7'd64)
                        estado <= GANO;
                    else if (!q_m)
                        estado <= PERDIO;
                    else
                        estado <= ESPERA;
                end

                ESPERA: begin
                    if (enter) begin
                        if (ju_valida)
                            estado <= APLICA;
                    end
                end

                APLICA: begin
                    add_jugadas <= 1;
                    load_fc     <= 1;
                    estado      <= CALC;
                end

                GANO: begin
                    win    <= 1;
                    estado <= GANO;
                end

                PERDIO: begin
                    lose   <= 1;
                    estado <= PERDIO;
                end

                default: estado <= INICIO;
            endcase
        end
    end

endmodule
