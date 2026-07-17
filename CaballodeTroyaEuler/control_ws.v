module control_ws( clk , init , rst , reset , DOUT , done  , inc , SEL_TIM, SEL, z );

 input clk;

 input rst;
 input init;

 input [1:0]SEL;

// Estos son las señales entrada del Bloque de control:
 input z;

//Estos son las señales de salida del bloque de control:
 output reg DOUT;
 output reg done;
 output reg inc;
 output reg reset;
 output reg [1:0]SEL_TIM;


 parameter START      = 4'b0000;
 parameter CHECK_SEL  = 4'b0001;
 parameter SEND_RES   = 4'b0010;
 parameter SEND_0     = 4'b0011;
 parameter SEND_1     = 4'b0100;
 parameter WAIT_TRST  = 4'b0101;
 parameter WAIT_TH    = 4'b0110;
 parameter WAIT_T     = 4'b0111;
 parameter SEND_PER   = 4'b1000;
 parameter END_SEND   = 4'b1001;


 reg [3:0] state;

 initial begin
  DOUT    <= 0;
  done    <= 0;
  reset   <= 0;
  inc     <= 0;
  SEL_TIM <= 0;
 end


always @(posedge clk) begin
    if (rst) begin
      state = START;
    end else begin
    case(state)

      START:begin
        DOUT    <= 0;
        done    <= 0;
        reset   <= 1;
        inc     <= 0;
        SEL_TIM <= 0;
        if(init)
          state <= CHECK_SEL;
        else
          state <= START;
      end

      CHECK_SEL: begin
        DOUT    <= 0;
        done    <= 0;
        reset   <= 0;
        inc     <= 0;
        SEL_TIM <= 0;
        if(SEL == 1)
          state <= SEND_1;
        else if (SEL == 0)
          state <= SEND_0;
        else if (SEL == 2 || SEL ==3)
          state <= SEND_RES;
      end

      SEND_1: begin
        DOUT    <= 1;
        done    <= 0;
        reset   <= 0;
        inc     <= 1;
        SEL_TIM <= 1;

        state <= WAIT_TH;
      end

      SEND_0: begin
        DOUT    <= 1;
        done    <= 0;
        reset   <= 0;
        inc     <= 1;
        SEL_TIM <= 0;

        state <= WAIT_TH;
      end

      SEND_RES: begin
        DOUT    <= 0;
        done    <= 0;
        reset   <= 0;
        inc     <= 1;
        SEL_TIM <= 2;

        state <= WAIT_TRST;
      end

      WAIT_TH: begin
        DOUT    <= 1;
        done    <= 0;
        reset   <= 0;
        inc     <= 1;

        if(z)
          state <= SEND_PER;
        else
          state <= WAIT_TH;
      end

     WAIT_TRST: begin
        DOUT    <= 0;
        done    <= 0;
        reset   <= 0;
        inc     <= 1;

        if(z)
          state <= END_SEND;
        else
          state <= WAIT_TRST;
      end


      SEND_PER: begin
        DOUT    <= 0;
        done    <= 0;
        reset   <= 0;
        inc     <= 1;
        SEL_TIM <= 3;

        state <= WAIT_T;
      end


      WAIT_T: begin
        DOUT    <= 0;
        done    <= 0;
        reset   <= 0;
        inc     <= 1;
        SEL_TIM <= 3;

        if(z)
          state <= END_SEND;
        else
          state <= WAIT_T;
      end

      END_SEND: begin
        DOUT    <= 0;
        done    <= 1;
        reset   <= 0;
        inc     <= 0;
        SEL_TIM <= 0;

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
    SEND_RES   : state_name = "SEND_RES";
    SEND_0     : state_name = "SEND_0";
    SEND_1     : state_name = "SEND_1";
    WAIT_TRST  : state_name = "WAIT_TRST";
    WAIT_TH    : state_name = "WAIT_TH";
    WAIT_T     : state_name = "WAIT_T";
    SEND_PER   : state_name = "SEND_PER";
    END_SEND   : state_name = "END_SEND";

  endcase
end
`endif



endmodule