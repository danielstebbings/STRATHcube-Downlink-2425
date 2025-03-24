#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"

#set heading(offset: 1)
// CCSDS Standards
// DVB-S2 Standard
// - GSE
// - ACM & VCM
// - CCM
// Interference
// - Cubesat paper
// - DVB-S2 interference cancellation
// STRATHcube
// - Niamh dissertation
// - Preben's Link budget


= STRATHcube
Sporadic work has been completed for the downlink communications system in the previous years of the project. 
// TODO: Add masters project reference 2020-2021
// TODO: ITU
In TODO: a tradeoff study was conducted of the communications system. It identified the 
UHF amateur allocation in 435 - 438 MHz as suitable for uplink and downlink. A 
preliminary link budget was conducted using information about the STAC ground station 
and a radio module was selected. 

// TODO: Gaus reference
The first radio selected was the GAUS Low Power UHF Radio which can use various frequency shift keying modes and convolutional codes for error correction. This has a stated max capacity of 250kbps, but 
per the datasheet this rating is not currently supported leaving the actual maximum rate of 100kbps. Additionally, the datasheet also states that Reed Solomon coding is supported, whilst also 
stating that it is not _currently_ supported in a footnote. Additionally, the coding rates for which 
the datarate values are calculated are not available.

//TODO: TOTEM Reference
//TODO: 2324 masters reference
//TODO: Alen 
In TODO: another tradeoff study was conducted for the primary payload system, ultimately selecting 
the TOTEM SDR from Alen Space. Alen Space also manufacture a UHF #acr("FE") compatible with the 
TOTEM SDR, for this reason it was decided to consolidate both the primary telecommunications and 
primary payload onto the TOTEM SDR in order to reduce component count and project cost. The full 
specification and operation of the TOTEM SDR is defined in @TOTEM_SDR.

//TODO: ISIS Antenna ref
UHF communications will be transmitted using the ISIS deployable antenna system configured 
with a single deployable dipole antenna. The exact specifications are selectable by the user, being 
rated for 10 MHz of usable bandwidth at design frequency and a VSWR < 1.9:1.

= TOTEM SDR <TOTEM_SDR>
//TODO: Zynq product selection guide
The TOTEM SDR consists of an AMD Zynq 7020 #acr("SoC") #acr("FPGA") connected to an AD9364 RF Transceiver via #acr("LVDS"), as shown in @TOTEM-Block. Compatible frontend modules can be mounted on the motherboard using the connector in the center of the board, which can be seen in @TOTEM-Motherboard.

// TODO: TOTEM Reference
#subpar.grid(
  figure(
    image("../Figures/Lit-Review/TOTEM-Motherboard.png",width:90%),
    caption:"Motherboard"
  ), <TOTEM-Motherboard>,
  figure(
    image("../Figures/Lit-Review/TOTEM-Block.png",width:80%),
    caption:"Block Diagram"
  ), <TOTEM-Block>,
  columns: (1fr,1fr),
  caption: [TOTEM SDR],
  label: <TOTEM>
)

// TODO: Finish
The Zynq 7020 has dual ARM Cortex-A9
processor cores that form the #acr("PS") and #acr("FPGA") fabric that forms the #acr("PL"). 
This allows improved performance, as serial operations such as network interfacing can be accomplished on the #acr("PS") and highly parallel operations such as signal processing can be accomplished on the #acr("PL"). The Zynq 

//TODO: AD9364 
The AD9364 is a high performance RF transceiver with separate ports for receive and transmit. It can operate from 70 MHz to 6 GHz and has a bandwidth of up to 56 MHz with a 12 bit #acr("ADC") and #acr("DAC"). A #acr("SPI") bus is used for control signals and a high speed #acr("LVDS") interface for #acr("IQ") data. This device is part of the larger family of AD936x transceivers form Analog Devices. The chips in this family differ in port count, bandwidth, and operating frequency, however the control interfaces are very similar across devices. For this reason, many software drivers and FPGA IPs work with multiple devices in the family.

// TODO: Cite ad9364 datasheet
#figure(
  image("../Figures/Lit-Review/TOTEM-AD9364-BD.png",width:50%),
  caption: "AD9364 Functional Block Diagram"
)

The frontend module is called FrontendUHF, and includes a transmit / receive switch, bandpass filtering and amplification for both transmit and recieve. It has a frequency range of 430 to 440 MHz and a typical power output of 30dBm. @TOTEM-frontendUHF depicts the module and a block diagram of its operation. 

#subpar.grid(
  columns: (1fr,1fr),
  caption: [FrontendUHF],
  label: <TOTEM-frontendUHF>,
  figure(
    image("../Figures/Lit-Review/TOTEM-FrontendUHF.png"),
    caption: "FrontendUHF module"
  ),
  figure(
    image("../Figures/Lit-Review/TOTEM-FrontendUHF-BD.png"),
    caption: "FrontendUHF Block Diagram"
  )
)

//todo: reference FMCOMMS
As the TOTEM SDR could not be purchased in time for the project, implementation was targeted towards development boards. The Digilent Zedboard is a Zynq 7020 development board with much less external RAM than the TOTEM, however it has the same FPGA resources. The Zedboard also includes an FPC connector, allowing the connection of high speed peripherals. This can be used to connect an FMCOMMS development board from Analog Devices, one of which is available for the AD9364 used in the TOTEM. As the control interfaces are the same, another FMCOMMS board from the AD936x family can be used for functional testing.

//TODO: FMCOMMS4 reference
//TODO: Zedboard reference digilent website
#subpar.grid(
  columns: (1fr,1fr),
  caption: [Development Boards],
  label: <Dev-boards>,
  figure(
    image("../Figures/Lit-Review/Dev-FMCOMMS4.png"),
    caption: "FMCOMMS4"
  ),<FMCOMMS4>,
  figure(
    image("../Figures/Lit-Review/Dev-zedboard.png"),
    caption: "Zedboard"
  ), <Zedboard>,
)

= STAC Ground Station
// TODO: STAC GS reference
The #acr("STAC") ground station was first created in 2008 and resides on the roof 
of the James Weir building at the University of Strathlycde. After a fire in the 
building, the project was abandoned in 2012. In 2015/2016, a master's group 
renovated the #acr("STAC") and were successful in receiving telemetry from the 
Strand-1 CubeSat. The station has since been out of use and has not been maintained,
as such, the current status of the components is unknown.
#figure(
  image("../Figures/Lit-Review/STAC.png",width: 50%),
  caption: "STAC After 2016 Renovation "
)

// TODO: Antenna reference
The #acr("STAC") has dual #acr("VHF") and #acr("UHF") antennas and includes pre-amplifiers suitable for both receive and transmit. The UHF antennas are the 
436CP30 from M2 Antenna Systems and the UHF pre-amplifier is the SP-7000 from SSB.
The details of which are shown in @SP7000 and @436CP0 respectively.

#figure(
  table(
    columns:2,
    align:(left, center),
    [*Frequency Range*],[430-440 MHz],
    [*Noise Figure*],   [0.9 dB],
    [*Maximum Gain*],   [20 dB],
  ),
  caption:"SP7000 Specification"
)
 <SP7000>

#figure(
  table(
    columns:2,
    align:(left, center),
    [*Frequency Range*],[432-440 MHz],
    [*Gain*],           [15.50 dBic],
    [*Beamwidth*],      [30 #sym.degree],
    [*Max VSWR*],       [1.6:1]
  ),
  caption: "436CP0 Antenna Specification"
) <436CP0>


= Standards
== DVB-S2
//TODO: Finish
#acr("DVB-S2") is a system designed for the transmission of data at high rates from satellite. It was standardised by the #acr("ETSI"). The standard is designed to be modular in order to improve flexibility, with structures suitable for video broadcasting and IP data transmission codified in the standard. The full block diagram can be seen in @dvb-s2-stand-bd. The key advantage of #acr("DVB-S2") for communications is its robust #acr("ACM") features.

// TODO: DVB-S2 Standard Citation
#figure(
  image("../Figures/Lit-Review/DVB-S2/DVB-S2_Full.png"),
  caption: "DVB-S2 Block Diagram"
) <dvb-s2-stand-bd>

// ACM
#acr("ACM") is the process of changing modulation and coding settings to meet channel conditions in real time. Similar in concept is #acr("VCM"), where the settings are precomputed. #acr("ACM") utilises a return path, data transmitted from the ground station to indicate received signal quality, in order to provide closed loop control. This has the key advantage of being able to adapt to transient channel effects, such as the presence of interference.

//FEC
#acr("DVB-S2") utilises

// TODO: Shannon citation


// DVB-S2X

// GSE

== CCSDS
= Interference