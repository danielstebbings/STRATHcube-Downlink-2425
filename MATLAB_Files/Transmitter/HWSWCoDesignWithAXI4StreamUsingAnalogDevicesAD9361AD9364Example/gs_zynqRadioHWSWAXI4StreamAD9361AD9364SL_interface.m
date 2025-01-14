%--------------------------------------------------------------------------
% Host Interface Script
% 
% Generated with MATLAB 24.2 (R2024b) at 13:40:30 on 14/01/2025.
% This script was created for the IP Core generated from design 'zynqRadioHWSWAXI4StreamAD9361AD9364SL'.
% 
% Use this script to access DUT ports in the design that were mapped to compatible IP core interfaces.
% You can write to input ports in the design and read from output ports directly from MATLAB.
% To write to input ports, use the "writePort" command and specify the port name and input data. The input data will be cast to the DUT port's data type before writing.
% To read from output ports, use the "readPort" command and specify the port name. The output data will be returned with the same data type as the DUT port.
% Use the "release" command to release MATLAB's control of the hardware resources.
%--------------------------------------------------------------------------

%% Program FPGA
% Uncomment the lines below to program FPGA hardware with the designated bitstream and configure the processor with the corresponding devicetree.
% MATLAB will connect to the board with an SSH connection to program the FPGA.
% If you need to change login parameters for your board, using the following syntax:
% hProcessor = xilinxsoc(ipAddress, username, password);
hProcessor = xilinxsoc();
% programFPGA(hProcessor, "hdl_prj/vivado_ip_prj/vivado_prj.runs/impl_1/system_top.bit", "devicetree_fmc_axis.dtb");

%% Create fpga object
hFPGA = fpga(hProcessor);

%% Setup fpga object
% This function configures the "fpga" object with the same interfaces as the generated IP core
gs_zynqRadioHWSWAXI4StreamAD9361AD9364SL_setup(hFPGA);

%% Write/read DUT ports
% Uncomment the following lines to write/read DUT ports in the generated IP Core.
% Update the example data in the write commands with meaningful data to write to the DUT.
%% AXI4-Lite
% writePort(hFPGA, "maxTxCount", zeros([1 1]));
% writePort(hFPGA, "txStart", zeros([1 1]));
% writePort(hFPGA, "txSel", zeros([1 1]));

%% AXI4-Stream Write
% data_AXI4S_Data_Out = readPort(hFPGA, "AXI4S_Data_Out");

%% AXI4-Stream Read
% writePort(hFPGA, "AXI4S_Data_In", zeros([1024 1]));

%% Release hardware resources
release(hFPGA);

