onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib c_ram8x365_opt

do {wave.do}

view wave
view structure
view signals

do {c_ram8x365.udo}

run -all

quit -force
