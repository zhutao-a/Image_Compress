vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/blk_mem_gen_v8_4_2

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm
vmap blk_mem_gen_v8_4_2 modelsim_lib/msim/blk_mem_gen_v8_4_2

vlog -work xilinx_vip -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/include" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/include" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_2 -64 -incr "+incdir+D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/include" \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../system.srcs/sources_1/ip/blk_mem_gen_0_1/sim/blk_mem_gen_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

