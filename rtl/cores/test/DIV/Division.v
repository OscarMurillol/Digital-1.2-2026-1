// La estacion que mas tiempo demora en completar un ciclo es la que menos produce
//Con paciencia y saliva, el elefante se comió a la hormiga
module division #(parameter N = 16)(
input rst, clk, init,
output reg done,
output reg [N-1:0] s,
output reg [N-1:0] r,
input [N-1:0] A,
input [N-1:0] B
);

reg w_LD;
reg w_add_r;
reg w_add_s;
reg w_Subs_t;
reg w_shift;
reg w_DEC;
reg w_LD_r;

wire w_Msb_t;
wire w_z;
wire [N-1:0] t;
wire Ai;

reg [N-1:0] A_reg;
reg [N-1:0] B_reg;
reg [4:0] i;

localparam START = 3'b000;
localparam SHIFT = 3'b001;
localparam SUBSTRACT = 3'b010;
localparam CHECK = 3'b011;
localparam ADDLOAD = 3'b100;
localparam COUNTER = 3'b101;
localparam CHECK_END = 3'b110;

reg [2:0] current_state, next_state;

always @(posedge clk) begin
  if (rst) begin
    current_state <= START;
  end else begin
    current_state <= next_state;
    end
end

always @* begin
  next_state = current_state;
  w_LD = 1'b0;
  w_add_r = 1'b0;
  w_add_s = 1'b0;
  w_Subs_t = 1'b0;
  w_shift = 1'b0;
  w_DEC = 1'b0;
  w_LD_r = 1'b0;
  done = 1'b0;

  case (current_state)
    START: begin
      if (init) begin
        w_LD = 1'b1;
        next_state = SHIFT;
        end
      end
    SHIFT: begin
      w_shift = 1'b1;
      w_add_r = 1'b1;
      next_state = SUBSTRACT;
      end
    SUBSTRACT: begin
      w_Subs_t = 1'b1;
      next_state = CHECK;
      end
    CHECK: begin
      if (w_Msb_t) begin
        next_state = COUNTER;
        end
      else begin
        next_state = ADDLOAD;
        end
      end
    ADDLOAD: begin
      w_add_s = 1'b1;
      w_LD_r = 1'b1;
      next_state = COUNTER;
      end
    COUNTER: begin
      w_DEC = 1'b1;
      next_state = CHECK_END;
      end
    CHECK_END: begin
      if (w_z) begin
        done = 1;
        next_state = 0;
        end
      else begin
        next_state = SHIFT;
        end
      end
  endcase
end

assign t = r - B_reg;
assign w_z = (i == 0); //assign es un cable fisico y para poner condiciones
                       //hago la comparación  lógica directa (i==0) da 1 si es verdad o 0 si es falso.
assign w_Msb_t = t[N-1];
assign Ai = A_reg[i-1];

always @(posedge clk) begin
  if (rst) begin
    A_reg <= 0;
    B_reg <= 0;
    s <= 0;
    r <= 0;
    i <= 0;
    end
  else if (w_LD) begin
    A_reg <= A;
    B_reg <= B;
    s <= 0;
    r <= 0;
    i <= N;
    end
  else if (w_add_r & w_shift) begin
    r <= 2*r+Ai;
    s <= 2*s; //s << 1
    end
  else if (w_add_s & w_LD_r) begin
    s <= s+1;
    r <= t;
    end
  else if (w_DEC) begin
    i <= i-1;
    end
end
endmodule
