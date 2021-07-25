vlib work
vmap -c
vmap -c -modelsimini FILL_IN_SIMULATION_LIB_PATH/modelsim.ini
set path_to_quartus C:/intelFPGA_lite/20.1/quartus/bin64/..
vlib work
vmap work work
vcom -work work -2002 -explicit $path_to_quartus/dspba/backend/Libraries/vhdl/base/dspba_library_package.vhd
vcom -work work -2002 -explicit $path_to_quartus/dspba/backend/Libraries/vhdl/base/dspba_library.vhd
vcom  mm_block_pkg.vhd
vcom  Maximum.vhd
vcom  mm_block.vhd
