
module ws2812_array(
    input  clk,
    input  INIT_M,
    input  RST_CMD,
    output DOUT,
    output DONE_M,
    // ---- Estado del juego (entra directo al traDuctor) ----
    input  [63:0] tablero,
    input  [63:0] pos_movi,
    input  [2:0]  caballo_f,
    input  [2:0]  caballo_c,
    input  [2:0]  cursor_f,
    input  [2:0]  cursor_c,
    input  win,
    input  lose
);

    wire [23:0] w_RGB;
    wire w_done_led;
    wire w_z;
    wire [8:0] w_scan_addr;   
    wire w_init_led;
    wire w_reset;
    wire w_inc;

    ws2812_LED ws2812_LED00(
        .clk(clk), .rst(RST_CMD), .RGB(w_RGB), .RESET_CMD(0),
        .INIT(w_init_led), .DOUT(DOUT), .DONE(w_done_led)
    );

    // Antes: led_mem_arr LEDMEM00 (.clk, .addr, .RGB)
    // Ahora: el traductor calcula el color del LED w_scan_addr
    traductor TRADUCTOR00 (
        .clk(clk),
        .addr(w_scan_addr[7:0]),
        .win(win), .lose(lose),
        .tablero(tablero), .pos_movi(pos_movi),
        .caballo_f(caballo_f), .caballo_c(caballo_c),
        .cursor_f(cursor_f), .cursor_c(cursor_c),
        .RGB(w_RGB)
    );

    count_arr countLED00 (.clk(clk), .inc(w_inc), .rst(w_reset), .addr(w_scan_addr));

    comp_arr shiftLED00 (.clk(clk), .addr(w_scan_addr), .z(w_z));

    control_arr control_wLED00(
        .clk(clk), .INIT_M(INIT_M), .rst(RST_CMD), .z(w_z),
        .DONE(DONE_M), .DONE_LED(w_done_led), .INIT_LED(w_init_led),
        .reset(w_reset), .inc(w_inc)
    );

endmodule
