module ws2812(clk, rst, INIT, DONE_T, SEL, DOUT );
    input rst;
    input clk;
    input INIT;

    output DONE_T;

    input  [1:0]SEL;
    output DOUT;
   

    wire [10:0]w_mux;
    wire [10:0]w_count;
    wire w_z;
    wire [1:0]w_seltim;

    wire w_inc;
    wire w_reset;



    comp_ws comp_ws00 (.clk(clk) , .mux_out(w_mux) , .count(w_count), .z(w_z));

    mux_ws multiplexor00 (.clk(clk) , .SEL_TIM(w_seltim) , .out(w_mux));

    count_ws count_ws00 (.clk(clk) , .rst(w_reset) , .inc(w_inc) , .count(w_count));

    control_ws control_ws( .clk(clk) , .init(INIT) , .rst(rst) , .reset(w_reset) , .DOUT(DOUT) , .done(DONE_T)  , .inc(w_inc) , .SEL(SEL), .SEL_TIM(w_seltim), .z(w_z));

endmodule