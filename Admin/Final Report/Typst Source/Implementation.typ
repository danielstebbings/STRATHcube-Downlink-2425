#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"

#set heading(offset: 1)


= Transmitter

== Tool Selection
There were multiple options for implementation of the #acr("DVB-S2") subsytem. 

#figure(
  table(
    columns:3,
    align:(left,center,center,center,),
    table.header(
      [*Method*],[*Advantage*],[*Disadvantage*]
    ),
    [GNU Radio software implementation],  [Simplicity of implementation],   [Processing speed],
    [COTS IP Core],                       [Reliability],   [Expensive],
    [Vitis Model Composer],               [Simplicity of implementation],   [],
    [MATLAB HDL Coder],                   [Specific Support from Analog Devices], [Resource efficiency],   
  ),
  caption:"Implementation Tool Tradeoff"
)
+ 
+ Scratch implementation in #acr("RTL") code.
// TODO: DO i need to expand IP here?
+ Use of off-the-shelf DVB-S2 IP core
+ MATLAB HDL Coder
+ Vitis Model Composer or System Generator

== DVB-S2 Modulation
//TODO: DVB-S2 HDL Coder citation
The core of the design is built upon a DVB-S2 HDL coder example created by Mathworks.

#pagebreak()
#figure(
  rotate(image("../Figures/Implementation/MATLAB-Examples/DVB-S2-Tx.png")),
  caption:"DVB-S2 HDL Transmitter MATLAB Example Design"
)
#pagebreak()

#figure(
  table(
    columns:3,
    align:(left,center,center),
    table.header(
      [*Port*],[*Type*],[*Purpose*]
    ),
    
    [pktBitsIn],    [Boolean Stream], [],
    [pktStartIn],   [Boolean],        [],
    [pktEndIn],     [Boolean],        [],
    [pktValidIn],   [Boolean],        [],
    [frameStartIn], [Boolean],        [],
    [frameEndIn],   [Boolean],        [],
    [TSorGS],       [ufix2],          [],
    [DFL],          [uint16],         [],
    [UPL],          [uint16],         [],
    [SYNC],         [uint8],          [],
    [pMODCOD],      [ufix5],          [],
    [pFECFRAME],    [boolean],        [],
    


  ),
  caption: "AXI-Stream Minimal Signals"
)
// TODO: rolloff investigation



== Transceiver Integration
//TODO: HW/SW
This then needed to interface with the rest of the system. It was decided to use the HW/SW Codesign features of HDL Coder to generate IIO bindings for the software to hook into. Support for Zedboard and FMCOMMS is provided by a support package. A MATLAB Example provided the interface that was then used to implement the final design.

#figure(
  image("../Figures/Implementation/MATLAB-Examples/HWSWCodesign.png"),
  caption: "HW/SW Codesign Chirp Example"
)

The provided example supports both the transmit and receive paths for the AD936x transceiver. This offers the possibility of implementing both the PBR processing and downlink communications using the same block design.

Data is transferred from the #acr("PS") via one of two methods. AXI-lite interfaces are used for control signals, as they have lower throughput, this was used for all control signals, such as #acf("DFL"), #acr("UPL"), etc. An AXI-Stream was used to transfer packet data, as it has a much higher throughput.

#figure(
  table(
    columns:3,
    align:(left,center,center),
    table.header(
      [*Signal*],[*Type*],[*Purpose*]
    ),
    [TData],  [uint32],  [Data to be transferred from master to slave],
    [TValid], [boolean], [Indication from master to slave that data is valid and can be read],
    [TReady], [boolean], [Indication from slave to master that it is ready for new data],
    [TLast],  [boolean], [Indication from master to slave that the current packet is the last in the current stream],

  ),
  caption: "Minimum AXI-Stream Signals"
)

#import "@preview/wavy:0.1.1"


#show raw.where(lang: "wavy"): it => wavy.render(it.text)


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


The DVB-S2 design used requires sideband signals to indicate the start and end of a frame or packet. Additionally, as the 

Unlike the other control signals, these require a high level of synchronisation with the data stream, necessitating their inclusion within the 32 bit TData. 

The remaining 28 bits could then be used to carry the packet data. No DFL size was evenly divisible by 28, giving two avenues for implementation. The first option was to implement a signalling system within the TDATA field allowing for a variable amount of packet bits within each TDATA field. The second was to find the largest number that factored all possible DFL sizes and accept the lower performance.

//TODO: Fastest 
All DFL sizes were factorised, giving a maximum size of 8 bits. AXI-Streams can transfer data much faster than the resultant symbols could be transmitted, so it was decided to accept the performance loss of using a subset of the TDATA field as it greatly reduced complexity.

#figure(
  table(
    columns:2,
    align:(left,center),
    [*Normal FECFRAME*],[15928, 21328, 25648, 32128, 38608, 42960, 48328, 51568, 53760, 57392, 58112],
    [*Short FECFRAME*], [2992,  5152,  6232,  6952,  9472, 10552, 11632, 12352, 13072, 14152],

  ),
  caption: "Possible DFL Sizes (bits)"
)

#subpar.grid(
  columns: (1fr),
  caption: [Design TDATA structure. TDATA is 32 bits wide here, ],
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

The AXI packets contain the start and end signals, as well as a byte of packet data in a parallel format. This must be serialised into a bitstream to interface with the #acr("DVB-S2") transmitter block. This in turn means that buffering is required. A #acr("FIFO") buffer was selected for this purpose, as the interface signals can be used to manage the AXI interface.

//TODO: FIFO diagram

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
caption: "AXI-Stream TReady timing. The DVB-S2 transceiver block asserts nextFrame for a single clock. This signal is extended until a packet signalling the end of a frame is received to create DVB-S2 Ready.",
kind:image,
) <AXI-Stream-Timing>


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
    	{name:'FIFO_Out',   wave:'0...3xxxxxxx4xxxxxxx', 'data':'A B'},
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
caption: "FIFO stream and parser interfacing timing. The input of the FIFO is used to handle the AXI-Stream, with TVALID driving \"FIFO_Push\". If Parse_Ready is asserted and the FIFO is not empty then FIFO_Pop is asserted and a packet output on the next clock.",
kind:image,
) <FIFO-Timing>

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
caption: "Parser timing. When Parse_Ready is asserted and the FIFO is not empty, the FIFO outputs a packet. The Parser processes the packet when FIFO_Valid is asserted, outputting the MSB of the packet data field along with start flags in the same cycle. Over the next six cycles, the packet data field is output sequentially, ending with the LSB and end flags on the 8th cycle. Parse_Ready is reasserted on the 8th cycle, ensuring no gaps between packets.",
kind:image,

) <Parser-Timing>

// TODO: TReady generation

// TODO: DAC conversion
// RRC changed to output sfix12 from sfix18

= Packet Handling

== Test Data Generation
To verify the proper functioning of the transceiver, synthetic packet data was required. Additionally, all sideband signals and control signals would need to be generated appropriately to ensure all inputs were valid.

#subpar.grid(
  columns: (1fr),
  caption: [Data Generation Function Structure],
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


== GSE

// TODO: gendata()
// TODO: serialisation + GSE
// TODO: Pocket???