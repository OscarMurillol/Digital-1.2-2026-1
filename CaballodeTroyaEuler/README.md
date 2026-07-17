# El Recorrido del Caballo — Juego en FPGA con matriz WS2812

Implementación en Verilog del clásico problema del **recorrido del caballo**
(*Knight's Tour*): mover un caballo de ajedrez por un tablero de 8×8
intentando pisar las 64 casillas sin repetir ninguna. El juego corre
completamente en hardware sobre una FPGA Lattice ECP5 (placa Colorlight
5A-75E v8.2) y se visualiza en una matriz de 16×16 LEDs WS2812.

<!-- ![Foto del proyecto funcionando](docs/foto_proyecto.jpg) -->

## Reglas del juego

El caballo arranca en la casilla (0,0), que queda marcada como pisada.
Con los botones de dirección se mueve un cursor por el tablero y con
*enter* se confirma la jugada. Una jugada es válida solo si la casilla
destino es alcanzable con un movimiento en "L" desde la posición actual
del caballo y no ha sido pisada antes. Se gana al completar las 64
casillas; se pierde cuando quedan casillas libres pero ninguna es
alcanzable desde la posición actual.

En pantalla: el cursor se ve **blanco**, el caballo **azul**, las
casillas ya pisadas **rojas**, las jugadas posibles **verdes**, y el
fondo es un patrón de ajedrez tenue. Al ganar o perder se muestra una
pantalla final completa cargada desde memoria (`display_win.hex` /
`display_lose.hex`).

## Arquitectura general

El diseño se divide en dos grandes bloques que se comunican a través del
estado del juego:

1. **El cerebro**: toda la lógica del juego (cursor, cálculo de
   movimientos válidos, registro del tablero, posición del caballo y la
   máquina de estados que ordena la secuencia).
2. **La pantalla**: la cadena de módulos WS2812 que barre los 256 LEDs
   50 veces por segundo, y el *traductor* que convierte el estado del
   juego en el color de cada LED.

La clave de la comunicación entre ambos es que **no se envían
mensajes**: el cerebro publica su estado (tablero de 64 bits, mapa de
movimientos posibles, posiciones del cursor y del caballo) y el
traductor lo lee durante cada barrido para calcular, LED por LED, qué
color pintar. Es un *framebuffer* virtual: se computa al vuelo en vez
de almacenarse.

<!-- ![Diagrama de bloques general](docs/diagrama_general.png) -->

## Módulos

| Módulo | Bloque | Función |
|---|---|---|
| `top.v` | — | Conecta cerebro y pantalla; genera el pulso de refresco (~50 Hz) |
| `cursor.v` | Cerebro | Mueve el puntero con los botones y genera el pulso *enter* |
| `detector_flanco.v` | Cerebro | Convierte el nivel de un botón en un pulso de 1 ciclo |
| `pos_mov.v` | Cerebro | Calcula el mapa de 64 bits con los movimientos en L posibles |
| `validar_jugada.v` | Cerebro | Verifica que la casilla del cursor sea jugada legal |
| `reg_jugadas.v` | Cerebro | Memoria del tablero (casillas pisadas) y contador de avance |
| `reg_caballo.v` | Cerebro | Posición actual del caballo; se actualiza al confirmar jugada |
| `mc.v` | Cerebro | Máquina de estados global: calcular → esperar → validar → aplicar → win/lose |
| `tablero_temp.v` | Traductor | Decide qué hay en cada casilla (prioridad: puntero > caballo > ocupada > posible > vacío) |
| `traductor.v` | Traductor | Convierte dirección física del LED (16×16, zigzag) a casilla (8×8) y asigna el color |
| `ws2812_array.v` | Pantalla | Barrido de los 256 LEDs (máquina SEND_N_LEDS) |
| `ws2812_led.v` + submódulos | Pantalla | Envío en serie de un color de 24 bits |
| `ws2812.v` + submódulos | Pantalla | Generación de un bit (temporización T0H/T1H/PER/RES) |

## La pantalla WS2812 por dentro

Los LEDs WS2812 se controlan con **una sola línea de datos**. Cada LED
toma los primeros 24 bits que recibe y retransmite el resto al
siguiente, así que un frame completo son 256 colores enviados en serie.
Los bits no se distinguen por voltaje sino por **duración del pulso en
alto**, con estos tiempos (a 25 MHz):

| Símbolo | Significado | Tiempo | Ciclos |
|---|---|---|---|
| T0H | Bit "0": tiempo en alto | 0.4 µs | 10 |
| T1H | Bit "1": tiempo en alto | 0.8 µs | 20 |
| PER | Período de cada bit | 1.25 µs | 31 |
| RES | Reset de frame (línea en bajo) | 50 µs | 1250 |

Dos convenciones importantes del proyecto:

- **El color va en orden GRB**, no RGB: `24'hFF0000` es verde puro.
- **La matriz está cableada en zigzag**: las filas impares van de
  derecha a izquierda. El traductor lo deshace invirtiendo los 4 bits
  bajos de la dirección en esas filas.
- Cada casilla del tablero 8×8 se dibuja como un **super-píxel de 2×2
  LEDs** sobre la matriz física de 16×16.
- El tablero lógico se representa como un vector plano de 64 bits con
  la convención `bit = fila*8 + columna`, igual en todos los módulos.

## Conexiones

| Señal | Pin FPGA | Conector | Nota |
|---|---|---|---|
| `clk` | P6 | — | Oscilador de 25 MHz de la placa |
| `led_out` | F3 | J2 | Dato hacia la matriz WS2812 |
| `reset` | R7 | — | Botón integrado de la placa (activo en bajo) |
| `btn_up` | C4 | J1 | Botón a GND, pull-up interno |
| `btn_down` | D4 | J1 | Botón a GND, pull-up interno |
| `btn_left` | D3 | J1 | Botón a GND, pull-up interno |
| `btn_right` | E3 | J1 | Botón a GND, pull-up interno |
| `btn_enter` | E4 | J1 | Botón a GND, pull-up interno |

La matriz se alimenta con 5 V externos (no desde la FPGA) compartiendo
GND con la placa. Los colores del diseño usan brillos bajos a propósito:
256 LEDs a máxima intensidad consumen varios amperios.

## Compilación y carga

Requisitos: `yosys`, `nextpnr-ecp5`, `ecppack` (proyecto Trellis),
`openFPGALoader`, y para simular `iverilog` + `gtkwave`.

```bash
make syn      # síntesis + place&route + bitstream (en build/)
make config   # carga el bitstream a la SRAM de la FPGA (via FT232RL)
make help     # lista de todos los comandos disponibles
```

La configuración usa un adaptador FT232RL como puente JTAG; el mapeo de
pines por defecto está documentado en el Makefile y puede cambiarse con
`make config CABLE_PINES=...`.

## Simulación

Hay dos testbenches, cada uno pensado para mostrar una parte distinta
del diseño.

### 1. Partida corta (`tb_juego.v`)

```bash
make sim
```

Simula: reset → jugada válida (0,0)→(2,1) → intento inválido en (2,2)
→ jugada válida (2,1)→(4,2). Al terminar abre GTKWave automáticamente
con `sim/tb_juego.vcd`.

Señales recomendadas para agregar (panel izquierdo de GTKWave, en este
orden):

1. `tb_juego.clk` y `tb_juego.reset`
2. Los cinco botones (`btn_up` … `btn_enter`)
3. `DUT.CURSOR0.f_s` y `DUT.CURSOR0.c_s` (formato *decimal*) — posición del cursor
4. `DUT.enter` — el pulso de confirmación
5. `DUT.mc0.estado` (formato *decimal*) — la máquina de estados: 0=INICIO, 1=CALC, 2=EVALUA, 3=ESPERA, 4=APLICA, 5=GANO, 6=PERDIO
6. `DUT.cal_mov_va` y `DUT.done_calc` — el "diálogo" con la calculadora de movimientos
7. `DUT.pos_movi` (formato *hexadecimal*) — el mapa de movimientos posibles
8. `DUT.ju_valida` — si la casilla del cursor es legal
9. `DUT.add_jugadas` y `DUT.load_fc` — las órdenes de aplicar jugada
10. `DUT.CABALLO0.f_out` y `DUT.CABALLO0.c_out` (decimal) — posición del caballo
11. `DUT.tablero` (hexadecimal) y `DUT.casillas_pisadas` (decimal)

Qué se debe observar:

- Tras el reset, `estado` pasa por INICIO→CALC→EVALUA→ESPERA,
  `casillas_pisadas` vale 1 y el bit 0 de `tablero` queda en 1 (la
  casilla inicial).
- Con cada botón de dirección, `f_s`/`c_s` cambian **una sola unidad**
  aunque el botón esté presionado varios ciclos (efecto del detector de
  flanco).
- Al llegar el cursor a (2,1), `ju_valida` sube a 1 (la casilla está en
  `pos_movi`). Con el enter: `estado` pasa por APLICA, se activan
  `add_jugadas` y `load_fc` un ciclo, el caballo salta a (2,1),
  `casillas_pisadas` sube a 2 y `pos_movi` cambia (se recalculó desde
  la nueva posición).
- En (2,2), `ju_valida` está en 0 y el enter **no produce ningún
  cambio**: el estado se queda en ESPERA.

<!-- ![Forma de onda de la partida](docs/onda_juego.png) -->

### 2. Protocolo WS2812 (`tb_ws2812.v`)

```bash
make sim tb=tb_ws2812.v
```

Envía el color `24'hAAAAAA` (bits alternados 1,0,1,0,…) por un solo
LED. Señales recomendadas: `clk`, `init`, `DUT.RGB`, `DOUT`, `DONE`.

Qué se debe observar: 24 pulsos en `DOUT`, alternando anchos. Midiendo
con los cursores de GTKWave (clic para el primer marcador, clic central
para el segundo): los pulsos anchos duran **0.8 µs** (bit 1) y los
angostos **0.4 µs** (bit 0), cada bit ocupa **1.24 µs**, y al final
`DONE` sube a 1. Estos tiempos corresponden exactamente a los
parámetros T1H, T0H y PER de la tabla anterior.

<!-- ![Forma de onda del protocolo](docs/onda_ws2812.png) -->

## Estructura del repositorio

```
.
├── top.v                  # Top-level: conexión cerebro <-> pantalla
├── cursor.v  pos_mov.v  validar_jugada.v  reg_jugadas.v
├── reg_caballo.v  mc.v  detector_flanco.v      # cerebro
├── traductor.v  tablero_temp.v                 # traductor 8x8 -> 16x16
├── ws2812_array.v  ws2812_led.v  ws2812.v ...  # pantalla WS2812
├── display_win.hex  display_lose.hex           # pantallas finales
├── tb_juego.v  tb_ws2812.v                     # testbenches
├── top.lpf                                     # asignación de pines
└── Makefile                                    # syn / config / sim
```
