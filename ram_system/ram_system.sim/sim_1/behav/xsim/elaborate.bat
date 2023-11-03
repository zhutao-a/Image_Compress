@echo off
REM ****************************************************************************
REM Vivado (TM) v2018.3 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Wed Aug 09 23:32:29 +0800 2023
REM SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
REM
REM Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
call xelab  -wto 7c1462a465ca41c1a1bff6414ab7c780 --incr --debug typical --relax --mt 2 -L xil_defaultlib -L blk_mem_gen_v8_4_2 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot tb_jpegls_encoder_behav xil_defaultlib.tb_jpegls_encoder xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
