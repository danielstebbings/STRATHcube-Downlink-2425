%% DVB-S2 HDL Transmitter
% This example shows how to implement a digital video broadcast satellite
% second generation (DVB-S2) transmitter using Simulink(R) blocks that are
% optimized for HDL code generation and hardware implementation.

%   Copyright 2022-2023 The MathWorks, Inc.  

%%
% From this example, you can generate a DVB-S2 transmitter waveform using
% these steps:
%
% # Generate a baseband frame (BBFRAME).
% # Encode using Bose-Chaudhuri-Hocquenghem (BCH) and low-density
% parity-check (LDPC) codes.
% # Interleave, modulate, and generate a physical layer frame (PLFRAME).
% # Insert dummy frames.
% # Pulse shape the symbols in frames using a root raised cosine (RRC)
% filter.

%% Model Architecture
% The BBFRAME Generator block generates BBFRAME from the user packets.
% The FECFRAME Generator block encodes the BBFRAME using BCH and LDPC
% coding, and interleaves the encoded frame to generate an FECFRAME. The
% Symbol Modulator block generates the xFECFRAME by mapping the FECFRAME
% bits to modulation symbols. The PLFRAME Generator block generates the
% PLHEADER, pilot symbols, and  dummy frames, and multiplexes them with the
% xFECFRAME bits. The PL Data Scrambler block scrambles the multiplexer
% output to generate a PLFRAME. The RRC Filtering block pulse shapes the
% PLFRAME symbols to generate the transmitter waveform.
%
% <<../dvbs2hdlTransmitterBlockDiagram.png>>

%%
% This figure shows the transmitter frame structure.
%
% <<../dvbs2hdlTxFrameFormation.png>>

%% File Structure
% This example uses supporting files.

%%
% * |dvbs2hdlTransmitter| &mdash; Model for DVB-S2 HDL transmitter.
% * |dvbs2hdlTransmitterCore| &mdash; Model reference for the transmitter
% design.
% * |dvbs2hdlTxParameters| &mdash; Functions that generates parameters for
% the |dvbs2hdlTransmitterCore| model.
% * |dvbs2hdlTxInit| &mdash; Script that initializes the
% |dvbs2hdlTransmitter| model.
% * |dvbs2hdlTransmitterVerify| &mdash; Script that generates reference
% transmitter waveform using
% <docid:satcom_ref#mw_sysobj_dvbs2WaveformGenerator
% dvbs2WaveformGenerator> function and compares the reference waveform with
% the simulated transmitter output.

%% System Interface
% The figure shows the top-level overview of the |dvbs2hdlTransmitter|
% model.

modelname = 'dvbs2hdlTransmitter';
modelRefname = 'dvbs2hdlTransmitterCore';
open_system(modelname);

%%
% *Model Inputs*
% 
% * *pktBitsIn* &mdash; Input packet bits, specified as a Boolean scalar.
% * *pktStartIn* &mdash; Control signal indicating the start of each
% packet, specified as a Boolean scalar.
% * *pktEndIn* &mdash; Control signal indicating the end of each packet,
% specified as a Boolean scalar.
% * *pktValidIn* &mdash; Control signal indicating whether the
% *pktBitsIn* is valid, specified as a Boolean scalar.
% * *frameStartIn* &mdash; Control signal indicating the start of each
% frame, specified as a Boolean scalar.
% * *frameEndIn* &mdash; Control signal indicating the end of each frame,
% specified as a Boolean scalar.
% * *TSorGS* &mdash; Input stream format, specified as a 2 bit unsigned
% real integer.
% * *DFL* &mdash; Data field length (DFL), specified as a 16 bit unsigned
% real integer.
% * *UPL* &mdash; User packet length (UPL), specified as a 16 bit unsigned
% real integer.
% * *SYNC* &mdash; SYNC word, specified as a 8 bit unsigned real integer.
% * *MODCOD* &mdash; MODCOD, specified as a 5 bit unsigned real integer.
% * *FECFrame* &mdash; FECFrame type, specified as a Boolean scalar.

%%
% *Model Outputs*:
%
% * *dataOut* &mdash; Transmitter output, returned as a 18 bit complex
% scalar.
% * *validOut* &mdash; Control signal indicating whether the *dataOut* is
% valid, returned as a Boolean scalar.
% * *flag* &mdash; Status signal to compute number of dummy frames and real
% frames in the transmit waveform, returned as a 2 bit real scalar.
% * *ready* &mdash; Control signal indicating whether the transmitter is
% ready for the input, returned as a Boolean scalar.

%% Model Structure
% This figure shows the structure of the DVB-S2 HDL transmitter subsystem.
% The subsystem comprises |BB Frame Generator|, |FEC Encoder|, |DVB-S2 HDL
% Interleaver|, |Symbol Modulator|, |PL Frame Generator|, |PL Data
% Scrambler|, and |RRC Transmit Filter| subsystems.

load_system(modelRefname);

open_system([modelRefname '/DVB-S2 Tx'],'force');

%%
% *BB Frame Generator*
%
% The |BB Frame Generator| subsystem comprises |BB Header and Data CRC
% Generator|, |Data Store FIFO|, |Multiplexer|, and |BB Scrambler| subsystems. The
% |BB Header and Data CRC Generator| subsystem generates BB header,
% discards the SYNC bits, appends CRC bits to each packet using the
% <docid:comm_ref#btebeql-1 General CRC Generator HDL Optimized> block, and
% appends padding bits to the data field for each frame. The |Data Store FIFO|
% subsystem stores the data field of each frame in a RAM buffer and reads
% it out after the BB header. The |Multiplexer| subsystem multiplexes the BB
% header and data field. The |BB Scrambler| subsystem scrambles the BB
% header and data field to generate a BBFRAME.

open_system([modelRefname '/DVB-S2 Tx/BB Frame Generator']);

%%
% *FEC Encoder*
%
% The |FEC Encoder| subsystem encodes the input bits with |BCH Encoder|
% subsystem  followed by |LDPC Encoder| subsystem. For more information,
% see <docid:whdl_ug#example-dvbs2bchencoder DVB-S2 HDL BCH Encoder> and
% <docid:whdl_ug#mw_3ec6ef70-e7f7-424a-8e74-d150b4dab6e1 DVB-S2 HDL LDPC
% Encoder> examples.

open_system([modelRefname '/DVB-S2 Tx/FEC Encoder']);

%%
% *DVB-S2 HDL Interleaver*
%
% The |DVB-S2 HDL Interleaver| subsystem stores encoded bits from the |LDPC
% Encoder| subsystem inside the |RAM| subsystem. The |RAM Address
% Generator| subsystem generates read and write addresses for the RAM for
% interleaving.

open_system([modelRefname '/DVB-S2 Tx/Interleaver/DVB-S2 HDL Interleaver'],'force');

%%
% In the |RAM Address Generator| subsystem, the |nRows and nColumns|
% subsystem stores the number of rows and columns of each possible
% configuration in lookup tables (LUT). Based on the *MODCOD* and
% *FECFrame* parameters, the subsystem determines the number of rows and
% columns for interleaving. The |Read Offset Address| subsystem generates
% the interleaver indices of each frame as an offset address. The subsystem
% reads only two bits are read for QPSK, three bits for 8-PSK, four bits
% for 16-APSK, and five bits for 32-APSK every eight time steps. This
% process ensures that each symbol covers eight time steps of the
% interleaver, which is equal to one symbol duration. The |Generate and Add
% Read Base Address| subsystem adds the offset address with a base read
% address to get the address of the bits that are stored in the RAM. The
% |Parameter Store FIFO| subsystem stores the parameters and reads them at
% the start of each frame.

open_system([modelRefname '/DVB-S2 Tx/Interleaver/DVB-S2 HDL Interleaver/RAM Address Generator']);

%%
% This table shows the rows and columns for deinterleaving in
% each of the configurations.

 F = table(...
    categorical({'QPSK';'8-PSK'; '16-APSK'; '32-APSK'}),...
    categorical({'64800';'21600'; '16200'; '12960'}),...
    categorical({'16200';'5400'; '4050'; '3240'}),...
    categorical({'1';'3'; '4'; '5'}),...
    'VariableNames',...
    {'Modulation','Rows (Normal)','Rows (Short)','Columns'});

disp(F);

%%
% *Symbol Modulator*
%
% The |Symbol Modulator| subsystem comprises
% <docid:whdl_ref#mw_3ba2ef85-7224-48d0-9ba7-9926d1fb6007 DVB-S2 Symbol
% Modulator> block that maps the input bits to the corresponding modulation
% symbols.

open_system([modelRefname '/DVB-S2 Tx/Symbol Modulator']);

%%
% *PL Frame Generator*
%
% The |PL Frame Generator| subsystem stores the modulated symbols in the
% |RAM FIFO| subsystem. The |PL Header Generator| subsystem generates the
% PLHEADER for each frame and stores it in the |RAM FIFO| subsystem. When
% symbols corresponding to a frame are ready in the RAM, the |PL Frame
% Generator| subsystem outputs the PLHEADER, pilot symbols, and data
% symbols according to the frame structure specified in [ <#22 1> ]. When
% the symbols corresponding to a frame are not ready, the |Dummy Frame
% Generator| subsystem inside the |RAM FIFO| subsystem outputs dummy
% frames. The |Multiplexer| subsystem multiplexes the PLHEADER, pilot
% symbols, data symbols, and dummy frames to generate a unscrambled
% PLFRAME. The |PL Data Scrambler| subsystem scrambles the data field
% excluding the PLHEADER. The scrambling starts after the PLHEADER of each
% frame and continues until the end of the frame.

open_system([modelRefname '/DVB-S2 Tx/PL Frame Generator']);

%%
% *RRC Transmit Filter*
%
% The |RRC Transmit Filter| subsystem upsamples the input by a factor of
% four and uses the <docid:dsphdl_ref#bvi0_ng-1 Discrete FIR Filter> block
% with an RRC impulse response to pulse shape the PLFRAME symbols.

open_system([modelRefname '/DVB-S2 Tx/RRC Transmit Filter']);

%% Run Model
% Set the symbol rate, *MODCOD*, *FECFrame* type, input stream format,
% and user packet length on the mask of the |Input Configuration| subsystem
% and run the |dvbs2hdlTransmitter| model.  Set the same symbol rate for
% the |Input Configuration| subsystem in the |dvbs2hdlTransmitter| model,
% the |DVB-S2 Tx| subsystem of the |dvbs2hdlTransmitterCore| model
% reference. Alternatively, execute this command at the
% MATLAB Command Window to run the model.
% 
% |sim dvbs2hdlTransmitter|
%
% The *MODCOD* and *FECFrame* must be row vectors. Each element of
% the row vectors corresponds to the values of *MODCOD* and *FECFrame* in a
% frame.

close_system(modelname,0);
close_system(modelRefname,0);

%% Verification and Results
% Run the model to display the transmitter spectrum, error plot between the
% reference waveform and simulation output, and relative mean squared error
% of the simulation output.

load_system(modelname);
h = get_param([modelname '/Capture Data/Spectrum Analyzer'],'ScopeConfiguration');
h.Visible = true;
sim(modelname);

%% HDL Code Generation
%
% To generate the HDL code for this example, you must have HDL Coder(TM).
% Use |makehdl| and |makehdltb| functions to generate HDL code and HDL
% test bench for the |DVB-S2 HDL transmitter| subsystem. The
% test bench generation time depends on the simulation time.
%
% The resulting HDL code is synthesized for a Xilinx(R) Zynq(R) UltraScale+
% RFSoC ZCU111 board. This table shows the post place and route resource
% utilization. The maximum frequency of operation is 365 MHz.

%%
 F = table(...
    categorical({'CLB LUT'; 'CLB Registers'; 'RAMB36'; 'RAMB18';...
    'DSP48'}),...
    categorical({'10701'; '9024'; '99'; '6'; '42'}),...
    'VariableNames',...
    {'Resources','Usage'});

disp(F);

%% References
% # ETSI EN 302 307-1. _Digital Video Broadcasting 
% (DVB); Second Generation Framing Structure, Channel Coding and Modulation Systems 
% for Broadcasting, Interactive Services, News Gathering and other Broadband Satellite 
% Applications (DVB-S2)_.
% # ETSI TR 102 376-1. _Digital Video Broadcasting 
% (DVB); Implementation Guidelines for the Second Generation System for
% Broadcasting, Interactive Services, News Gathering and other Broadband
% Satellite Applications (DVB-S2)_.

close_system(modelname,0);
