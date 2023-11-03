-makelib xcelium_lib/xilinx_vip -sv \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/BaiduNetdiskDownload/vivado2018.3/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/axi_infrastructure_v1_1_0 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_vip_v1_1_4 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/98af/hdl/axi_vip_v1_1_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/processing_system7_vip_v1_0_6 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/70cf/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_processing_system7_0_1/sim/system_processing_system7_0_1.v" \
-endlib
-makelib xcelium_lib/lib_pkg_v1_0_2 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/64f4/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/64f4/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/64f4/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/lib_fifo_v1_0_12 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/544a/hdl/lib_fifo_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/lib_srl_fifo_v1_0_2 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/lib_cdc_v1_0_2 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_datamover_v5_1_20 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/dfb3/hdl/axi_datamover_v5_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_sg_v4_1_11 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/efa7/hdl/axi_sg_v4_1_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_dma_v7_1_19 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/09b0/hdl/axi_dma_v7_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_dma_0_1/sim/system_axi_dma_0_1.vhd" \
-endlib
-makelib xcelium_lib/generic_baseblocks_v2_1_0 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_register_slice_v2_1_18 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/cc23/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_data_fifo_v2_1_17 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/c4fd/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_crossbar_v2_1_19 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/6c9d/hdl/axi_crossbar_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_xbar_0/sim/system_xbar_0.v" \
-endlib
-makelib xcelium_lib/axi_apb_bridge_v3_0_14 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/2f3b/hdl/axi_apb_bridge_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_apb_bridge_0_0/sim/system_axi_apb_bridge_0_0.vhd" \
-endlib
-makelib xcelium_lib/xlconcat_v2_1_1 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/2f66/hdl/xlconcat_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_xlconcat_0_0/sim/system_xlconcat_0_0.v" \
  "../../../bd/system/ipshared/f5ed/apb_reg.v" \
  "../../../bd/system/ip/system_apb_reg_0_1/sim/system_apb_reg_0_1.v" \
  "../../../bd/system/ip/system_encoder_top_0_0/sim/system_encoder_top_0_0.v" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/sim/bd_8562.v" \
-endlib
-makelib xcelium_lib/xlconstant_v1_1_5 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/4649/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_0/sim/bd_8562_one_0.v" \
-endlib
-makelib xcelium_lib/proc_sys_reset_v5_0_13 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_1/sim/bd_8562_psr_aclk_0.vhd" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/979d/hdl/sc_util_v1_0_vl_rfs.sv" \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/c012/hdl/sc_switchboard_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_2/sim/bd_8562_arsw_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_3/sim/bd_8562_rsw_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_4/sim/bd_8562_awsw_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_5/sim/bd_8562_wsw_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_6/sim/bd_8562_bsw_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/f85e/hdl/sc_mmu_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_7/sim/bd_8562_s00mmu_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/ca72/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_8/sim/bd_8562_s00tr_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/9ade/hdl/sc_si_converter_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_9/sim/bd_8562_s00sic_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/b89e/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_10/sim/bd_8562_s00a2s_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/b2d0/hdl/sc_node_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_11/sim/bd_8562_sarn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_12/sim/bd_8562_srn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_13/sim/bd_8562_sawn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_14/sim/bd_8562_swn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_15/sim/bd_8562_sbn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_16/sim/bd_8562_s01mmu_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_17/sim/bd_8562_s01tr_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_18/sim/bd_8562_s01sic_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_19/sim/bd_8562_s01a2s_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_20/sim/bd_8562_sarn_1.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_21/sim/bd_8562_srn_1.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_22/sim/bd_8562_s02mmu_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_23/sim/bd_8562_s02tr_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_24/sim/bd_8562_s02sic_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_25/sim/bd_8562_s02a2s_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_26/sim/bd_8562_sawn_1.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_27/sim/bd_8562_swn_1.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_28/sim/bd_8562_sbn_1.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/7005/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_29/sim/bd_8562_m00s2a_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_30/sim/bd_8562_m00arn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_31/sim/bd_8562_m00rn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_32/sim/bd_8562_m00awn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_33/sim/bd_8562_m00wn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_34/sim/bd_8562_m00bn_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/b387/hdl/sc_exit_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_35/sim/bd_8562_m00e_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_36/sim/bd_8562_m01s2a_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_37/sim/bd_8562_m01arn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_38/sim/bd_8562_m01rn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_39/sim/bd_8562_m01awn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_40/sim/bd_8562_m01wn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_41/sim/bd_8562_m01bn_0.sv" \
  "../../../bd/system/ip/system_axi_smc_2/bd_0/ip/ip_42/sim/bd_8562_m01e_0.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_axi_smc_2/sim/system_axi_smc_2.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_rst_ps7_0_10M_0/sim/system_rst_ps7_0_10M_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/sim/system.v" \
-endlib
-makelib xcelium_lib/axi_protocol_converter_v2_1_18 \
  "../../../../reg_system.srcs/sources_1/bd/system/ipshared/7a04/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/system/ip/system_auto_pc_0/sim/system_auto_pc_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

