// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:apb_reg:1.0
// IP Revision: 5

(* X_CORE_INFO = "apb_reg,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "system_apb_reg_0_1,apb_reg,{}" *)
(* CORE_GENERATION_INFO = "system_apb_reg_0_1,apb_reg,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=apb_reg,x_ipVersion=1.0,x_ipCoreRevision=5,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,data_width=32,addr_width=32,base_addr=0x43C00000}" *)
(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module system_apb_reg_0_1 (
  clk,
  rstn,
  s_apb_paddr,
  s_apb_penable,
  s_apb_pprot,
  s_apb_prdata,
  s_apb_pready,
  s_apb_psel,
  s_apb_pslverr,
  s_apb_pstrb,
  s_apb_pwdata,
  s_apb_pwrite,
  tile_width,
  tile_height,
  en_or_de,
  encode_done,
  byte_len
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_RESET rstn, FREQ_HZ 40000000, PHASE 0.000, CLK_DOMAIN system_processing_system7_0_1_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rstn RST" *)
input wire rstn;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PADDR" *)
input wire [31 : 0] s_apb_paddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PENABLE" *)
input wire s_apb_penable;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PPROT" *)
input wire [2 : 0] s_apb_pprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PRDATA" *)
output wire [31 : 0] s_apb_prdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PREADY" *)
output wire s_apb_pready;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PSEL" *)
input wire s_apb_psel;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PSLVERR" *)
output wire s_apb_pslverr;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PSTRB" *)
input wire [3 : 0] s_apb_pstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PWDATA" *)
input wire [31 : 0] s_apb_pwdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PWRITE" *)
input wire s_apb_pwrite;
output wire [8 : 0] tile_width;
output wire [8 : 0] tile_height;
output wire en_or_de;
input wire encode_done;
input wire [8 : 0] byte_len;

  apb_reg #(
    .data_width(32),
    .addr_width(32),
    .base_addr('H43C00000)
  ) inst (
    .clk(clk),
    .rstn(rstn),
    .s_apb_paddr(s_apb_paddr),
    .s_apb_penable(s_apb_penable),
    .s_apb_pprot(s_apb_pprot),
    .s_apb_prdata(s_apb_prdata),
    .s_apb_pready(s_apb_pready),
    .s_apb_psel(s_apb_psel),
    .s_apb_pslverr(s_apb_pslverr),
    .s_apb_pstrb(s_apb_pstrb),
    .s_apb_pwdata(s_apb_pwdata),
    .s_apb_pwrite(s_apb_pwrite),
    .tile_width(tile_width),
    .tile_height(tile_height),
    .en_or_de(en_or_de),
    .encode_done(encode_done),
    .byte_len(byte_len)
  );
endmodule
