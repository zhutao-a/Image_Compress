onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+n_ram7x365 -L xilinx_vip -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_2 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.n_ram7x365 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {n_ram7x365.udo}

run -all

endsim

quit -force
