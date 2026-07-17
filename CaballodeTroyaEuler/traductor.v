module traductor(clk , addr , RGB  ,win ,lose , tablero, pos_movi, caballo_f, caballo_c, cursor_f, cursor_c);

   input  clk;          //entrada inicial
   input  [7:0] addr;   //entrada inicial

    input win;               //Pantalla predeterminada
    input lose;              //Pantalla predeterminada

    input [63:0] tablero;    //Memoria del juego
    input [63:0] pos_movi;  //Movimientos posibles

    input [2:0] caballo_f;   //Posicion jugada
    input [2:0] caballo_c;   //Posicion jugada

    input [2:0] cursor_f;    //Puntero
    input [2:0] cursor_c;    //Puntero

   output reg [23:0] RGB; //entrada inicial


   reg [23:0] memoriaw [0:255];
   reg [23:0] memorial [0:255];

    initial begin
       $readmemh("./display_win.hex",memoriaw);
       $readmemh("./display_lose.hex",memorial);
    end

    localparam COL_PUNTERO   = 24'h20_20_20; // blanco (cursor)
    localparam COL_CABALLO   = 24'h00_00_30; // azul
    localparam COL_OCUPADA   = 24'h00_20_00; // rojo
    localparam COL_POSIBLE   = 24'h20_00_00; // verde
    localparam COL_FONDO_A   = 24'h00_00_00; // casilla oscura del ajedrez
    localparam COL_FONDO_B   = 24'h02_02_02; // casilla clara (muy tenue)
    localparam COL_WIN       = 24'h20_00_00; // pantalla verde
    localparam COL_LOSE      = 24'h00_20_00; // pantalla roja

    localparam VACIO   = 3'd0;
    localparam OCUPADA = 3'd1;
    localparam POSIBLE = 3'd2;
    localparam CABALLO = 3'd3;
    localparam PUNTERO = 3'd4;

        
    wire [3:0] fila_led = addr[7:4];                  // Direccion Fila

    wire       invertir = (fila_led[0] == 1);
    wire [3:0] col_led  = invertir ? ~addr[3:0]       // Verificar inversion 
                                   :  addr[3:0];      // Invierte en filas impares

    wire [2:0] f = fila_led[3:1];                    //Conversion (divide entre 2) para que se acceda 
    wire [2:0] c = col_led[3:1];                     //a la misma posicion en el tablero en los 4 leds


    
    //Modulo de jerarquia para el color, el cual depende de las acciones
    wire [2:0] color;
    tablero_temp temp00000 (.f(f), .c(c), .tablero(tablero), .pos_movi(pos_movi),.caballo_f(caballo_f), .caballo_c(caballo_c), .cursor_f(cursor_f), .cursor_c(cursor_c),.codigo(color)
    );




    always @(negedge clk) begin

        if (win)
            RGB <= memoriaw[addr];
        else if (lose)
            RGB <= memorial[addr];
        else begin
            case (color)
                PUNTERO: RGB <= COL_PUNTERO;
                CABALLO: RGB <= COL_CABALLO;
                OCUPADA: RGB <= COL_OCUPADA;
                POSIBLE: RGB <= COL_POSIBLE;
                default: RGB <= (f[0] ^ c[0]) ? COL_FONDO_B : COL_FONDO_A;
            endcase
        end
    end

  //rojo:  FF0000
  //azul:  0000FF
  //verde: 00FF00

endmodule
