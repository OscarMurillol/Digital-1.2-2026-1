module control_wsl( clk , init , rst , z , DONE_T, sh , INIT_T, dec, ld, DONE );

 input clk;
 input rst;
 input init;


// Estos son las señales entrada del Bloque de control:
 input z;
 input DONE_T;
//Estos son las señales de salida del bloque de control:
 output reg sh;
 output reg INIT_T;
 output reg dec;
 output reg ld;
 output reg DONE;


 parameter START      = 3'b000;
 parameter CHECK_SEL  = 3'b001;
 parameter SEND_BIT   = 3'b010;
 parameter WAIT_TX    = 3'b011;
 parameter SHIFT      = 3'b100;
 parameter CHECK_END  = 3'b101;
 parameter END_SEND   = 3'b110;



 reg [3:0] state;

 initial begin
  sh      <= 0;
  INIT_T  <= 0;
  dec     <= 0;
  ld      <= 0;
  DONE    <= 0;
 end


always @(posedge clk) begin
    if (rst) begin
      state = START;
    end else begin
    case(state)

      START:begin
        sh      <= 0;
        INIT_T  <= 0;
        dec     <= 0;
        ld      <= 1;
        DONE    <= 0; 
        if(init)
          state <= CHECK_SEL;
        else
          state <= START;
      end

      CHECK_SEL: begin
        sh      <= 0;
        INIT_T  <= 1;
        dec     <= 0;
        ld      <= 0;
        DONE    <= 0; 

        state <= SEND_BIT;
      end

      SEND_BIT: begin
        sh      <= 0;
        INIT_T  <= 0;
        dec     <= 0;
        ld      <= 0;
        DONE    <= 0; 

        state <= WAIT_TX;
      end

      WAIT_TX: begin
        sh      <= 0;
        INIT_T  <= 0;
        dec     <= 0;
        ld      <= 0;
        DONE    <= 0; 
        if(DONE_T)
          state <= SHIFT;
        else
          state <= WAIT_TX;
      end
 

      SHIFT: begin
        sh      <= 1;
        INIT_T  <= 0;
        dec     <= 1;
        ld      <= 0;
        DONE    <= 0; 
        state <= CHECK_END;
      end

      CHECK_END: begin
        sh      <= 0;
        INIT_T  <= 0;
        dec     <= 0;
        ld      <= 0;
        DONE    <= 0; 
        if(z)
          state <= END_SEND;
        else
          state <= CHECK_SEL;
      end

    END_SEND: begin
        sh      <= 0;
        INIT_T  <= 0;
        dec     <= 0;
        ld      <= 0;
        DONE    <= 1; 
        state <= START;
      end

     default: state = START;
   endcase
  end
end

`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(state)
    START      : state_name = "START";
    CHECK_SEL  : state_name = "CHECK_SEL";
    SEND_BIT   : state_name = "SEND_BIT";
    WAIT_TX    : state_name = "WAIT_TX";
    SHIFT      : state_name = "SHIFT";
    CHECK_END  : state_name = "CHECK_END";
    END_SEND   : state_name = "END_SEND";

  endcase
end
`endif



endmodule