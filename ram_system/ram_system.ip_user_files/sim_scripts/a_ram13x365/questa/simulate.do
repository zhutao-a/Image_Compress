onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib a_ram13x365_opt

do {wave.do}

view wave
view structure
view signals

do {a_ram13x365.udo}

run -all

quit -force
