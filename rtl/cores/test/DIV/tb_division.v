`timescale 1ns / 1ps

module tb_division();

  parameter N = 16;
  
  // Entradas como reg
  reg rst;
  reg clk;
  reg init;
  reg [N-1:0] A;
  reg [N-1:0] B;
  
  // Salidas como wire
  wire done;
  wire [N-1:0] s;
  wire [N-1:0] r;

  // Instanciación del módulo
  division #(N) uut (
    .rst(rst),
    .clk(clk),
    .init(init),
    .done(done),
    .s(s),
    .r(r),
    .A(A),
    .B(B)
  );

  // Generación del reloj (Periodo de 10ns)
  always #5 clk = ~clk;

  initial begin
    // Generación del archivo para GTKWave
    $dumpfile("simulacion.vcd");
    $dumpvars(0, tb_division);

    // Estado inicial
    clk = 0;
    rst = 1;
    init = 0;
    A = 0;
    B = 0;

    // Quitar reset
    #15 rst = 0;

    // --- Prueba 1: 25 / 4 ---
    // Esperado: Cociente (s) = 6, Residuo (r) = 1
    A = 16'd25;
    B = 16'd4;
    init = 1;
    #10 init = 0; // init debe ser un pulso

    // Esperar a que la señal done se ponga en 1
    wait(done);
    #20; // Pausa para ver el resultado estable

    // --- Prueba 2: 100 / 3 ---
    // Esperado: Cociente (s) = 33, Residuo (r) = 1
    A = 16'd100;
    B = 16'd3;
    init = 1;
    #10 init = 0;

    wait(done);
    #20;

    // Terminar simulación
    $display("Simulacion finalizada.");
    $finish;
  end

endmodule
