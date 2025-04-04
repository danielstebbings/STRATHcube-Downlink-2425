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

// TODO: ITU
In @lewis_creed_strathcube_2021 a tradeoff study was conducted of the communications system. It identified the 
UHF amateur allocation in 435 - 438 MHz as suitable for uplink and downlink. A 
preliminary link budget was conducted using information about the #acr("STAC") ground station 
and a radio module was selected. 

The first radio selected was the GAUSS Low Power UHF Radio  which can use various frequency shift keying modes and convolutional codes for error correction. This has a stated max capacity of 250kbps, but 
per the datasheet this rating is not currently supported leaving the actual maximum rate of 100kbps. Additionally, the datasheet also states that Reed Solomon coding is supported, whilst also 
stating that it is not _currently_ supported in a footnote. Additionally, the coding rates for which 
the datarate values are calculated are not available. @gauss_srl_gauss_2018

In @pablo_alvarez-icaza_advancing_2024 another tradeoff study was conducted for the primary payload system, ultimately selecting 
the TOTEM SDR from Alén Space. @alen_space_totem_2024 Alén Space also manufacture a UHF #acr("FE") compatible with the 
TOTEM SDR, @alen_space_frontenduhf_2021 for this reason it was decided to consolidate both the primary telecommunications and 
primary payload onto the TOTEM SDR in order to reduce component count and project cost. The full 
specification and operation of the TOTEM SDR is defined in @TOTEM_SDR.

UHF communications will be transmitted using the ISIS deployable antenna system @isispace_cubesat_nodate configured 
with a single deployable dipole antenna. The exact specifications are selectable by the user, being 
rated for 10 MHz of usable bandwidth at design frequency and a VSWR < 1.9:1.

A member of the team completed a research internship analysing the downlink in summer 2024. @preben_rasamanickam_strathcube_2024 This analysis compared multiple types of modulation and #acr("FEC"), ultimately recommending #acr("DVB-S2") for the final system. It also analysed the maximum bandwidth for the link to close, i.e. to have a positive link margin, arriving at a figure of 158.5 kHz. The resulting link budget is shown in @Preben-2024-Link-Budget. With the ground station undefined, many of the performance figures were based on the link budget created by AcubeSAT, @amarantidou_acubesat_2020 an open source satellite mission. The final link margin number is effectively the #acr("CNR") above the margin requirement, so the actual margin would be 12 dB.
/*
#subpar.grid(
  columns: (1fr, 1fr),
  caption: [Summer 2024 Analysis Results],
  label: <Preben-Analysis>,
  figure(
    image("../Figures/Lit-Review/Preben/Preben-BitratevBWvMODCOD.svg"),
    caption: "Bitrate Analysis"
  ), <Preben-Bitrate>,
  figure(
    image("../Figures/Lit-Review/Preben/Preben-MarginvDatarate.svg"),
    caption: "Link Margin Analysis"
  ), <Preben-Margin>,
)
*/

//TODO: Explain these numbers
#figure(
  table(
    columns: 3,
    table.cell(colspan: 3, align(center,strong("Spacecraft"))),
    [Transmit Power],                     [1.76],   [dBW],
    [Transmitter Gain],                   [0],      [dBi],
    [Transmitter Line Losses],            [-1.93],  [dB],
    [Transmitter Antenna Pointing Loss],  [-3],     [dB],
    [#acr("EIRP")],                               [-3.17],  [dBW],

    table.cell(colspan: 3, align(center,strong("Link"))),
    [Frequency],                                    [435],      [MHz],
    [Bandwidth (Max Achievable)],                   [158.5],    [kHz],
    [Path Length (409 km Altitude, 15° Elevation)], [1196.622], [km],
    [Free Space Path Loss],                         [-146.777], [dB],
    [Other Losses (Atmospheric, Polarisation, …)],  [-4.6],     [dB],

    table.cell(colspan: 3, align(center,strong("Ground Station"))),
    [Received Incident Power],                                [-154.61], [dBW],
    [Receiver Gain],                      [12],      [dB],
    [Receiver Line Losses],               [-2.4],    [dB],
    [Receiver System Noise Temperature],  [249.3],   [K],
    [Receiver Sensitivity],               [-11.97],  [dB-K],
    [Implementation Loss],                [-2],      [dB],
    [Received CN0R],                      [62.03],   [dB],
    [Received CNR],                       [12.025],  [dB],
    [Required CNR],                       [-10],     [dB],
    [Link Margin],                        [2.025],   [dB],   
  ),
  caption:"Summer 2024 Link Budget"
) <Preben-2024-Link-Budget>

The ISIS space antenna VSWR and @Preben-2024-Link-Budget contributed to the link analysis in @ACM-Analysis-Section.

= TOTEM SDR <TOTEM_SDR>
The TOTEM SDR consists of an AMD Zynq 7020 #acr("SoC") #acr("FPGA") connected to an AD9364 RF Transceiver via #acr("LVDS"), as shown in @TOTEM-Block. @alen_space_totem_2024 Compatible frontend modules can be mounted on the motherboard using the connector in the center of the board, which can be seen in @TOTEM-Motherboard.

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

The AD9364 is a high performance #acr("RF") transceiver with separate ports for receive and transmit. It can operate from 70 MHz to 6 GHz and has a bandwidth of up to 56 MHz with a 12 bit #acr("ADC") and #acr("DAC"). A #acr("SPI") bus is used for control signals and a high speed #acr("LVDS") interface for #acr("IQ") data. This device is part of the larger family of AD936x transceivers form Analog Devices. The chips in this family differ in port count, bandwidth, and operating frequency, however the control interfaces are very similar across devices. For this reason, many software drivers and FPGA #acr("IP") blocks work with multiple devices in the family. @analog_devices_ad9364_2014

The frontend module is called FrontendUHF, and includes a transmit / receive switch, bandpass filtering and amplification for both transmit and recieve. It has a frequency range of 430 to 440 MHz and a typical power output of 30dBm. @TOTEM-frontendUHF depicts the module and a block diagram of its operation. @alen_space_frontenduhf_2021

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

As the TOTEM SDR could not be purchased in time for the project, implementation was targeted towards development boards. The Digilent Zedboard is a Zynq 7020 development board with much less external #acr("RAM") than the TOTEM, however it has the same FPGA resources. The Zedboard also includes a #acr("FMC")connector, allowing the connection of high speed peripherals. @noauthor_zedboard_nodate This can be used to connect an FMCOMMS development board from Analog Devices, one of which is available for the AD9364 used in the TOTEM. As the control interfaces are the same, another FMCOMMS board from the AD936x family can be used for functional testing without changing the design. @noauthor_ad-fmcomms4-ebz_nodate @noauthor_ad-fmcomms1-ebz_nodate

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

The interface of the TOTEM UHF described here contributed to the system design in @System-Design-Section, and the selected development boards used as the target for implementation in @Implementation-Section.

= STAC Ground Station
The decision for which ground station will be used for communications has not been finalised, however one of the most likely options is the #acr("STAC") ground station. It was first created in 2008 and resides on the roof 
of the James Weir building at the University of Strathlycde. After a fire in the 
building, the project was abandoned in 2012. In 2015/2016, a master's group 
renovated the #acr("STAC") and were successful in receiving telemetry from the 
Strand-1 CubeSat. @calum_clarke_strathclyde_2016 The station has since been out of use and has not been maintained,
as such, the current status of the components is unknown.
#figure(
  image("../Figures/Lit-Review/STAC.png",width: 50%),
  caption: "STAC After 2016 Renovation "
)

The #acr("STAC") has dual #acr("VHF") and #acr("UHF") antennas and includes pre-amplifiers suitable for both receive and transmit. The UHF antennas are the 
436CP30 from M2 Antenna Systems and the UHF pre-amplifier is the SP-7000 from SSB.
The details of which are shown in @SP7000 and @436CP0 respectively. @ssb_sp-7000_2012 @m2_antenna_systems_inc_436cp30_2017.

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

As part of the 2015/2016 renovation, a link budget was created for reception of communications from the Strand-1 satellite. @STAC-UHF-Link-Budget shows the original numbers, with the "Unit" column subsequently added for context. @calum_clarke_strathclyde_2016

#figure(
  table(
    columns:4,
    align:(left,center,center,center,),//center),
    table.header(
      [*Parameter*],[*20 Degrees*],[*90 Degrees*],[*Unit*],//[*Source / \ Condition*]
    ),
    [*Frequency*],                      [4.40E+08],     [4.40E+08],   [Hz], //[Strand-1],
    [*Speed*],                          [3.00E+08],     [3.00E+08],   [m/s],//[Speed of Light],
    [*Wavelength*],                     [2.06],         [2.06],       [m],  //[Strand-1],
    [*Transmitted Power*],              [0.5],          [0.5],        [W],  //[],
    [*Transmitter Gain*],               [1],            [1],          [dB], //[],
    [*Line Loss*],                      [-3],           [-3],         [dB], //[],
    [*EIRP*],                           [-1.5],         [-1.5],       [dBW],//[],
    [*Path Length*],                    [3253000],      [811000],     [m],  //[],
    [*Space Loss*],                     [-136.5],       [-123.5],     [dB], //[],
    [*Antenna Pointing Loss*],          [-0.7],         [-0.7],       [dB], //[],
    [*Polarization Loss*],              [-0.3],         [-0.3],       [dB], //[],
    [*Receiver Gain*],                  [10.2],         [10.2],       [dB], //[],
    [*System Noise Temperature*],       [19.03089987],  [19.03089987],[K],  //[],
    [*Data Rate*],                      [9600],         [9600],       [bps],//[],
    [*Boltzmann's Constant*],           [228.6],        [228.6],      [dB], //[],
    [*Bit Energy to Noise Ratio*],      [16.88],        [28.95],      [dB], //[],
    [*Miscellaneous*],                  [-25],          [-25],        [dB], //[],
    [*Required Energy to Noise Ratio*], [10],           [10],         [dB], //[],
    [*Margin*],                         [6.88],         [18.95],      [dB], //[]
  ),
  caption:"STAC Strand-1 UHF Downlink Link Budget"
) <STAC-UHF-Link-Budget>

The link budget here was used to update the link budget described in @preben_rasamanickam_strathcube_2024, contributing to the analysis in @ACM-Analysis-Section.

= Standards
== DVB-S2 Overview
//TODO: Finish
The input to a DVB-S2 system is one or more datastreams. These can be transport streams, for transmission of video, or generic streams which are either packetised or continuous. A packetised stream has a constant packet size termed the  #acr("UPL"). Variable packet sizes are sent via a continuous generic stream. These are depicted in @dvb-s2-stream-types.

#figure(
  image("../Figures/Lit-Review/DVB-S2/DVB-S2-Streams.svg"),
  caption:"DVB-S2 Input Stream Types."
) <dvb-s2-stream-types>

The input streams are sliced and merged to create a #acr("BBFRAME"). The Structure of which is shown in @BBFRAME. A #acr("BBHEADER") is also applied, which contains various signalling fields providing information about the transmitted frame. The structure is shown in @BBHEADER. Contained within the #acr("MATYPE") field is the #acr("MODCOD") field, which indicates the settings being used on the frame.

#figure(
  image("../Figures/Lit-Review/DVB-S2/DVB-S2-Sliciing.png"),
  caption: "DVB-S2 BBHEADER Structure"
) <BBHEADER>

//FEC
#acr("DVB-S2") utilises two stages of #acr("FEC"), the first code is #acr("BCH") followed by #acr("LDPC"). This combination results in extremely strong error correction performance, allowing near Shannon limit performance. @eroz_dvb-s2_2004 The output of the #acr("FEC") subsystem is a #acr("FECFRAME"). This can either be short, 16200 bits, or normal, 64800 bits. This is shown in @FECFRAME. The information content of the #acr("FECFRAME") is determined by the coding rate, which can be from 1/4 to 9/10.

The FECFRAME is then mapped to symbols and modulated to become a #acr("PLFRAME"). Pilots can optionally be inserted here to aid in decoding. Dummy frames are PLFRAMEs that carry no information. DVB-S2 used #acr("APSK") modulation, configurable between QPSK to 8PSK, 16PSK and 32PSK.

The final block in the system is a root-raised-cosine filter for pulse shaping. This can have a roll-off factor of 0.35, 0.25 or 0.20. The value of which is indicated in the #acr("MATYPE") field.

//GSE
Mapping a packet into a dynamically changing frame is difficult. The #acr("GSE") protocol introduces an intermediate layer to handle fragmentation of network packets, referred to as #acr("PDU")s, into one or more #acr("GSE") packets. @etsi_ts_2014 The operation of the protocol is discussed further in @fragmentation-section.

// DVB-S2X
ETSI released an extension to the original DVB-S2 standard called DVB-S2X, this included several features to improve efficiency for high throughput satellites, such as bonding multiple transponders, beam hopping, and high order modulations up to 256APSK. Particularly relevant, are the new features for #acr("VL-SNR"), which include new #acr("PLFRAME") structures, #acr("BPSK") modulation, and lower coding rates down to 1/5. Features were also added to improve the efficiency of #acr("GSE") packet transmission. 

// TODO: Write paragraph about this
#subpar.grid(
  columns: (1fr),
  caption: [DVB-S2 Frame Structures. (a) Shows a BBFRAME, where $K_"BCH"$ is the input data size to the #acr("FEC") system. (b) Shows a FECFRAME before scrambling. (c) Shows a PLFRAME, where the header is transmitted using $pi/2$ BPSK modulation and data transmitted in groups of 16 slots, followed by an optional 36 symbol pilot block.],
  label: <DVB-S2-Frame-Structure>,
  figure(
    image("../Figures/Lit-Review/DVB-S2/BBFRAME.svg"),
    caption: ""
  ), <BBFRAME>,
  figure(
    image("../Figures/Lit-Review/DVB-S2/FECFRAME.svg"),
    caption: ""
  ), <FECFRAME>,
  figure(
    image("../Figures/Lit-Review/DVB-S2/PLFRAME.svg"),
    caption: ""
  ), <PLFRAME>,
  
)

In @grayver_software_2015, an SDR-based communication system operating in the 915 MHz UHF band and utilizing ACM is described. The system employed modulation techniques similar to DVB-S2 but implemented a different coding scheme. Their analysis demonstrated nearly double the throughput compared to CCM, confirming the feasibility and significant performance advantages of ACM systems for CubeSats.

= Interference <Inteference-Section>

Interference is particularly prevalent in the UHF amateur band. In @quintana-diaz_detection_2022 interference power in the UHF amateur space allocation was measured using the Serpens satellite. Sustained interference power of over -70dBm was measured, with particularly high levels measured over Europe, as shown in @interference-heatmap and @interference-pass. This issue is more relevant for uplink communications, as ground stations can use highly directional antennas to reduce the impact of terrestrial interference, however during low elevation passes this will impact the downlink communications as well.

#subpar.grid(
  columns: (1fr),
  caption: [Interference Analysis],
  label: <Interference-Analysis>,
  figure(
    image("../Figures/Lit-Review/Interference/interference-heatmap.png",height:25%),
    caption: "Interference power heatmap."
  ), <interference-heatmap>,
  figure(
    image("../Figures/Lit-Review/Interference/UK-Pass.png",height:40%),
    caption: "Interference power over time during a pass over Europe."
  ), <interference-pass>
)

To reduce the impact of this interference, advanced filtering could be used. In @same_effects_2020 the effect of narrowband continuous wave interference was investigated for DVB-S2 QPSK communications and an adaptive notch filter designed. 
@Interference-Filter-Results @same_effects_2020[Fig. 27] shows the effect on #acr("BER") of a Jamming to Signal Ratio (JSR) of just -6dB. Without filtering, and at low Eb/N0 values, 
the recovery is significantly degraded however the filter is able to improve performance to close to that of the theoretical peak.
The paper also notes that the filter could reduce performance in certain scenarios.

#figure(
  image("../Figures/Link-Budget/DVB-S2_Interference.png",width:50%),
  caption: "Impact of interference on DVB-S2 QPSK signal reception."
) <Interference-Filter-Results>

The issue of interference was identified as a gap in the analysis described in @ACM-Analysis-Section, and will form the basis of future analysis of the communications system. It will be particularly important during the design of the uplink communications system.