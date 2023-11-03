onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib b_ram9x365_opt

do {wave.do}

view wave
view structure
view signals

do {b_ram9x365.udo}

run -all

quit -force
