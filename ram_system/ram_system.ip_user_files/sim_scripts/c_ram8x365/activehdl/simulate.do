onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+c_ram8x365 -L xilinx_vip -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_2 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.c_ram8x365 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {c_ram8x365.udo}

run -all

endsim

quit -force
