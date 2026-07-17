module cursor(
    input clk,
    input rst,
    input b_u, b_d, b_l, b_r, b_e, // recibe el botón activado
    output reg [2:0] f_s,
    output reg [2:0] c_s,
    output enter
);

    wire p_u, p_d, p_l, p_r;

    detector_flanco DF_U (.clk(clk), .boton_in(b_u), .pulso_out(p_u));
    detector_flanco DF_D (.clk(clk), .boton_in(b_d), .pulso_out(p_d));
    detector_flanco DF_L (.clk(clk), .boton_in(b_l), .pulso_out(p_l));
    detector_flanco DF_R (.clk(clk), .boton_in(b_r), .pulso_out(p_r));
    detector_flanco DF_E (.clk(clk), .boton_in(b_e), .pulso_out(enter));

    always @(posedge clk) begin
        if (rst) begin
            f_s <= 3'd0;
            c_s <= 3'd0;
        end else begin
            if (p_u) f_s <= f_s + 3'd1;
            if (p_d) f_s <= f_s - 3'd1;
            if (p_r) c_s <= c_s + 3'd1;
            if (p_l) c_s <= c_s - 3'd1;
        end
    end

endmodule
