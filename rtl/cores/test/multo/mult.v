module mult #(parameter N = 16)(
  input init,rst,clk,
  output reg done,
  output reg [2*N-1:0]R,
  input [N-1:0]A,
  input [N-1:0]B
  );

  reg LD;
  reg shift_A;
  reg shift_B;
  reg ADD;
  reg DEC;

  wire LSB_B;
  wire z;

  reg [2*N-1:0]A_reg;
  reg [N-1:0]B_reg;
  reg [4:0]count;

  localparam START = 3'b000;
  localparam CHECK_B = 3'b001;
  localparam ADD_R = 3'b010;
  localparam SHIFTyDEC = 3'b011;
  localparam CHECK_END = 3'b100;
  localparam SHIFT = 3'b101;
  localparam DONE_ST = 3'b110;

  reg [2:0] cstate, nstate;

  always @(posedge clk) begin
    if (rst) begin
      cstate <= START;
    end
    else begin
      cstate <= nstate;
    end
  end

always @* begin
    nstate = cstate;
    LD = 1'b0;
    shift_A = 1'b0;
    shift_B = 1'b0;
    ADD = 1'b0;
    DEC = 1'b0;
    done = 1'b0;

  case (cstate)
  START: begin
    if (init) begin
      LD = 1'b1;
      nstate = CHECK_B;
      end
    end
  CHECK_B: begin
    if (LSB_B) begin
      nstate = ADD_R;
      end
    else begin
      nstate = SHIFTyDEC;
      end
    end
  ADD_R: begin
    ADD = 1'b1;
    nstate = SHIFTyDEC;
    end
  SHIFTyDEC: begin
    shift_A = 1'b1;
    DEC = 1'b1;
    nstate = CHECK_END;
    end
  CHECK_END: begin
    if (z) begin
      nstate = DONE_ST;
      end
    else begin
      nstate = SHIFT;
      end
    end
  SHIFT: begin
    shift_B = 1'b1;
    nstate = CHECK_B;
    end
  DONE_ST: begin
    // ¡EL CONGELADOR! Mantiene done=1 y R intacto hasta que llegue un nuevo init
    done = 1'b1;
    if (init) begin
      LD = 1'b1;
      nstate = CHECK_B;
    end
    end
  endcase
end

assign LSB_B = B_reg[0];
assign z = (count == 0);

always @(posedge clk) begin
  if (rst) begin
    A_reg <= 0;
    B_reg <= 0;
    R <= 0;
    count <= 0;
    end
  else if (LD) begin
    A_reg <= {{N{1'b0}}, A};
    B_reg <= B;
    R <= 0;
    count <= N;
    end
  else if (ADD) begin
    R <= R+A_reg;
    end
  else if (shift_A & DEC) begin
    A_reg <= A_reg << 1;
    count <= count - 1;
    end
  else if (shift_B) begin
    B_reg <= B_reg >> 1;
    end
  end
endmodule
