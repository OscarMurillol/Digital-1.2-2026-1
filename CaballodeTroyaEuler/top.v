module top(
    input clk,// 25 MHz
    input btn_up, btn_down, btn_left, btn_right, btn_enter,
    input reset,
    output led_out //dato a la matriz
);
    wire rst;
    assign rst = ~reset;
    reg [19:0] delay = 0;
    reg init_trigger = 0;

    always @(posedge clk) begin
        if (rst) begin
            delay <= 0;
            init_trigger <= 0;
        end else begin
            if (delay < 20'd500_000) begin
                delay <= delay + 1;
                init_trigger <= 0;
            end else begin
                delay <= 0;
                init_trigger <= 1;
            end
        end
    end

    wire [2:0] cursor_f, cursor_c;
    wire enter;

    cursor CURSOR0 (
        .clk(clk), .rst(rst),
        .b_u(~btn_up), .b_d(~btn_down),
        .b_l(~btn_left), .b_r(~btn_right), .b_e(~btn_enter),
        .f_s(cursor_f), .c_s(cursor_c), .enter(enter)
    );

    wire [2:0] caballo_f, caballo_c;
    wire load_fc;

    reg_caballo CABALLO0 (
        .clk(clk), .rst(rst), .load_fc(load_fc),
        .f_in(cursor_f), .c_in(cursor_c),
        .f_out(caballo_f), .c_out(caballo_c)
    );

    wire add_jugadas;
    wire [63:0] tablero;
    wire [6:0] casillas_pisadas;

    regjugadas JUGADAS0 (
        .clk(clk), .rst(rst), .add_jugadas(add_jugadas),
        .f(cursor_f), .c(cursor_c),
        .tablero_flat(tablero), .casillas_pisadas(casillas_pisadas)
    );

    wire cal_mov_va, done_calc, q_m;
    wire [63:0] pos_movi;

    pos_mov CALCULADORA0 (
        .clk(clk), .rst(rst), .cal_mov_va(cal_mov_va),
        .f(caballo_f), .c(caballo_c), .jugadas(tablero),
        .done(done_calc), .q_m(q_m), .pos_movi(pos_movi)
    );

    wire ju_valida;

    validar_jugada VALIDADOR0 (
        .f_s(cursor_f), .c_s(cursor_c),
        .pos_movi(pos_movi), .tablero(tablero),
        .ju_valida(ju_valida)
    );

    wire win, lose;

    mc mc0 (
        .clk(clk), .rst(rst),
        .enter(enter), .ju_valida(ju_valida),
        .q_m(q_m), .done_calc(done_calc),
        .casillas_pisadas(casillas_pisadas),
        .cal_mov_va(cal_mov_va), .add_jugadas(add_jugadas),
        .load_fc(load_fc), .win(win), .lose(lose)
    );


    ws2812_array PANTALLA0 (
        .clk(clk),
        .INIT_M(init_trigger),
        .RST_CMD(rst),
        .DOUT(led_out),
        .DONE_M(),
        .tablero(tablero),
        .pos_movi(pos_movi),
        .caballo_f(caballo_f), .caballo_c(caballo_c),
        .cursor_f(cursor_f), .cursor_c(cursor_c),
        .win(win), .lose(lose)
    );

endmodule
