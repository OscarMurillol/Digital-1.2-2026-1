module sqrt #(parameter N = 16)(
input init, rst, clk,
input [N-1:0]A,
output reg done,
output reg [2*N-1:0]S,
output reg [2*N-1:0]R
);

reg LD;
reg LD_B;
reg LD_S;
reg Add_RS;
reg Add_T;
reg Subs_R;
reg SH;
reg DEC;

wire MSB;
wire Z;

reg [N-1:0]A_reg;
reg [1:0]B_reg;
reg [2*N-1:0]R_reg;
reg [2*N-1:0]T_reg;
reg [4:0]count;

localparam START = 0;
localparam LOADB = 1;
localparam LOADYSUBS = 2;
localparam CHECKEND = 3;
localparam SHIFT = 4;
localparam ADDYLOAD = 5;
localparam CHECKTEMP = 6;
localparam ADD = 7;
localparam COUNTER = 8;
localparam END = 9;

reg [3:0] cstate, nstate;

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
  LD=0;
  LD_B=0;
  LD_S=0;
  Add_RS=0;
  Add_T=0;
  Subs_R=0;
  SH=0;
  DEC=0;
  done=0;

  case (cstate)
  START: begin
    LD=1;
    if (init) begin
      nstate=LOADB;
      end
    else begin
      nstate=START;
      end
    end
  LOADB: begin
    LD_B=1;
    nstate=LOADYSUBS;
    end
  LOADYSUBS: begin
    LD_S=1;
    Subs_R=1;
    nstate=CHECKEND;
    end
  CHECKEND: begin
    if (Z) begin
      nstate=END;
      end
    else begin
      nstate=SHIFT;
      end
    end
  SHIFT: begin
    SH=1;
    nstate = ADDYLOAD;
    end
  ADDYLOAD: begin
    LD_B=1;
    Add_T=1;
    nstate=CHECKTEMP;
    end
  CHECKTEMP: begin
    if (MSB) begin
      nstate=COUNTER;
      end
    else begin
      nstate=ADD;
      end
    end
  ADD: begin
    Add_RS=1;
    nstate=COUNTER;
    end
  COUNTER: begin
    DEC=1;
    nstate=CHECKEND;
    end
  END: begin
    done=1;
    if (!init) begin
      nstate = START;
      end
    else begin
      nstate = END;
      end
    end
  endcase
end


assign MSB = (R + B_reg >= T_reg);
assign Z = (count == 0);

always @(posedge clk) begin
  if (rst) begin
    A_reg <= 0;
    B_reg <= 0;
    R <= 0;
    S <= 0;
    T_reg <= 0;
    count <= 0;
    end
  else if (LD) begin
    A_reg <= A;
    B_reg <= 0;
    R <= 0;
    S <= 0;
    T_reg <= 0;
    count <= N-2;
    end
  else if (LD_B) begin
    B_reg <= A_reg[N-1:N-2];
    end
  else if (LD_S & Subs_R) begin
    S <= 1;
    R <= B_reg-1;
    end
  else if (SH) begin
    A_reg <= A_reg << 2;
    R <= R << 2;
    S <= S << 1;
    end
  else if (Add_T) begin
    T_reg <= (S<<1)+1;
    B_reg <= A_reg[N-1:N-2];
    end
  else if (Add_RS) begin
    R <= R + B_reg - T_Reg;
    S <= S+1;
    end
  else if (DEC) begin
    count <= count - 2;
    end
end
