// =====================================================================
// TB_WS2812: testbench del protocolo de UN led (ws2812_LED)
// Envía el color 24'hAAAAAA (bits alternados 1,0,1,0,...) para poder
// MEDIR en gtkwave la diferencia entre un bit "1" y un bit "0":
//
//   bit "1": DOUT en alto  0.8 us (20 ciclos de 40 ns)
//   bit "0": DOUT en alto  0.4 us (10 ciclos)
//   período de cada bit:   1.24 us (31 ciclos)
//
// Correr con:  make sim tb=tb_ws2812.v
// =====================================================================
`timescale 1ns/1ps

module tb_ws2812;

    reg clk = 0;
    always #20 clk = ~clk;   // 25 MHz

    reg rst = 1;
    reg init = 0;
    reg [23:0] RGB;
    wire DOUT, DONE;

    ws2812_LED DUT (
        .clk(clk), .rst(rst),
        .RGB(RGB), .RESET_CMD(1'b0),
        .INIT(init), .DOUT(DOUT), .DONE(DONE)
    );

    initial begin
        $dumpfile("sim/tb_ws2812.vcd");
        $dumpvars(0, tb_ws2812);

        // Color de prueba: 1010... alternado para comparar anchos de pulso
        RGB = 24'hAAAAAA;

        repeat(5) @(posedge clk);
        rst = 0;
        repeat(5) @(posedge clk);

        // Pulso de arranque
        init = 1;
        repeat(3) @(posedge clk);
        init = 0;

        // Esperar a que termine de enviar los 24 bits
        wait (DONE == 1);
        repeat(50) @(posedge clk);

        $display("Fin de la simulacion. Abrir sim/tb_ws2812.vcd en gtkwave");
        $finish;
    end

endmodule
