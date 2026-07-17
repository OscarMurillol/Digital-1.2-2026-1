help: help-syn
clean: clean-syn clean-sim
top=top

DESIGN=top.v cursor.v detector_flanco.v mc.v pos_mov.v validar_jugada.v reg_jugadas.v reg_caballo.v
DESIGN+=traductor.v
DESIGN+=tablero_temp.v
# PANTALLA
DESIGN+=ws2812_array.v
DESIGN+=comp_arr.v
DESIGN+=control_arr.v
DESIGN+=count_arr.v
DESIGN+=ws2812_led.v
DESIGN+=control_wsl.v
DESIGN+=count_wsl.v
DESIGN+=shift_wsl.v
DESIGN+=ws2812.v
DESIGN+=control_ws.v
DESIGN+=count_ws.v
DESIGN+=comp_ws.v
DESIGN+=multiplexor_ws.v
DIR_BUILD=build
Z=caballo

#################################################
###--- Rules from colorlight-5a-75e-syn.mk ---###
#################################################
top_NAME=$(basename $(notdir $(DESIGN)))
top?=$(top_NAME)
LPF?=$(top).lpf
JSON?=$(DIR_BUILD)/$(top).json
PNR?=$(DIR_BUILD)/$(top).pnr
BISTREAM?=$(DIR_BUILD)/$(top).bit
LOG_YOSYS?=$(DIR_BUILD)/yosys-$(top).log
LOG_NEXTPNR?=$(DIR_BUILD)/nextpnr-$(top).log
MACROS_SYN := $(foreach macro,$(MACROS_SYN),"$(macro)")

help-syn:
	@printf "\n## SINTESIS Y CONFIGURACIÓN ##\n"
	@printf "\tmake syn\t\t-> Sintetizar diseño\n"
	@printf "\tmake config\t\t-> Configurar fpga en SRAM\n"
	@printf "\tmake config-flash\t-> Guardar el bistream en memoria flash\n"
	@printf "\tmake detect\t\t-> Detectar FPGA\n"
	@printf "\tmake reset\t\t-> Reiniciar FPGA\n"
	@printf "\tmake erase-flash\t-> Borrar la memoria flash de configuración\n"
	@printf "\tmake log-syn\t\t-> Ver el log de la síntesis con Yosys\n"
	@printf "\tmake log-pnr\t\t-> Ver el log del place&route con nextpnr\n"
	@printf "\tmake clean\t\t-> Limpiar síntesis\n"

syn: json pnr bitstream

OBJS+=$(DESIGN)

$(JSON): $(OBJS)
	mkdir -p $(DIR_BUILD)
	yosys $(MACROS_SYN) -p "synth_ecp5 -top $(top) -json $(JSON)" $(OBJS) -l $(LOG_YOSYS)

log-syn:
	less $(LOG_YOSYS)

$(PNR): $(JSON)
	nextpnr-ecp5 --25k --package CABGA256 --speed 6 --json $(JSON) --lpf $(LPF) --freq 65 --textcfg $(PNR) --log $(LOG_NEXTPNR)

log-pnr:
	less $(LOG_NEXTPNR)

$(BISTREAM): $(PNR)
	ecppack $(PNR) $(BISTREAM)

# USB-UART
CABLE= -c ft232RL
FT232RL_TXD=0
FT232RL_RXD=1
FT232RL_RTS=2
FT232RL_CTS=3
FT232RL_DTR=4
FT232RL_DSR=5
FT232RL_DCD=6
FT232RL_RI=7
TDI=$(FT232RL_TXD)
TDO=$(FT232RL_CTS)
TCK=$(FT232RL_DTR)
TMS=$(FT232RL_RXD)
CABLE_PINES?=$(TDI):$(TDO):$(TCK):$(TMS)

CONFIG_OPTIONS+=$(CABLE)
ifneq ($(CABLE_PINES),)
CONFIG_OPTIONS+= --pins=$(CABLE_PINES)
endif
CONFIG_OPTIONS+= --verbose
CONFIG_OPTIONS+= --freq 3000000

PATH_OPEN_FPGA_LOADER=openFPGALoader

reset:
	$(PATH_OPEN_FPGA_LOADER) $(CONFIG_OPTIONS)  -r

detect:
	$(PATH_OPEN_FPGA_LOADER) $(CONFIG_OPTIONS) --detect $(OPTIONS_CABLE)

config-flash:
	$(PATH_OPEN_FPGA_LOADER) $(CONFIG_OPTIONS) -f $(BISTREAM) --unprotect-flash

erase-flash:
	$(PATH_OPEN_FPGA_LOADER) $(CONFIG_OPTIONS) --bulk-erase --unprotect-flash

config-sram:
	$(PATH_OPEN_FPGA_LOADER) $(CONFIG_OPTIONS) -m $(BISTREAM)

config: config-sram

json:$(JSON)
pnr:$(PNR)
bitstream:$(BISTREAM)

clean-syn:
	$(RM) -rf $(DIR_BUILD)

.PHONY: clean

###############################
###--- SIMULACIÓN ---###
###############################
# Uso:
#   make sim                  -> simula el juego completo (tb_juego.v)
#   make sim tb=tb_ws2812.v   -> simula el protocolo de un LED
S=sim
tb?=tb_juego.v
TBN=$(basename $(notdir $(tb)))

sim: sim-compile sim-run wave

sim-compile:
	mkdir -p $S
	iverilog -o $S/$(TBN).vvp -s $(TBN) $(tb) $(DESIGN)

sim-run:
	vvp $S/$(TBN).vvp

wave:
	gtkwave $S/$(TBN).vcd &

clean-sim:
	$(RM) -rf $S
