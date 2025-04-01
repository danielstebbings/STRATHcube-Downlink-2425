#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"
#set heading(offset: 1)

= Systems Engineering
// TODO: Development of requirements
// TODO: Review of existing requirements
// 

In order to work effectively in a large project structure, a review of system requirements was conducted with close collaboration with system engineers on the team.

This contributed to a complete overhaul of all #acr("TT&C") requirements to be more relevant to actual operations, for submission as part of the ESA Baseline Design Review. The relevant requirements are shown in @System-Requirements.

#figure(
  table(
    columns: 2,
    inset: 6pt,
    align: (horizon,left), 
    table.header(
      [*Code*],[*Description*],
    ),
    // System
    [SYS-082],  [The CubeSat shall downlink PPL data according to a packet prioritisation system.],
    [SYS-083],  [The CubeSat shall downlink TM data according to a packet prioritisation system.],
    // TTC
    [TTC-013],  [The primary communication system shall be capable of transmitting PPL data to the GS with a minimum data rate of 5 kbps (TBC).],
    [TTC-014],  [The primary communication system shall be capable of transmitting TM data to the GS with a minimum data rate of 5 kbps (TBC).],
    [TTC-016],  [The primary communication system shall downlink packetised data according to a packet prioritisation system. ],
    [TTC-019],  [The primary communications system shall be capable of transmitting packetised data to the ground station (network) at a capacity in the range of 5-50 kbps (TBC).],
    [TTC-021],  [During ground communication windows, the primary communications system shall have a minimum link margin of 3dB.],
    
  ),
  caption: "Relevant system and TT&C requirements for downlink communications"
) <System-Requirements>

There also exist data handling requirements, although this is an area that needs substantially more work at this time, so are currently vague and provided little impact to the implementation.



Derived from the design are some further interface requirements.



= Packet Handling
// GSE Usage
// Why not gse-lite?
// -- PPL Data size req
// PBR block sizes
// XTCE Schemas / CCSDS Packet Library
The packets onboard STRATHcube can be grouped into two distinct types: Telemetry, those that are required for the continued functioning of the spacecraft, such as information regarding battery state or the orientation of the craft. The second being payload packets, such as the measured IQ signals during an observation period.

Of the two types, telemetry has 

// non-exhaustive list of packet types and grouping

= Transmitter
// Continuous stream vs generic stream etc,
// Decision not to use DVB-S2X features

#figure(
  image("../Figures/System-Architecture/DVB-S2.drawio.svg"),
  caption:"Transmitter Block Diagram"
)


= Full System

// TODO: PHY -> not that"C"OR
// TODO: AD936x controller control signals
#figure(
  image("../Figures/System-Architecture/System_Diagram.drawio.svg",width:75%),
  caption: "System Diagram"
)

// TODO: ACM return path
// TODO: Reerence link analysis
Due to the limitation of scope for this project, the particulars of the channel measurement has been underdeveloped. The two main factors are accuracy and frequency.
As identified in TODO:, the main varying factor is the distance from the ground station to the satellite which can be computed in advance, giving #acr("VCM"). Interference has not been extensively analysed, but is expected to be a significant and varying factor.

Another important factor for the system is "in the blind" communications, i.e. downlink data transmission without any uplink communications from the ground station. Under these conditions, there is no return channel to facilitate #acr("ACM") operation. Additionally, prescheduled #acr("VCM") operation requires orbit position information that may not be present. For this reason, the lowest MODCOD of QPSK 1/4 shall be used, as this maximises availaibility.