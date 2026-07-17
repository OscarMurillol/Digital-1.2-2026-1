module detector_flanco (
    input clk,
    input boton_in,
    output pulso_out
);
    // Guarda el estado actual del botón y el estado del ciclo anterior
    reg [1:0] estado_boton;

    always @(posedge clk) begin
        estado_boton <= {estado_boton[0], boton_in};
    end
    assign pulso_out = (estado_boton == 2'b01);

endmodule
