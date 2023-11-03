onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib n_ram7x365_opt

do {wave.do}

view wave
view structure
view signals

do {n_ram7x365.udo}

run -all

quit -force
