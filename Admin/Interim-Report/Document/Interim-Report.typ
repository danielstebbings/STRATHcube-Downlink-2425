
#import "@preview/timeliney:0.1.0"
#import "@preview/subpar:0.2.0"
#import "@preview/acrostiche:0.5.0": *

// Set up page, paragraphs, text size
#set page(
  margin: (top: 1cm, bottom: 1cm, left: 1cm, right:1cm),
  numbering: "1",
  number-align: right
  )
#set par(
  spacing: 0.8em,
  first-line-indent: 0.8em,
  justify: true,
)
#set text(
  size: 10pt
)
// Heading numbering 1.0, 1.1, 1.1.1
#set heading(
  numbering: "1.",
)

// Defines acronyms when first used
// pl - plural uses 
// Acrostiche)
#init-acronyms((
  "DVB-S2": "Digital Video Broadcasting - Satellite - Second Generation",                          
  "ACM": "Adaptive Coding and Modulation",
  "TS": "Transport Stream",
  "XTCE": "XML Telemetric and Command Exchange",
  "SDR": "Software Defined Radio",
  "UPL": "User Packet Length",
  "DFL": "Data Field Length",
  "BBFRAME": "Baseband Frame",
  "PBR": "Passive Bistatic Radar",
  "ISS": "International Space Station",
  "COTS": "Commercial Off-The-Shelf",
  "BCH": "Bose-Chaudhuri-Hocquenghem",
  "LDPC": "Low-Density Parity-Check",
  "FECFRAME": "Forward Error Correction Frame",
  "PLFRAME": "Physical Layer Frame",
  "FEC": "Forward Error Correction",
  "SNR": "Signal to Noise Ratio",
  "CNR": "Carrier to Noise Ratio",
  "ITU": "International Telecommunication Union",
  "OFCOM": "Office of Communications",
  "PS": "Processing System",
  "PL": "Programmable Logic",
  "CCSDS": "Consultative Committee for Space Data Systems",
  "ESA": "European Space Agency",
  "FYS": "Fly Your Satellite",
  "RF": "Radio Frequency",
  "CCDD": "Core Flight System (CFS) Command and Data Dictionary",
  "IPC": "Inter-Process Communication",
  "SoC": "System on Chip",
  "CRC-8": "8 bit Cyclic Redundancy Check",
  "GSE": "Generic Stream Encapsulation",
  "FIFO": "First In First Out",
  "I2C": "Inter-Integrated Circuit",
  "CAN": "Controller Area Network",
  "IP": "Internet Protocol",
  "PDR": "Preliminary Design Review",
  "BER": "Bit Error Rate",
  "FPGA": "Field Programmable Gate Array",

))


= Project Context & Background <Project_Context>

== STRATHcube
STRATHcube is a student led satellite project at the University of Strathclyde that will be launched from the International Space Station with the aim of demonstrating the use of a #acr("PBR") for in-orbit detection of space debris. This project aims to create an engineering model of the downlink communication system for the satellite using commercially available development boards in compliance with relevant standards, a key step towards the preliminary design review with the #acr("ESA") Fly Your Satellite program.

The satellite will include an Alén Space TOTEM #acr("SDR") to handle both communication and #acr("PBR") systems, which consists of an AMD Zynq 7020 #acr("SoC") connected to an Analog Devices AD9364 RF transceiver. Due to the high cost of space qualified hardware, it will be modelled by a Digilent Zedboard connected to an FMCOMMS1 AD9361 development board. This has an identical Zynq #acr("SoC") with less external memory and a similar RF transceiver.

A summer research project investigated the downlink configuration, selecting a frequency range of 430-440MHz, creating a link budget and selecting DVB-S2 (Digital Video Broadcasting - Satellite - Second Generation)#mark-acr-used("DVB-S2") as the modulation scheme. This has extremely strong #acr("FEC") capabilities and can adapt based on channel conditions to maximise spectral efficiency with #acr("ACM").

As this project ties into a larger mission, it was important to identify clear goals and limit scope. The primary goal is to create a detailed system definition and implementation of the downlink communication system that maximises data throughput over the duration of the mission. The detailed definition of packet structures, uplink communication system and final implementation on flight hardware are outside the scope of this project. To ensure that the final solution is suitable, systems will be designed to comply with #acr("CCSDS") standards where possible.

== DVB-S2
=== Overview
The #acr("DVB-S2") standard is modular with several optional blocks and data formats depending on the application@noauthor_dvb-s2_nodate. This project will use a single generic packetised stream with a fixed #acr("UPL"), as it includes #acr("CRC-8") error detection. The data stream is sliced into #acr("DFL") sized chunks and a header inserted to become a #acr("BBFRAME"). The #acr("FEC") systems require the #acr("BBFRAME") to be padded to a specific length that depends on the current #acr("ACM") settings. After two coding stages, this becomes a FECFRAME#mark-acr-used("FECFRAME") which goes through constellation mapping, pilot insertion and scrambling to become a Physical Layer Frame. It is finally filtered and modulated up to the carrier frequency.

#acr("DVB-S2") uses four modulation schemes from QPSK to 32APSK, coding rates from 1/4 to 9/10 and two #acr("FECFRAME") lengths. These parameters, along with #acr("DFL") and #acr("UPL"), are controlled by the #acr("ACM") Router to adapt to channel conditions and can be changed from one #acr("BBFRAME") to the next. To minimise padding, a link layer protocol can be used called #acr("GSE") that handles the fragmentation of packets based on the current optimal #acr("DFL")@noauthor_ts_nodate

=== Implementation
The Zynq #acr("SoC") consists of a traditional #acr("FPGA"), referred to as the #acr("PL") combined with two ARM processing cores, referred to as the #acr("PS"). One of the key challenges of this project is managing #acr("PL") resource usage. The flight hardware must handle uplink and downlink communications, #acr("PBR") processing and existing code included by the manufacturer. A target of no more than 50% usage on any one resource was implemented to ensure everything could fit. The second key challenge is reliability, verification, and adherence to standard. To ensure this, a MATLAB example DVB-S2 implementation using HDL Coder will be modified to minimise resource requirements and integrate with the rest of the system. Packet handling will be managed on the #acr("PS"), including #acr("ACM"), scheduling, any #acr("GSE") implementation and header configuration.

#stack(
  dir:ltr,
  box(width: 10.5cm)[
    == Adaptive Coding and Modulation Analysis

    Due to the complexity of implementing #acr("ACM") in the system, an investigation into the benefits over a fixed configuration that maximised availability was conducted. The satellite was simulated for the full mission duration at its initial altitude of 400km using the MATLAB Satellite Communications Toolbox. The elevation of the satellite during each pass over the Glasgow based ground station was binned into 5#symbol("°") increments. An existing link budget was used to calculate the #acr("CNR") for each elevation bin and cross-referenced to the optimimum modulation and coding rate using the #acr("DVB-S2") standard with a 10dB link margin and #acr("BER") of 10#super("-7"). The maximum possible throughput was calculated for each elevation bin and multiplied by the time spent to find the total throughput for each strategy. The results are shown in @Elevation2Capacity and show a significant increase in throughput, proving that the complexity of implementing #acr("ACM") is worth the benefits.
  ],
  [
    #figure(
        
        image("Figures/Elevation2Throughput.svg",width:50%),
        caption: [Left - Elevation vs modulation and coding rate (Blue), \
         modulation and Coding rate to throughput (red). \
         Top Right - Time spent in each elevation bin. \
          Bottom Right - Throughput vs strategy.]
        ) <Elevation2Capacity>
  ]
)
== Packet Handling
=== Interfacing and Formatting
When designing the system, it was important to balance implementation complexity with future integration of the final system as the onboard data handling on the satellite is an area that has not been fully developed. For this purpose it was decided to design all systems to be compatible with #acr("XTCE") formatted packets. #acr("XTCE") was defined by the #acr("CCSDS") in order to unify the interpretation of data between space systems and is widely supported. This will allow generic packets to be defined for testing without restricting future development. 

Project packet definitions will be managed by a NASA tool called #acr("CCDD"). This can be used to generate C headers for parsing, or a Python library may be used. The Python approach may be simpler to implement, but the C headers will be more efficient, and easier to integrate with the rest of the system.

The TOTEM SDR is connected to the rest of the satellite through two bus interfaces: #acr("CAN") and #acr("I2C"). There is also an Ethernet interface for ground testing and the #acr("PBR") systems running in parallel on the #acr("PS") connected through Linux #acr("IPC"). The system will be designed to accept packets from all of these sources in parallel.

=== ACM Routing and PL Interface
A previous dissertation project investigated the scheduling and compression requirements of the downlink system. This identified a need to prioritise housekeeping packets over #acr("PBR") data. The research also selected the POCKET lossless compression algorithm and created a Python implementation in order to reduce the data footprint of packets.

The #acr("DVB-S2") implementation guidelines define methods for controlling quality of service for several types of input stream, including transmission priority and changing the #acr("ACM") policy. This could allow the use of a lower speed, low #acr("BER") target for housekeeping data and a lower reliability target but higher speed for #acr("PBR") data to increase total throughput. The flight implementation of the #acr("ACM") Router will utilise information received from uplinked data, which must be synthesised for this project based on expected channel conditions.

#acr("GSE") may be used to handle the varying #acr("DFL") due to #acr("ACM"), however the standard defines several features required for Internet Protocol that may not be necessary for this application. To reduce complexity, the system may implement only a subset of the standard.

The #acr("ACM") Router will interface with the #acr("PL") using "libiio", a library for interfacing with devices that use the Linux Industrial Input Output subsystem. Created by Analog Devices, this library is well documented and simplifies the creation of drivers.

== System Architecture

#stack(
  dir:ltr,
  spacing:0.5cm,
  box(width:9cm)[
    The resulting system will have a structure as shown in @SystemDiagram, with three main blocks on the #acr("PS"), most of which connected through buffers.
    
    The first is the system interface, which collates packets from each external interface buffer and forwards them for parsing. 

    The Packet Parser will read each packet to identify its priority level, placing them accordingly in buffered queues.

    The ACM Router will select packets based on their priority according to its scheduling policy. It will also choose ACM settings based on the current reported channel conditions and encapsulate packets accordingly using #acr("GSE"). The packets and #acr("ACM") command information will be passed to the relevant registers using the #acr("PL") Interface.

    This data will go through modulation on the #acr("PL") and be converted into In-phase and Quadrature (IQ) data for the transceiver. Control of the physical device will be through MATLAB HDL Coder blocks available from the Analog Devices that interface with the transceiver over a Low Voltage Digital Signalling (LVDS) link. The resulting RF signal output can then be connected to an SDR for analysis.



  ],
  [
    #figure( 
        image("Figures/System_Diagram.drawio.svg", width:50%),
        caption: "System Diagram"
      ) <SystemDiagram>
  ]

)

#pagebreak()
#set page( 
flipped: true,
  paper: "a4",
  margin: (x: 0.5cm, y: 0.5cm)
)

= Project Timeline

#set text(
  size: 8pt,
)
// Define some styles
#let tl_deliverables   = (stroke:2pt + color.rgb("#f75757"))
#let tl_research       = (stroke:2pt + color.rgb("#f1aa30"))
#let tl_implementation = (stroke:2pt + color.rgb("#7bfc61"))
#let tl_verification   = (stroke:2pt + color.rgb("#6bfaff"))
#let tl_syseng         = (stroke:2pt + color.rgb("#dc62fa"))
// Week offsets
#let sem1 = 0
#let sem2 = 16
#let exam = 11
#let os_break = 13



#timeliney.timeline(
  show-grid: true,
  spacing: 3pt,
  milestone-layout: "in-place",
  {
    import timeliney: *
    //headerline(
    //  group(([*Project Timeline*], 13+3+12)),
    //)
    headerline(
                group(([*Semester 1*], 13)),
                group(([*Break*],       3)), 
                group(([*Semester 2*], 12))
                )
    headerline(
      group(..range(11).map(n => strong("W" + str(n + 1)))),
      group(..range(2).map(n => strong("E" + str(n + 1)))),
      group(..range(3).map(n => strong("C" + str(n + 1)))),
      group(..range(12).map(n => strong("W" + str(n + 0)))),
    )
    
    taskgroup(title: [*D - Deliverables*], {
      task("D1 - Statement of Intent",   (1+sem1,   3+sem1),  style: tl_deliverables)
      task("D2 - Interim Report",        (10+sem1,  13+sem1), style: tl_deliverables)
      task("D3 - Poster",                (2+sem2,   7+sem2),  style: tl_deliverables)
      task("D4 - Final Report",          (7+sem2,   11+sem2), style: tl_deliverables)
        })
        
        taskgroup(title:[*R1 - Research - STRATHcube*], {
      task("R1.1 - Mission Requirements",  (4.5+sem1,11+sem1), style: tl_research)
      task("R1.2 - Data Handling",         (6+sem1, 11+sem1),  style: tl_research)
      task("R1.3 - Link Budget",           (2+sem1, 6+sem1),   style: tl_research)
      task("R1.4 - TOTEM SDR",             (1+sem1, 11+sem1),  style: tl_research)
        })

        taskgroup(title: [*R2 - Research - DVB-S2*], {
      task("R2.1 - ACM",                      (2.5+sem1,9.5+sem1),  style: tl_research)
      task("R2.2 - Standard",                 (2+sem1,  5+sem1),    style: tl_research)
      task("R2.3 - Existing Implementations", (1+sem1,  0+os_break),style: tl_research)
      task("R2.4 - GSE",                      (0+exam,  0+os_break),(1+os_break,3+os_break),style: tl_research)
        })

        taskgroup(title: [*R3 - Research - Packet Handling*], {
      task("R3.1 - XTCE Standard",         (3+sem1, 0+os_break),    style: tl_research)
      task("R3.2 - Libraries",             (6+sem1, 11+sem1),       style: tl_research)
        })              
        
        taskgroup(title:[*S - Systems Engineering*], {
      task("S1 - Requirements",            (4+sem1, 12+sem1),   style: tl_syseng)
        })

        taskgroup(title:[*I1 - Implementation - Transmitter*], {
      task("I1.1 - Resource Usage Analysis", (5+sem1,   8+sem1),   style: tl_implementation)
      task("I1.2 - Transceiver Integration", (1+os_break,1+sem2),   style: tl_implementation)
      task("I1.3 - Libiio Driver",           (1+sem2,   4+sem2),   style: tl_implementation)
      task("I1.4 - PL-PS Integration",   (2+sem2,   4+sem2),   style: tl_implementation)
      task("I1.5 - Resource Optimisation",   (9+sem2,   11+sem2),  style: tl_implementation)
        })

        taskgroup(title:[*I2 - Implementation - Packet Handling*], {
      task("I2.1 - System Interfacing",      (3+exam, 0.5+sem2), style: tl_implementation)
      task("I2.2 - XTCE",                    (0+sem2, 3+sem2),   style: tl_implementation)
      task("I2.3 - ACM Router",              (4+sem2, 7+sem2),   style: tl_implementation)
        })

        taskgroup(title:[*V1 - Verification - Required*], {
      task("V1.1 - Timing Closure",               (1+sem2, 2+sem2),   style: tl_verification)
      task("V1.2 - Individual component testing", (0+sem2, 6.5+sem2), style: tl_verification)
      task("V1.3 - System Testing",               (7+sem2, 10+sem2),  style: tl_verification)
      task("V1.4 - Performance Requirements",     (7+sem2, 10+sem2),  style: tl_verification)
        })

        taskgroup(title:[*V2 - Verification - Optional*], {
      task("V2.1 - Hardware in the Loop",    (8+sem2, 10+sem2),  style: tl_verification)
      task("V2.2 - Memory Corruption",       (8+sem2, 10+sem2),  style: tl_verification)
        })
    
    // Deadlines
    milestone(
      at: 3+sem1,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Statement of Intent*\
        Week 3 S1
      ])
    )
    milestone(
      at: 1+exam,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Interim Report*\
        Exam Week 1
      ])
    )
    milestone(
      at: 7+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Poster*\
        Week 7 S2
      ])
    )
    milestone(
      at: 11+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Final Report*\
        Week 11 S2
      ])
    )

    // Development Decision Points
    milestone(
      at: 10+sem1,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *DP1 - Dev v Flight HW*\
        week 10 S1
      ])
    )
    milestone(
      at: 8+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        \
        \

        *DP2 - HW Testing v Software Completion*\
        week 8 S2
      ])
    )
    
    // Development Milestones
    milestone(
      at: 11.07+sem1,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *MS1 - System Architecture*\
        week 11 S1]
      )
    )
    milestone(
      at: 3+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *MS2 - System Prototype*\
        week 3 S2
        
      ])
    )

  }
)
#set page( 
flipped: false,
  paper: "a4"
)
#pagebreak()

#set text(
  size: 10pt,
)

= Project Review

== Project Plan
The first semester has been devoted to the research and planning of the project. The outcome of which has been a detailed analysis of each sub-block required for the final system and the identification of open source resources and relevant standards to ensure success.

There are three key milestones outlined in the project timeline. The first being the system architecture, which has been defined in @Project_Context. The second is the creation of a "System Prototype" which will demonstrate the minimum features necessary to send a packet through the system. This is targeted for Week 3 of Semester 2. 

There are two key decision points, marked "DP1" and "DP2". DP1 has been reached, and marks the decision to target development hardware, as the TOTEM SDR could not be procured in time for the project. DP2 will be reached in Week 8 of Semester 2 and will mark the decision to focus on end to end testing of the system versus continuing feature development.

To ensure time is left for the final report, a design freeze will be implemented during week 9 of semester 2. This means that no major features or changes will be implemented from that point onwards to ensure that the system is finalised and tested in advance of the final report deadline.


== Technical Riskswf7f057"), 4: color.rgb("#aaf757"), 5: color.rgb("#57f757"))

// #show table.cell: it=> {
//   if it.x == 4 and it.y > 0 {// L*S column values
//     // Colour by L*S in groups of 5
//     // 1-5, 6-10, 11-15, 16-20, 21-25
//     set text(color: risk_colour[1 + (it.value - 1) / 5])
//   } else {
//     // otherwise, 
//     it
//   }
// }

#set text(
  size: 8pt,
)
#table(
  columns: (auto,auto,auto,auto,auto),
  inset: 6pt,
  align: (horizon,horizon,center,center,center),
  table.header(
    [*Risks*], [*Mitigation*],[*Likelihood*],[*Severity*],[*L\*S*]
  ),
  [Catastrophic Dataloss],[ + Use of cloud storage
                            + Use of Git source control
                            + Regular snapshots of work],
                            [1],[5],[5],
  [Severe Illness],       [ + Creation of draft submissions on    
                              Myplace to avoid missing deadlines
                            + Report personal circumstances on Pegasus
                            + Discussion of reduction of scope with supervisor],
                            [1],[4],[4],
  [Breakage of key equipment],  [+ Only work in designated areas
                                 + Use of equipment as designed, with care given for fragile connectors
                                 + Identification of alternatives available in the department],
                                [2],[3],[6],
  ["Feature Creep"],      [ + Creation of requirements document
                            + Regular review of work with supervisor
                            + Scope freeze decided at Interim report, with options for further reduction identified in project plan],
                            [3],[2],[6],
  [Difficulty in system integration], [ + Regular project meetings with supervisor
                                        + Adherence to best practices in RTL design with 
                                          continous verification and testing
                                        + Use of version control to track changes
                                        + Use of a modular design to allow verification of components
                                        + Use of resources from manufacturers to ensure compatibility],
                                        [3],[2],[6],
  [Extended learning curves of new languages and tools], [+ Use of online resources
                                                          + Use of existing knowledge of similar tools to reduce learning curve
                                                          + Use of manufacturer resources],
                                                          [3],[2],[6],
  [System not fit for purpose], [ + Design with requirements in mind
                                 + Use of open-source examples to ensure compatibility and reliability
                                 + Use of a modular design to allow for changes and unit testing],
                                 [2],[3],[6],
)

#set text(
  size: 10pt,
)

== Sustainability

STRATHcube's primary mission relates to a pressing issue in the space industry. The #acr("PBR") will demonstrate a technology that could fill a critical resolution gap in debris detection that ground based radars cannot. The importance of space situational awareness cannot be understated, as the amount of operational satellite increases there will be a higher risk of impact with debris too small to be detected with current methods.

The more data that can be downlinked during the mission, the more opportunities there are to observe passing debris and verify the operation of the #acr("PBR"). As such, the successful completion of this project will directly contribute to the success of the mission and an important aspect of space sustainability.

== Ethical Considerations and EDI

The main ethical considerations for this project lie in compliance to relevant telecommunications regulations from the #acr("ITU") and #acr("OFCOM"). During development, all transmissions will be conducted using certified equipment and through cables to ensure that no harmful interference is caused. 

The resulting source code will be made available to the public under an open-source license to ensure that the project is transparent and accessible to all. This will also allow for the project to be continued for further use in STRATHcube or as a resource for other projects.

Aditionally, space is a resource that underpins modern society and it is important to ensure that it is used responsibly. The primary and secondary missions of STRATHcube will positively contribute to space sustainability and as such will have a positive impact that will support society as a whole.

#pagebreak()
= References
#bibliography(
  title:none,
    full: true, "Bibliography/Dissertation.bib", style:"institute-of-electrical-and-electronics-engineers",

    )