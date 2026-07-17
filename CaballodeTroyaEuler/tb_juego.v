// =====================================================================
// TB_JUEGO: testbench del sistema completo (top.v)
// Simula una partida corta:
//   1. Reset del sistema (el caballo arranca en (0,0), casilla pisada)
//   2. Jugada VÁLIDA:  cursor a (2,1)  -> enter -> el caballo salta
//   3. Jugada INVÁLIDA: cursor a (2,2) -> enter -> se ignora
//   4. Jugada VÁLIDA:  cursor a (4,2)  -> enter -> el caballo salta
//
// Correr con:  make sim
// =====================================================================
`timescale 1ns/1ps

module tb_juego;

    // Reloj de 25 MHz -> período de 40 ns
    reg clk = 0;
    always #20 clk = ~clk;

    // Botones y reset: ACTIVOS EN BAJO (reposo = 1, presionado = 0)
    reg btn_up = 1, btn_down = 1, btn_left = 1, btn_right = 1, btn_enter = 1;
    reg reset = 1;

    wire led_out;

    top DUT (
        .clk(clk),
        .btn_up(btn_up), .btn_down(btn_down),
        .btn_left(btn_left), .btn_right(btn_right),
        .btn_enter(btn_enter),
        .reset(reset),
        .led_out(led_out)
    );

    // ---- Tareas para "presionar" cada botón (10 ciclos abajo, 10 arriba)
    task press_up;    begin btn_up = 0;    repeat(10) @(posedge clk); btn_up = 1;    repeat(10) @(posedge clk); end endtask
    task press_down;  begin btn_down = 0;  repeat(10) @(posedge clk); btn_down = 1;  repeat(10) @(posedge clk); end endtask
    task press_left;  begin btn_left = 0;  repeat(10) @(posedge clk); btn_left = 1;  repeat(10) @(posedge clk); end endtask
    task press_right; begin btn_right = 0; repeat(10) @(posedge clk); btn_right = 1; repeat(10) @(posedge clk); end endtask
    task press_enter; begin btn_enter = 0; repeat(10) @(posedge clk); btn_enter = 1; repeat(10) @(posedge clk); end endtask

    initial begin
        $dumpfile("sim/tb_juego.vcd");
        $dumpvars(0, tb_juego);

        // ------------------ 1. RESET ------------------
        reset = 0;                     // botón de reset presionado
        repeat(5) @(posedge clk);
        reset = 1;                     // suelto: arranca el juego
        repeat(30) @(posedge clk);     // INICIO -> CALC -> EVALUA -> ESPERA

        // ------------------ 2. JUGADA VÁLIDA (0,0) -> (2,1) ------------------
        // Movimiento en L: 2 arriba + 1 derecha
        press_up;
        press_up;
        press_right;
        press_enter;
        repeat(30) @(posedge clk);     // APLICA -> CALC -> EVALUA -> ESPERA

        // ------------------ 3. JUGADA INVÁLIDA en (2,2) ------------------
        // (2,2) es adyacente al caballo, NO es movimiento en L:
        // ju_valida debe estar en 0 y el enter debe ignorarse.
        press_right;                   // cursor de (2,1) a (2,2)
        press_enter;
        repeat(30) @(posedge clk);

        // ------------------ 4. JUGADA VÁLIDA (2,1) -> (4,2) ------------------
        // Desde el cursor en (2,2): 2 arriba llega a (4,2), que sí es L.
        press_up;
        press_up;
        press_enter;
        repeat(100) @(posedge clk);

        $display("Fin de la simulacion. Abrir sim/tb_juego.vcd en gtkwave");
        $finish;
    end

endmodule
