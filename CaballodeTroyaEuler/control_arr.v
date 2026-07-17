module control_arr( clk , INIT_M , rst , z , DONE_LED, DONE , INIT_LED, reset, inc);

 input clk;
 input rst;
 input INIT_M;


// Estos son las señales entrada del Bloque de control:
 input z;
 input DONE_LED;
//Estos son las señales de salida del bloque de control:
 output reg reset;
 output reg INIT_LED;
 output reg inc;
 output reg DONE;


 parameter START      = 3'b000;
 parameter START_SEND = 3'b001;
 parameter SEND_LED   = 3'b010;
 parameter WAIT_TX    = 3'b011;
 parameter INC        = 3'b100;
 parameter CHECK_END  = 3'b101;
 parameter END_SEND   = 3'b110;



 reg [3:0] state;

 initial begin
  INIT_LED <= 0;
  reset    <= 0;
  inc      <= 0;
  DONE     <= 0;
 end


always @(posedge clk) begin
    if (rst) begin
      state = START;
    end else begin
    case(state)

      START:begin
        INIT_LED <= 0;
        reset    <= 1;
        inc      <= 0;
        DONE     <= 0;
        if(INIT_M)
          state <= START_SEND;
        else
          state <= START;
      end

      START_SEND: begin
        
        INIT_LED <= 1;
        reset    <= 0;
        inc      <= 0;
        DONE     <= 0;

        state <= SEND_LED;
      end

      SEND_LED: begin
        INIT_LED <= 0;
        reset    <= 0;
        inc      <= 0;
        DONE     <= 0;

        state <= WAIT_TX;
      end

      WAIT_TX: begin
        INIT_LED <= 0;
        reset    <= 0;
        inc      <= 0;
        DONE     <= 0;

        if(DONE_LED)
          state <= INC;
        else
          state <= WAIT_TX;
      end
 

      INC: begin
        INIT_LED <= 0;
        reset    <= 0;
        inc      <= 1;
        DONE     <= 0;
        state <= CHECK_END;
      end

      CHECK_END: begin
        INIT_LED <= 0;
        reset    <= 0;
        inc      <= 0;
        DONE     <= 0;
        if(z)
          state <= END_SEND;
        else
          state <= START_SEND;
      end

    END_SEND: begin
        INIT_LED <= 0;
        reset    <= 0;
        inc      <= 0;
        DONE     <= 0;
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
    START       : state_name = "START";
    START_SEND  : state_name = "START_SEND";
    SEND_LED    : state_name = "SEND_LED";
    WAIT_TX     : state_name = "WAIT_TX";
    INC         : state_name = "INC";
    CHECK_END   : state_name = "CHECK_END";
    END_SEND    : state_name = "END_SEND";

  endcase
end
`endif



endmodule