#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"
#import "@preview/wavy:0.1.1"
#import "@preview/codelst:2.0.2": sourcecode
#show raw.where(lang: "wavy"): it => wavy.render(it.text)

#set heading(offset: 1)


= Transmitter

== Tool Selection
There were multiple options for implementation of the #acr("DVB-S2") subsytem. 

#figure(
  table(
    columns:4,
    align:(left,center,center,center,),
    table.header(
      [*Method*],[*Type*],[*Advantage*],[*Disadvantage*]
    ),
    [GNU Radio software implementation],         [Software],   [Simplicity of implementation],             [Slower processing speed],
    [COTS IP Core],                               [Hardware],   [Pre-tested, guaranteed reliability],       [Expensive, could complicate integration with PBR system],
    [Vitis Model Composer],                       [Hardware],   [Simplicity of implementation, Can be fully verified using MatLab simulation],             [Would have to implement interface with transceiver block manually, taking more development time.],
    [Scratch implementation in VHDL or Verilog], [Hardware],    [Highest resource efficiency.],             [Will require much more development time, as well as much increased testing time],
    [MATLAB HDL Coder],                   [Hardware], [Supports AD936x transceiver as a target. Can be fully verified using MatLab simulation], [Poorer resource efficiency],   
  ),
  caption:"Implementation Tool Tradeoff"
)

== DVB-S2 Modulation
=== Bandwidth and Symbol Rate
The block design has a sample rate dependent on the symbol rate of the transmitter, to limit the clock domains on the design, this was used to define the sample rate for the entire system.

The single sided bandwidth of a modulated DVB-S2 signal is a function of the symbol rate, $R_s$, and the roll-off factor, #sym.alpha, of the root raised cosine filter as shown in @bandwidth. This can be rearrange to find the highest symbol rate for a given bandwidth, as shown in @symbolrate.


$ B_"single" = f_N (1+ #sym.alpha) \
 "Where" f_N = R_s /2 $ <bandwidth>

$ R_s =  (B_"double") / (1+ #sym.alpha) \
 "Where" B_"double" = 2B_"single" $ <symbolrate>

The standard allows for a roll-off factor of 0.35, 0.25 or 0.20. For the target bandwidth of 150 kHz, this gives the theoretical maximum symbol rates shown in @roll-off2Rs.

#figure(
  table(
    columns:2,
    align:(center,center),
    table.header(
      [*#sym.alpha*],[*$R_S$ (Symbols / sec)*]
    ),
    [0.35],[111,111],
    [0.25],[120,000],
    [0.20],[125,000],
  ),
  caption: "Symbol rate vs roll-off factor"
) <roll-off2Rs>

This results in a tradeoff between maximum symbol rate and the roll-off factor, which is linked to the complexity of the filter. A pulse shaping filter with more weights is required to achieve the higher symbol rates, which increases the overall resource requirements of the design. 

With this filter in place, the expected bitrate can be re-calculated for each roll-off factor, with the spectral efficiency values from @modcod_reqs_150khz, the result is shown in @bitrateVrolloff. Note that the resulting datarates are lower than in @ACM-Analysis-Section as the usable bandwidth has lowered.

#figure(
  image("../Figures/Implementation/roll-off/roll-off-investigation.svg"),
  caption:"Bitrate achievable by modulation, coding rate, and roll-off factor (Alpha).",
) <bitrateVrolloff>

For most of the settings, all three have relatively similar performance. As the modulation and coding rates get higher, the differences become more apparent. Overall, the difference between #sym.alpha = 0.25 and #sym.alpha = 0.20 is minimal, but #sym.alpha = 0.35 consistently performs significantly worse than the other two.

It was determined in @ACM-Analysis-Section that the majority of time during a pass will be using the lower modulation and coding rate settings, so it was decided to use #sym.alpha = 0.25 to save some resources. Through simulation, it was determined that a symbol rate of 125,000 Symbols / second using this rolloff was achievable, while staying within the ITU spectrum mask, see @DAC-Spectrum-ITU-Mask.


=== Transmitter block
//TODO: DVB-S2 HDL Coder citation
The core of the design is built upon a DVB-S2 HDL coder example implementation created by Mathworks. This block implements all of the necessary logic for the modulation of a bitstream into a valid DVB-S2 signal.

#pagebreak()
#figure(
  rotate(image("../Figures/Implementation/MATLAB-Examples/DVB-S2-Tx.png")),
  caption:"DVB-S2 HDL Transmitter MATLAB Example Design"
)
#pagebreak()

//TODO: SYNC
#figure(
  table(
    columns:4,
    align:(left,center,center,center),
    table.header(
      [*Port*],[*Direction*],[*Type*],[*Purpose*],
    ),
    table.cell(colspan: 4,  align:center, [*Sideband Signals*]),
    [pktValidIn],   [Input],[Boolean],        [Indicates that input data is valid],
    [pktBitsIn],    [Input],[Boolean Stream], [Information for transmission],
    [pktStartIn],   [Input],[Boolean],        [Indicates packet start, not used for continuous stream],
    [pktEndIn],     [Input],[Boolean],        [Indicates packet end, not used for continuous stream],
    [frameStartIn], [Input],[Boolean],        [Indicates frame start],
    [frameEndIn],   [Input],[Boolean],        [Indicates frame end],
    table.cell(colspan: 4,  align:center, [*Control Signals*]),
    [TSorGS],      [Input],[ufix2],          [Indicates if transport stream, continuous or packetised generic stream],
    [DFL],         [Input],[uint16],         [Data Field Length, can be from 0 to $K_"BCH"$],
    [UPL],         [Input],[uint16],         [User Packet Length, 0 for continuous stream, up to $K_"BCH"$],
    [SYNC],        [Input],[uint8],          [],
    [MODCOD],      [Input],[ufix5],          [MODulation and CODing rate selection],
    [FECFRAME],    [Input],[boolean],        [FECFRAME length selection. 1 for ],
    table.cell(colspan: 4,  align:center, [*Output*]),
    [dataOut],    [Output],[ufix18en16 (c)], [IQ output data. 18 bit complex fixed point data with 16 fraction bits],
    [validOut],   [Output],[boolean],        [Indicates that IQ data is valid],
    [flag],       [Output],[ufix2],          [Flag bits to indicate when a dummy frame is sent, and when a real frame is sent.],
    [nextFrame],  [Output],[boolean],        [Asserted when transmitter is ready for next frame. Is reset when frameStart is asserted],

    
  ),
  caption: "DVB-S2 Transmitter Ports"
)
// TODO: rolloff investigation



== PL System Integration
//TODO: HW/SW
=== Hardware-Software Co-Design
The transmission subsystem required an interface with both with the packet handling software on the PS and the external transceiver chip. It was decided to use the Hardware-Software Co-Design features of HDL coder to accomplish this. 

The Co-Design workflow starts with the creation of an IP block using HDL coder with a specific interface. This design is then automatically integrated into a predefined "reference design" in Vivado and can be synthesised and implemented on hardware. Additionally, software drivers can be generated to handle the PS-PL interface.

// TODO: Include a hwsw flow design here

This workflow massively simplifies the PS-PL interfacing, which is one of the most challenging parts of an SoC FPGA design. However, it comes with some drawbacks. The first is that the design is limited in that it must conform to the reference design. If there is not a reference design for the target platform this must be implemented manually, a non-trivial process. Additionally, any other software running on the PS will have to integrate with the generated C code, an area that appeared to have little documentation or examples.

// TODO: Reference hwsw chirp
A Co-Design example project was used as a template to ensure that all necessary interfaces were generated in order to comply with the requirements of the reference design. This example project had support for both receive and transmit, which would allow both the PBR and downlink communications systems to be implemented on the same design. The top level interface is shown in @hwswchirp.

#figure(
  image("../Figures/Implementation/MATLAB-Examples/HWSWCodesign.png"),
  caption: "HW/SW Co-Design Chirp Example. The logic to be implemented on the PL is defined within the orange block. External blocks are used to verify operation."
) <hwswchirp>

Data is transferred from the #acr("PS") via one of two methods. AXI-lite interfaces are used for control signals, as they have lower throughput, this was used for all control signals, such as #acf("DFL"), #acr("UPL"), etc. An AXI-Stream was used to transfer packet data, as it has a much higher throughput.

//TODO: Ensure all AXI-Lite mentions capitalised correctly.
The reference design included an AXI-Stream for the transfer of data from the PS to the design, and separate I and Q ports to connect to the transceiver. Additional control signals could be implemented using AXI-Lite and the design included further ports for implementation of the receiving logic.

An AXI-Stream interface can be implemented with as few as three signals, TData, TValid and TReady but there are several optional signals defined in the standard, the most relevant being TLast and TUser. TLast is used to indicate the final AXI packet in a stream, while TUser can be used to carry any arbitrary user defined data, commonly being information to control the transfer such as flags. These signals are summarised in @Relevant-AXI-Signals. 

#figure(
  table(
    columns:3,
    align:(left,center,center),
    table.header(
      [*Signal*],[*Type*],[*Purpose*]
    ),
    [TData],  [uint32 ],  [Data to be transferred from master to slave],
    [TValid], [boolean], [Indication from master to slave that data is valid and can be read],
    [TReady], [boolean], [Indication from slave to master that it is ready for new data],
    [TLast],  [boolean], [Indication from master to slave that the current packet is the last in the current stream (optional)],
    [TUser],  [User Defined], [Encodes extra information about the transfer (optional)]


  ),
  caption: "Relevant AXI-Stream Signals"
) <Relevant-AXI-Signals>

TData is listed as 32 bits here although by the standard this can be any integer number of bytes. This is due to the fact that the physical PS-PL interface on the Zynq 7020 is 32 bits wide, meaning wider interfaces require more complexity. Additionally, the PS connects to the PL through AXI-MM memory mapped interfaces, with additional PL logic required to interface with a stream. This means that the creation of TUser signalling synchronised with the AXI-Stream is non-trivial.

An AXI-Stream transfer occurs on the rising edge of the clock, when both TReady is asserted by the slave, and TValid by the master. This process is shown in @AXI-Stream-Timing for a minimal stream.


//TODO: Axi stream citation
#figure(
```wavy
{
  signal:
  [
    //. -> repeat last
    //p -> pulse
    // 1 / 0 -> signal for whole timestep
    {                 node:'..ACEGI', phase:'0.14'}, // Start of lines
    {name:'ACLK',     wave:'p......'},
    ['Master',
      {name:'TDATA',  wave:'x.34.5.',data:'1 2 3'},
      {name:'TVALID', wave:'0.34.5.'},
    ],
    ['Slave',
      {name:'TREADY', wave:'07...0.'},
    ],
    {name:'', node:'..BDFHJ', phase:'0.14'},
  ],
  edge: [
    'A-|B',
    'C-|D',
    'E-|F',
    'G-|H',
    'I-|J',
  
  ],
  foot: {
    text:[
      'tspan', 
    //['tspan', {dy:'-5'}, 'wdwdwd'],
      ['tspan', {x: '80',dy:'-25',class:'h6'}, 'NO XFR'],
      ['tspan', {x: '120',dy:'0',class:'h6'}, 'XFR 1'],
      ['tspan', {x: '160',dy:'0',class:'h6'}, 'XFR 2'],
      ['tspan', {x: '200',dy:'0',class:'h6'}, 'XFR 2'],
      ['tspan', {x: '245',dy:'0',class:'h6'}, 'NO XFR'],
    ],
      
      
  }
}
```,
caption: "Minimal AXI-Stream timing diagram. A transfer (XFR) occurs on the active edge of the clock when both TVALID and TREADY are high. TDATA can change after a transfer occurs, but must be held once TVALID is asserted until the next transfer.",
kind:image,
) <AXI-Stream-Timing>

=== DVB-S2 Transmitter integration

The selected template architecture suited the requirements for the downlink transmission system well. Control signals could be implemented using the AXI-Lite interface, as they can be asserted at any point before the next frame has started. The packet and sideband data could then be transferred using the AXI-Stream, as this required much higher datarates and guaranteed alignment.

For the reasons mentioned previously, it was determined that the implementation of the sideband signals using the TUSER features of the AXI-Stream would overcomplicate implementation as the interface is determined by the reference design. These signals would instead be transferred within the 32 bit TDATA stream.

The remaining 28 bits could then be used to carry the packet data. No DFL size was evenly divisible by 28, giving two avenues for implementation. The first option was to implement a signalling system within the TDATA field allowing for a variable amount of packet bits within each TDATA field. The second was to find the largest number that factored all possible DFL sizes and accept the lower performance.

//TODO: Fastest 
The maximum DFL sizes corresponding to all valid modulation and coding rates, as shown in @DFL-Sizes, were factorised and the largest common factor found to be 8, giving a maximum of 1 byte per AXI packet without additional signalling.

AXI-Streams can transfer data much faster than the resultant symbols could be transmitted, so it was decided to accept the performance loss of using a subset of the TDATA field as it greatly reduced complexity. The performance impact was minimal, as each packet needed to be serialised over multiple clock cycles anyway. The resultant TDATA structure is shown in @AXI-Pkts.

#figure(
  table(
    columns:2,
    align:(left,center),
    [*Normal FECFRAME*],[15928, 21328, 25648, 32128, 38608, 42960, 48328, 51568, 53760, 57392, 58112],
    [*Short FECFRAME*], [2992,  5152,  6232,  6952,  9472, 10552, 11632, 12352, 13072, 14152],

  ),
  caption: "Possible DFL Sizes (bits)"
) <DFL-Sizes>


#subpar.grid(
  columns: (1fr),
  caption: [Designed TDATA structure.],
  label: <AXI-Pkts>,
  //figure(
  //  image("../Figures/Implementation/Packets/AXI_pkt_1.svg",width:100%),
  //  caption: "AXI Packet With Sidebands"
  //),<AXI-Packet-Sidebands>,
  figure(
    image("../Figures/Implementation/Packets/AXI_pkt_2.svg",width:100%),
    //caption: "AXI Packet Final Structure"
  ), <AXI-Packet-Structure>,
)


// TODO: FIFO axi stream explanation

// TODO: Packet Parser

The AXI packets were transferred as uint32 words, which required serialisation for interface with the #acr("DVB-S2") transmitter block. This introduced multiple rates for the interface, for which a FIFO buffer was implemented as it could be used to manage the AXI-Stream interface logic.

The implementation of the TREADY handling is very important for an AXI-Stream slave and is a common source of issues within an AXI based design. The DVB-S2 transmitter block asserts nextFrame to indicate it is ready for data and deasserts it once frameStart has been asserted, however the AXI-Stream required TREADY to be high for the entire frame. This resulted in the circuit shown in @TREADY-Circuit, with the intended timings shown in @AXI-Stream-FIFO-Timing.

#figure(
  image("../Figures/Implementation/Timing Diagrams/TREADY-Circuit.svg",width:70%),
  caption:"AXI-Stream TREADY generation logic. nextFrame is connected to the Set input of an SR flip flop, and frame end to the Reset. The output of this is then ANDed with FIFO nFull."
) <TREADY-Circuit>


#figure(
```wavy
{
  signal:
  [
    //. -> repeat last
    //p -> pulse
    // 1 / 0 -> signal for whole timestep
    {name:'ACLK',     	  wave:'p.|..|..|..|..|..|..'},
    
    //{name:'nFull',  wave:'x.34.5.',data:'1 2 3'},
    {name:'tx_nextFrame', wave:'30|..|30|..|..|..|30'},
    {name:'pkt_frameEnd', wave:'0.|40|..|..|..|40|..'},
    {name:'DVB-S2 Ready', wave:'5.|.0|.5|..|..|.0|5.'},
    {name:'FIFO_nFull',   wave:'8.|..|..|0.|8.|..|..'},
    {name:'TREADY',		    wave:'7.|.0|.7|0.|.7|0.|7.'},
    {name:'', 		        node:'A.BC.DE.FG.HI.JK.LM.N', phase:'0.14'},
    
    
    
  ],
  edge: [
    'A+B Begin',
    'C+D FRM In',
    'E+F FRM Done',
    'G+H FIFO Full',
    'I+J FIFO nFull',
    'K+L FRM In',
    'M+N FRM Done',
  ],
  foot: {
    text:[
      'tspan', 
    //['tspan', {dy:'-5'}, 'wdwdwd'],
    //['tspan', {x: '130',dy:'-25',class:'h6'}, 'XFR 1'],
    //['tspan', {x: '170',dy:'0',class:'h6'}, 'XFR 2'],
    //['tspan', {x: '245',dy:'0',class:'h6'}, 'NO XFR'],
    ],
      
      
  }
}
```,
caption: "AXI-Stream TREADY timing. The DVB-S2 transceiver block asserts nextFrame for a single clock. This signal is extended until a packet signalling the end of a frame is received to create DVB-S2 Ready. TREADY is only asserted when both the transceiver block is ready and the FIFO is not full.",
kind:image,
) <AXI-Stream-FIFO-Timing>

The next stage of the input stream handling is the FIFO buffer. Data is pushed onto the FIFO when TREADY and TVALID are asserted, in compliance with an AXI transaction. There are three conditions to be met to pop data off the FIFO. First, TREADY must be asserted, indicating that the transmitter is ready for new data. Second, the packet serialiser block must be ready for a new packet. Third, the FIFO must not be empty. There is a further delay circuit to ensure only one packet is output at a time. The resulting blocks can be seen in @packet-input-circuit, and intended timing in @FIFO-Timing.

#figure(
  image("../Figures/Implementation/Timing Diagrams/FIFO-Serialiser-Circuit.svg"),
  caption:"Annotated Packet Input Circuit"
) <packet-input-circuit>

// FIFO timing
#figure(
```wavy
{
  signal:
  [
    //. -> repeat last
    //p -> pulse
    // 1 / 0 -> signal for whole timestep
    {                 		node:'..AC.I.......K......', phase:'0.14'}, // Start of lines
    {name:'ACLK',     		wave:'p...................'},
    
    //{name:'nFull',  wave:'x.34.5.',data:'1 2 3'},
    ['Stream',
    	{name:'TDATA', 		  wave:'x34xX...............', 'data':'A B'},
    	{name:'TVALID', 	  wave:'0110................'},
    	{name:'TREADY',		  wave:'07.0................'},
    ],
    ['Parse Interface',
    	{name:'FIFO_Pop', 	wave:'0..80......80.......'},
    	{name:'FIFO_Out',   wave:'x...3xxxxxxx4xxxxxxx', 'data':'A B'},
      {name:'FIFO_Valid', wave:'0...10......10......',},
		  {name:'FIFO_nEmpty',wave:'0..8........0.......'},
     	{name:'Parse_Ready',wave:'5....0.....5.0....5.'},
    	{name:'', 		    node:'..BDE.......F', phase:'0.14'},
      {name:'', 		    node:'.....J.......L.', phase:'0.14'},
    ],
    
    
  ],
  edge: [
    'A-|B',
    'C-|D',
    'I-|J',
    'K-|L',
    'E+F	8 Cycles / AXI Packet',
  ],
  foot: {
    text:[
      'tspan', 
    	['tspan', {x: '80', dy:'-60',class:'h6'}, 'XFR A'],
    	['tspan', {x: '120',dy:'0',class:'h6'},   'XFR B'],
      ['tspan', {x: '200',dy:'+30',class:'h6'}, 'XFR A'],
    	['tspan', {x: '520',dy:'0',class:'h6'},   'XFR B'],
    ],
      
      
  }
}
```,
caption: "FIFO stream and parser interfacing timing. The input of the FIFO is used to handle the AXI-Stream, with TVALID driving \"FIFO_Push\". If TREADY and Parse_Ready are asserted, and the FIFO is not empty, then FIFO_Pop is asserted and a packet output on the next clock.",
kind:image,
) <FIFO-Timing>

The serialisation block, Parse Packet, was implemented through MATLAB code wrapped in a function block. It takes two inputs, pktIn and pktValidin, and is configurable via a mask. The ports and parameters are defined in @Parse-Packet-Signals. The block serialises the data as shown in @Parser-Timing.

#figure(
  table(
    columns:3,
    align:(left,center,center),
    table.header(
      [*Name*],[*Type*],[*Purpose*]
    ),
    table.cell(colspan: 3,  align:center, [*Inputs*]),
    [pktIn],      [uint32],   [AXI Packet to be serialised],
    [pktValidIn], [boolean],  [Indicates if packet input is valid],
    
    table.cell(colspan: 3,  align:center, [*Outputs*]),
    [readyOut],    [Boolean], [Indicates that the block is ready for new data],
    
    [pktBitOut],   [boolean], [Output data stream],
    [pktStartOut], [boolean], table.cell(rowspan: 5,  align:center, [Synchronised sideband signal outputs]),
    [pktEndOut],   [boolean], 
    [pktValidOut], [boolean], 
    [frmStartOut], [boolean], 
    [frmEndOut],   [boolean], 

    table.cell(colspan: 3,  align:center, [*Configuration*]),
    [LSB First],[boolean],  [If false, data is output MSB first, if true data, is output LSB first. Should always be 0, as DVB-S2 is MSB first.],
    [Frame End Position],   [unsigned int],table.cell(rowspan: 4,  align:center, [Bit position of signals within AXI packet.]),
    [Frame Start Position], [unsigned int],
    [Packet End Position],  [unsigned int],
    [Packet Start Position],[unsigned int],
    [Payload Position],     [unsigned int],[Bit position of LSB of payload data byte],
  ),
  caption: "Parse Packet Interface"
) <Parse-Packet-Signals>





#figure(
```wavy
{
  signal:
  [
    //. -> repeat last
    //p -> pulse
    // 1 / 0 -> signal for whole timestep
    {                 		node:'.A.E', phase:'-0.1'}, // Start of lines
    {name:'ACLK',     		wave:'p..................'},
    
    //{name:'nFull',      wave:'x.34.5.',data:'1 2 3'},
    ['FIFO - Parser',
     {name:'FIFO_nEmpty',	wave:'01........0........'},
     {name:'Parse_Ready',	wave:'1..0.....1.0.....1.'},
     {name:'FIFO_Pop', 		wave:'010......10........'},
     {name:'FIFO_Out',   	wave:'x.3xxxxxxx4xxxxxxx.', 'data':'A B'},
     {name:'FIFO_Valid', 	wave:'0.10......10.......'},	
     
    	
     	//{name:'', 		    node:'....', phase:'0.14'},
    ],
     ['Parser - DVB-S2 Tx',
      {name:'pktValid',		wave:'0.1...............0'},
      {name:'pktBits',		wave:'x.3333333344444444x','data':'D7 D6 D5 D4 D3 D2 D1 D0 D7 D6 D5 D4 D3 D2 D1 D0'},
      {name:'pktStart',		wave:'x.10..............x'},
      {name:'pktEnd',		  wave:'x.0..............1x'},
      {name:'frmStart',		wave:'x.10..............x'},
      {name:'frmEnd',		  wave:'x.0..............1x'},
      
    ],
      {name:'', 		    node:'.BE...............F', phase:'-0.1'},
    
  ],
  edge: [
    'A-|B',
    'C-|D',
    'E+F	DFL = UPL = 16 bits',
  ],
  foot: {
    text:[
      'tspan', 
    //['tspan', {dy:'-5'}, 'wdwdwd'],
    	//['tspan', {x: '80',dy:'-30',class:'h6'}, 'XFR A'],
    	['tspan', {x: '50',dy:'-25',class:'h6'},  'RDY &amp; nEMPTY'],
    	//['tspan', {x: '245',dy:'0',class:'h6'},  'NO XFR'],
    ],
      
      
  }
}
```,
caption: "Parser timing. When Parse_Ready is asserted and the FIFO is not empty, the FIFO outputs a packet on the next cycle. The Parser processes the packet when FIFO_Valid is asserted, outputting the MSB of the packet data field along with start flags in the same cycle. Over the next six cycles, the packet data field is output sequentially, ending with the LSB and end flags on the 8th cycle. Parse_Ready is reasserted on the 8th cycle, ensuring no gaps between packets.",
kind:image,

) <Parser-Timing>

The next stage of the design handled the interface between the DVB-S2 Transmitter block and the #acr("DAC") interface. 

Both I and Q outputs are in the form of signed 16 bit words, where only the most significant 12 bits are used and the remaining 4 bits ignored. The DVB-S2 Transmitter block outputs signed fixed point 18 bit complex words with 16 fractional bits, which is more precision than required. The block was tested with all modulation constellations and the maximum magnitude of the output signal was found to be less than 1. This indicated that the bit depth could be safely reduced. To ensure that the full 12 bits of accuracy were maintained only the final block was modified, the root-raised-cosine pulse shaping filter.

With the modification, the output data type was signed 12 bit words with 11 fractional bits. These are then scaled and cast to a signed 16 bit word for output to the DAC. The resulting blocks are shown in @DAC-interface. The scaling factor is indicated as En11, meaning $times 2^-11$ and E4 meaning $times 2^4$.

#figure(
  image("../Figures/Implementation/block-diagram/DAC-SCaling.png"),
  caption: "Blocks for scaling of IQ data for transceiver interface"
) <DAC-interface>

// TODO: PAcket Parser operation. Flowchart + walk through + Listing.

= HDL Generation

Once the PL design was ready, HDL code could be generated. The device target was set as "Zedboard and FMCOMMS2/3/4" and the "Receive and transmit path" reference design selected. #footnote([Vivado expected a version of the Zedboard board file that was not present. This required the manual modification of an existing board file before the design could be generated.]) The target interface was configured according to @HDL-Coder-interface. Most signals were automatically assigned to the interface of the reference design, however the control signals required manual assignment. 

The FMCOMMS2 and FMCOMMS3 are based on the AD9361 and AD9363 respectively. These have two channel transmit and recieve, wheras the FMCOMMS4 with its AD9364 only has single channel receive. The controller block is common across all three devices, however in the case of the FMCOMMS4, these extra channel interfaces are nonfunctional. For this reason, there are two Rx channels defined within the block design, with the second channel tied to "0".

All of the interface ports for the design are shown in @HDL-Coder-interface.

#figure(
  table(
    columns:4,
    align:(left,center,center),
    table.header(
      [*Port Name*],[*Port Type*],[*Data Type*],[*Target Platform Interface*]
    ),
    
    table.cell(colspan: 4,  align:center, [*PS-PL Transmit*]),
    [AXI4S_Data_In],    [Input],  [uint32],  [AXI4-Stream Read Slave],
    [AXI4S_Valid_In],   [Input],  [boolean], [AXI4-Stream Read Slave],
    [AXI4S_Tready_Out], [Output], [boolean], [AXI4-Stream Read Slave Ready (optional)],

    table.cell(colspan: 4,  align:center, [*DVB-S2 Control Signals*]),
    [TSorGS_In],     [Input], [ufix2],   [AXI4-Lite],
    [DFL_In],        [Input], [uint16],  [AXI4-Lite],
    [UPL_In],        [Input], [uint16],  [AXI4-Lite],
    [SYNC_In],       [Input], [uint8],   [AXI4-Lite],
    [MODCOD_In],     [Input], [ufix5],   [AXI4-Lite],
    [FECFRAME_In],   [Input], [boolean], [AXI4-Lite],
    
    table.cell(colspan: 4,  align:center, [*Transceiver Transmit*]),
    [Tx_Valid_In],    [Input],  [boolean], [DMA Tx Valid In],
    [Tx1_Data_I_In],  [Input],  [int16],   [DMA Tx I1 In [0:15]],
    [Tx1_Data_Q_In],  [Input],  [int16],   [DMA Tx Q1 In [0:15]],
    [Tx_Valid_Out],   [Output], [boolean], [Baseband Tx Valid Out],
    [Tx1_Data_I_Out], [Output], [int16],   [Baseband Tx I1 Out [0:15]],
    [Tx1_Data_Q_Out], [Output], [int16],   [Baseband Tx Q1 Out [0:15]],
    

    table.cell(colspan: 4,  align:center, [*Transceiver Receive*]),
    [Rx_Valid_In],    [Input],  [boolean], [Baseband Rx Valid In],
    [Rx1_Data_I_In],  [Input],  [int16],   [Baseband Rx I1 In [0:15]],
    [Rx1_Data_Q_In],  [Input],  [int16],   [Baseband Rx Q1 In [0:15]],    
    [Rx_Valid_Out],   [Output], [boolean], [DMA Rx Valid Out],
    [Rx1_Data_I_Out], [Output], [int16],   [DMA Rx I1 Out [0:15]],
    [Rx1_Data_Q_Out], [Output], [int16],   [DMA Rx Q1 Out [0:15]],
    [Rx2_Data_I_Out], [Output], [int16],   [DMA Rx I2 Out [0:15]],
    [Rx2_Data_Q_Out], [Output], [int16],   [DMA Rx Q2 Out [0:15]],
    table.cell(colspan: 4,  align:center, [*PL-PS Receive*]),
    [AXI4S_Tready_In],  [Input],  [boolean], [AXI4-Stream Write Master],
    [AXI4S_Data_Out],   [Output], [uint32],  [AXI4-Stream Write Master],
    [AXI4S_Valid_Out],  [Output], [boolean], [AXI4-Stream Write Master Valid],
  )
) <HDL-Coder-interface>

= Packet Handling

== PS-PL Interface
HDL Coder generated the software interface shown in @PS-PL-Interface, however due to time constraints, this was not tested.

#figure(
  image("../Figures/Implementation/block-diagram/software-interface.png"),
  caption: "Generated software interface. Packets are transmitted by sending data into the \"data\" port of the AD936x Transmitter block. This block can also be used to configure the radio, including center frequency."
) <PS-PL-Interface>


== Test Data Generation
To verify the proper functioning of the transceiver, synthetic packet data was required. Additionally, all sideband signals and control signals would need to be generated appropriately to ensure all inputs were valid.

The test data encoded DVB-S2 frame and packet, as well as AXI packet, counters into the data field to ease debugging of the resulting waveforms. Only 8 bits were available, so these were assigned accordingly: A single frame may contain hundreds of small packets and thousands of AXI packets. These counters would rollover and were zero indexed. The resulting packet structure is shown in @test-packet-struct, and the flow for generation in @gendata-struct.

#figure(
  image("../Figures/Implementation/Packets/Synth-AXI-Packet.svg"),
  caption: "Test Packet Structure "
) <test-packet-struct>


#subpar.grid(
  columns: (1fr),
  caption: [Data generation function structure. (a) Shows the inputs and outputs of  the function, where both the AXI packet stream and control signals have the same size. (b) Shows the functionality of the gendata function. ],
  label: <gendata-struct>,
  figure(
    image("../Figures/Implementation/Packets/Gendata-Highlevel.svg"),
    caption: "High Level Flow"
  ),<gendata-high>,
  figure(
    image("../Figures/Implementation/Packets/Gendata-Lowlevel.svg"),
    caption: "Low Level Flow"
  ), <gendata-low>,
)

Another function called parse_axipkt was developed to verify that gendata was generating data as expected. This used bit shift operations to parse the generated 32 bit data word into a formatted struct.

== GSE

// TODO: gendata()
// TODO: serialisation + GSE
// TODO: Pocket???

// TODO: reference cereal
Initial work on the GSE implementation has been completed. Various libraries for serialisation were investigated, with the cereal library being considered, as it supports the creation of binary archive files with embedded flags to make them portable across computer architectures. Ultimately, the conclusion was reached that serialisation will have to be implemented manually, as the libraries found increased overheads to improve compatibility. For this application, the exact packet structures are known as a schema will be created ahead of time.

@GSE-Packet-Class shows the class definition for a GSE Packet. The fixed header specifies the bit alignmment of the members in order to byte align it properly. std::optional was chosen to handle the missing members of the variable header. The serialise function shall return a byte array that can be passed to the PS-PL interface.

#figure(sourcecode[```C++
class GSE_Packet {
public:
    struct FixedHeader {
        bool start    : 1;
        bool end      : 1;
        int labelType : 2;
        int GSElength : 12;
        };
    struct VariableHeader {
        std::optional<char>     fragID;
        std::optional<uint16_t> totalLength;
        std::optional<uint16_t> protocolType;
        std::optional<char[3]>  label;
    };
private:
    FixedHeader fh;
    std::optional<VariableHeader> vh;
    Packet* pdu;

public:
    // constructor
    GSE_Packet(FixedHeader fh, VariableHeader vh, Packet* pdu);
    std::vector<uint8_t> serialise();
};
```], 
caption: [GSE_Packet Class Definition]) <GSE-Packet-Class>

During the investigation of packet structure, it decided that all packets shall include both a type and version field. The type field shall occur first such that buffers can be allocated appropriately, and the version field included to ensure that packet structure can be updated without breaking backwards compatibility. For the final system, these fields could be reduced in size, as it is not expected for the packet definitions to change during the mission however they should not be omitted in order to allow this possibility. @Packet-Class shows a possible implementation of a packet class, with the cereal library used for serialisation.

#figure(sourcecode[```C++
class Packet {
    uint8_t type;
    uint8_t version;
    timestamp time;
    virtual cereal::PortableBinaryOutputArchive serialise();
};
```], 
caption: [Packet Interface Definition]) <Packet-Class>

@fragment-function shows a possible function definition for fragmentation. 

#figure(sourcecode[```C++
std::vector<GSE_Packet> fragment(Packet* pdu);
```], 
caption: [Packet Fragmentation Function Structure]) <fragment-function>

An example primary payload packet is shown in @PPL-Packet-Definition. It inherits the members from Packet and creates a definition for serialise().

#figure(sourcecode[```C++
struct PPL_pkt_64k : Packet{
    double standard_deviation;  // Standard deviation of data
    double codebook[16];        // Quantization levels
    uint32_t data[2048];        // compressed PPL data

    cereal::PortableBinaryOutputArchive serialise();
};
```], 
caption: [Primary Payload Packet Definition]) <PPL-Packet-Definition>

