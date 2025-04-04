#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"
#set heading(offset: 1)

= Systems Engineering <system-engineering-section>
// TODO: Development of requirements
// TODO: Review of existing requirements
// 

In order to work effectively in a large project structure, a review of system requirements was conducted with close collaboration with system engineers on the team.

This contributed to a complete overhaul of all #acr("TT&C") requirements to be more relevant to actual operations, for submission as part of the ESA Baseline Design Review. The relevant requirements are shown in @TTC-Reqs. The figures marked #acr("TBC") are indicative only, pending full analysis of the mission parameters. PPL refers to the Primary Payload, the #acr("PBR"). TM refers to telemetry data, including data about the spacecraft state, such as battery charge levels. GS refers to the Ground Station, (network) used to indicate that there may be several.

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
  caption: "Relevant system and TT&C requirements for downlink communications."
) <TTC-Reqs>

The data handling requirements had not yet been substantially explored at time of writing. The most relevant requirements that had been created are shown in @Data-handling-reqs. OBC refers to the On-Board Computer, used for data processing and control of the spacecraft. OBSW refers to On-Board SoftWare, this refers to any code running on the satellite, whether it is on the #acr("SDR"), OBC, or elsewhere. The listed protocols are #acr("CAN"), #acr("UART"), and #acr("I2C").


#acused("OBC")

//TODO: review obsw reqs, make sure all relevant ones are met.
#figure(
  table(
    columns: 2,
    inset: 6pt,
    align: (horizon,left), 
    table.header(
      [*Code*],[*Description*],
    ),
    [ODH-039],[The OBC shall support standardised protocols such as CAN/UART/I2C.],
    [ODH-040],[The OBSW shall produce PPL data packets that include timestamp, I/Q, position, and attitude.],
  ),
  caption: "Relevant data handling requirements.",
) <Data-handling-reqs>

From these requirements, rough design objectives were derived for the downlink communication system:

// TODO: formatting on numbers
// TODO: Embetter
// TODO: Justification

#set enum(numbering: "1.a.i.")
+ The system shall support packet input from all interfaces present on the TOTEM SDR <totem-interface-objective>
+ The system should maximise datarate while conforming to #acr("BER") requirements.
  + The system shall support modification of modulation and coding rate through #acr("ACM") or #acr("VCM").
  + Efficiency should be prioritised. The design should use minimal padding and seek to reduce overheads.
+ The system should be reliable
  + The system shall be designed for testability.
    + Large pieces of logic shall be broken up into smaller systems that can be unit tested.
    + Assertions shall be used regularly throughout code and block designs.
  + The system shall be tested thoroughly using simulation to verify operation.
+ The downlink subsystem and PBR system should fit on the PL at the same time. // Regular reconfiguration is complex. If code gets corrupted, could be major issues!
  + The downlink system should use no more than 50% of any one resource type.
+ The downlink subsystem shall be capable of transmitting packets that are over 64kB.

Requirement 4 follows on from requirement 3 of reliability. If the FPGA has to be reconfigured for every downlink pass, this introduces a large amount of complexity. If this process fails, communication will have to fall back to the much slower secondary communication system. There is also the effect of radiation to consider, if the stored bitstream file is corrupted its recovery could be very difficult.

Requirement 5 is derived from the #acr("PBR") packet size requirements. This is discussed further in @fragmentation-section.

= Packet Handling
== Quality of Service
// GSE Usage
// Why not gse-lite?
// -- PPL Data size req
// PBR block sizes
// XTCE Schemas / CCSDS Packet Library
The packets onboard STRATHcube can be grouped into two distinct types. The first is telemetry, those that are required for the continued functioning of the spacecraft, such as information regarding battery state or the orientation of the craft. The second being payload packets, such as the measured IQ signals during an observation period.

Of the two types, telemetry packets are more important and make up a much smaller proportion of total data sent. These telemetry packets are to be compressed using the POCKET or POCKET+ algorithm. This may occur on the SDR, but is more likely to be done in advance on the #acr("OBC"). 

To maximise datarates, it is possible to group packets into classes, and apply rules for #acr("BER") seperately for each class. For instance, the primary payload data may be transmitted with a #acr("BER") target of $10^-5$, and the telemetry data with a target of $10^-9$. The exact targets should be subject of future analysis, as retransmission of primary payload data could be extremely costly due to large block sizes.

== Fragmentation <fragmentation-section>
//TODO: Reference OPS-SAT FAPEC re chunk size
The FAPEC algorithm was one of the options identified for compression of the #acr("PBR") data, which outputs data in "chunks". These chunks typically have a fixed size, ranging from 4kB to 384 MB @de_mora_image_2022. If the compressed data is corrupted, only those chunks containing errors need to be corrected, therefore, the selection of chunk size provides a logical minimum packet size. The maximum #acr("DFL") for DVB-S2 is 58,112 bits, or 7264 Bytes. This is only possible when using the highest modulation and coding rates, which are not expected to be feasible for much of the mission. For this reason, it was deemed likely that the #acr("PBR") data packets would require fragmentation across multiple frames.

#acr("GSE") will be used for this purpose, as it is specifically designed for DVB-S2 transmission. A #acr("GSE") packet has the following structure:

#figure(
  image("../Figures/System-Architecture/GSE_Structure.drawio.svg"),
  caption:"GSE packet structure. The header is composed of two sections, the first is fixed, and the second has content determined by those fixed flags. This is followed by the data field, with the final part being a CRC32 checksum to detect reconstruction errors."
) <GSE_Structure>

#subpar.grid(
  columns: (1fr,1fr),
  caption: [GSE header fields. The fixed header is 16 bits long, while the variable header can be from 0 to 11 Bytes.],
  label: <gse_header_Structure>,
  
  figure(
    image("../Figures/System-Architecture/GSE_Fixed_Header.svg"),
    caption: "Fixed"
  ),  <gse_fixed>,
  figure(
    image("../Figures/System-Architecture/GSE_Variable_Header.svg"),
    caption: "Variable"
  ), <gse_variable>,
  
)

There are four key parts of the header for this application.

+ *Label Type*: Indicates the length or existence of the label field. Can also indicate if a label is to repeated from the previous GSE packet.
+ *Label*: Typically used to indicate addresses for networking. Optional.
+ *Total Length*: Total length of #acr("PDU") before fragmentation in bits. Maximum of 65536 Bytes.
+ *GSE Length*: Length of GSE packet in bits. Maximum of 4096 Bytes.

For this application, the label field is unnecessary, as the source and destination of packets is always known. This also means that the label type field could be omitted, saving two further bits per GSE packet at the expense of standard compliance.

The GSE standard also defines GSE-Lite which is optimised for constrained systems, however it only supports a max PDU size of 1800 Bytes, making it unsuitable for this application.

== Packet Definition
As discussed in @system-engineering-section, the data handling systems on the satellite were underdeveloped at time of writing, it was decided that the final system should accept packet schemas in order to handle future updates to packet structure with minimal refactoring. The #acr("XTCE") format was identified as suitable, as it is a #acr("CCSDS") standard that has been used for several missions. 

NASA has created an open source program called #acr("CCDD") which can be used for the creation and management of XTCE packet schemas. Additionally, it can export packets to C headers, which could be useful for future packet handling work.

= Transmitter
// Continuous stream vs generic stream etc,
// Decision not to use DVB-S2X features
It was decided to handle merging of packet streams in the processing system, and to implement a single stream transmitter using the programmable logic. This is due to the limited memory available in the FPGA fabric, which would otherwise be consumed by large buffers required for handling multiple streams simultaneously. It was also decided that the transmitter should support both continuous and generic stream transmission, as the GSE design architecture had not been finalised, meaning that variable packet sizes may be necessary. The resulting architecture with optional blocks removed is shown in @DVB-S2-Single-GS.

#figure(
  image("../Figures/System-Architecture/DVB-S2.drawio.svg"),
  caption:"Transmitter Block Diagram"
) <DVB-S2-Single-GS>


= Full System

#figure(
  image("../Figures/System-Architecture/System_Diagram.drawio.svg",width:75%),
  caption: "System Diagram"
)

Due to the limitation of scope for this project, the particulars of the channel measurement has not been investigated, there are two main requirements for the system: Accuracy and frequency of updates.

As identified in @ACM-Analysis-Section, the main varying factor is the distance from the ground station to the satellite which can be computed in advance, giving #acr("VCM"). Interference has not been analysed thusfar, but is expected to be a significant and varying factor that cannot be predicted, requiring the implementation of #acr("ACM"). The presented architecture allowed either to be implemented without redesign.

Another important factor for the system is "in the blind" communications, i.e. downlink data transmission without any uplink communications from the ground station. Under these conditions, there is no return channel to facilitate #acr("ACM") operation. Additionally, prescheduled #acr("VCM") operation requires orbit position information that may not be present. For this reason, the lowest MODCOD of QPSK 1/4 shall be used, as this maximises availaibility.