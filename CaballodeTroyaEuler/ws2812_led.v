module ws2812_LED(clk, rst, RGB, RESET_CMD, INIT, DOUT, DONE );
    input rst;
    input clk;
    input INIT;
    input RESET_CMD;

    output DONE;

    input  [23:0]RGB;
    output DOUT;
   

    wire [23:0]w_RGB;

    wire w_z;
 
    wire w_sh;
    wire w_init_t;
    wire w_done_t;
    wire w_dec;
    wire w_ld;


    ws2812 ws2812(.clk(clk), .rst(rst), .INIT(w_init_t), .DONE_T(w_done_t), .SEL({RESET_CMD,w_RGB[23]}), .DOUT(DOUT) );

    count_wsl countLED00 (.clk(clk) , .dec(w_dec), .ld(w_ld), .z(w_z));

    shift_wsl shiftLED00(.clk(clk) , .in_RGB(RGB) , .o_RGB(w_RGB), .sh(w_sh) , .ld(w_ld));

    control_wsl control_wLED00( .clk(clk) , .init(INIT) , .rst(rst),  .z(w_z)  , .DONE_T(w_done_t) , .sh(w_sh) , .INIT_T(w_init_t), .dec(w_dec), .ld(w_ld)  , .DONE(DONE) );

endmodule