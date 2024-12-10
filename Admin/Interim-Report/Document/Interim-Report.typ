
#import "@preview/timeliney:0.1.0"
#import "@preview/subpar:0.2.0"
#import "@preview/acrostiche:0.4.1": *

// Set up page, paragraphs, text size
#set page(margin: (top: 1.25cm, bottom: 1cm, left: 1.5cm, right: 2.5cm), numbering: "1", number-align: right)
#set par(
  spacing: 1em,
  first-line-indent: 1em,
  justify: true,
)
#set text(
  size: 10pt,
)
// Heading numbering 1.0, 1.1, 1.1.1
#set heading(
  numbering: "1.",
)

// Defines acronyms when first used
// pl - plural uses 
// Acrostiche
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
  "CRC-8": "Cyclic Redundancy Check 8",
  "GSE": "Generic Stream Encapsulation",

))


= Project Context <Project_Context>

== STRATHcube
STRATHcube is a student led satellite project at the University of Strathclyde that will be launched from the #acr("ISS") with the aim of demonstrating the use of a #acr("PBR") for in-orbit detection of space debris. This project aims to create an engineering model of the downlink communication system for the satellite using #acr("COTS") development boards.

STRATHcube is being launched as part of the #acr("ESA") #acr("FYS") program. This imposes several requirements on the project such as transmit power limits, control and passivation. The team is also currently working on their application to the #acr("FYS") Design Booster program, which will provide additional support for the project. 

In order to successfully meet all requirements, relevant standards from #acr("ESA"), the #acr("CCSDS") and the #acr("ITU") will be followed. 
 
A research project this summer investigated the configuration of the downlink communication system for the satellite, creating a link budget and selecting #acr("DVB-S2") as the modulation scheme. The scheme has multiple key advantages, as it has robust #acr("FEC") capabilities that allow it to operate extremely close to the shannon limit for a given #acr("CNR"). Additionally, the #acr("ACM") capabilities of the system allow it to adapt to changing channel conditions, improving the efficiency of the system.

STRATHcube will include a TOTEM #acr("SDR") that will handle both the communication and primary payload systems. The TOTEM consists of a Zynq 7020 #acr("SoC") connected to an Analog Devices AD9364 RF transceiver with full duplex capabilities. Due to the extremely high cost of space qualified hardware, development boards will be used for the project. A Digilent Zedboard will be used for processing as it has the same Zynq 7020 #acr("SoC") as the TOTEM, albeit with less memory. The RF transceiver will be modelled using an FMCOMMS1 development board connected via the FMC connector on the Zedboard. This has an AD9361 RF transceiver, which is identical to the AD9364 but with an extra channel that will be disabled.


== DVB-S2 Modulation
=== Overview
The #acr("DVB-S2") standard defines a modulation scheme specifically designed for satellite 
communications. To improve the efficiency of the system, the modulation constellation and coding 
rate can be adapted based on channel conditions using #acr("ACM"). Despite what the name may 
imply, the standard is not limited to video broadcasting and can be used for transmission of any 
packetised data, the data carried by the system is referred to as a stream. There are three main types of data stream: Transport, Generic Packetised and Generic Continuous. Each of these are defined by their #acr("UPL"), being the number of bytes in a packet. @DVBS2Full shows the full possible system diagram for a DVB-S2 system, while @DVBS2 shows the condensed version for a Generic Packetised stream.

A Generic Packetised stream may have a #acr("UPL") between 1 and 65535 Bytes. Variable #acr("UPL"), or sizes greater than 65535 Bytes are treated as a Generic Continuous Stream. The data stream is then sliced into Data Fields of size #acr("DFL"). After a header is inserted, this comprises a #acr("BBFRAME"). For packetised streams a #acr("CRC-8") sequence is inserted into the header to allow for error detection.

The #acr("BBFRAME") is then padded to align with the requirements of the #acr("BCH") and #acr("LDPC") encoders. This length, referred to in the standard as k#sub("BCH"), is dependent on the modulation, coding rate and #acr("FECFRAME") size. As such, the efficiency of the system can be improved by optimising the #acr("UPL") and #acr("DFL") to minimise the padding required. Additionally the #acr("FECFRAME") size can be chosen between short (16200 bits) and normal (64800 bits) to balance the responsiveness of the system with the overhead of the error correction. This is the responsibility of the ACM router.

The #acr("FECFRAME") is then mapped to a constellation, pilots inserted, scrambled and modulated to the carrier frequency. 

=== Configuration Decisions

As one of the key challenges of this project is managing resource usage, the system configuration will be chosen to minimise the requirements of the PL system. This means that packet scheduling, #acr("ACM") and header configuration will be managed by software on the #acr("PS"). This will allow quick and easy reconfiguration of the system in order to optimise for expected channel conditions.

There are two main types of data that the downlink system will have to carry, housekeeping data and primary payload data. Housekeeping data may come in several #acr("UPL") sizes and would be best suited to a generic continuous stream. Primary payload data will be larger and of a fixed size, making it best suited to a generic packetised stream. One method to handle both types of data efficiently is to use a #acr("GSE") layer to encapsulate the data, allowing handling of multiple #acr("UPL") sizes with varying #acr("DFL") and #acr("FECFRAME") sizes.


#figure(
    image("Figures/DVB-S2-Sliciing.png"),
    caption: "DVB-S2 Slicing Diagram"+ ref(<dvbs2_standard>)
    ) <DVBS2Slice>


#figure(
    image("Figures/DVB-S2_Full.png"),
    caption: "DVB-S2 System Diagram"+ ref(<dvbs2_standard>)
    ) <DVBS2Full>

#figure(
   image("Figures/DVB-S2.png"),
    caption: "DVB-S2 System Diagram"
    ) <DVBS2>

== Packet Handling
=== XTCE 
The #acr("XTCE") standard allows consistent definition of data packets, algorithms and commands to be used within a space system. This has been created by the #acr("CCSDS") in order to promote inter-operability between systems and for easy definition of new systems. This has been selected for the project, as allows for generic definition of telemetry packets to facilitate development of the communication system, without restricting future development of the satellite.

As #acr("XTCE") is quite a complex standard, several tools are available to manage the definition and parsing of packets. NASA have created a tool called #acr("CCDD") which allows for the definition of packets in a graphical interface which will be used in this project. Additionally, this tool is capable of generating code to parse the packets in C.

An alternative to parsing with headers generated by #acr("CCDD") is to use a Python library called "space_packet_parser" which has been used on multiple space missions. This has the advantage of being easy to implement and use, but may not be as efficient as a C implementation and introduces issues with the interoperation of subsystems written in different languages.

=== Interfacing
The TOTEM SDR has multiple interfaces from which it can receive packets from other satellite systems via the PC104 bus. The primary interfaces are a CAN bus and I2C bus which will be used during the mission. The TOTEM SDR also includes an Ethernet interface for ground testing which will be used for validation. As the primary payload system will be running on the TOTEM SDR, there is a potential requirement for receiving packets from other programs running on the #acr("PS"). This will be achieved using a #acr("FIFO") buffer with Linux #acr("IPC") mechanisms.

=== Scheduling & Compression
The onboard data handling has been analysed in a previous dissertation project. This identified the need to prioritise housekeeping data, such as GNSS data and power telemetry, over primary payload data. This project also defined multiple packet structures, along with their priority. These will be used to create sample packets for testing of the system.

This project also identified the need for compression of the data to reduce the amount to be transmitted, with the lossless POCKET algorithm being selected for this purpose. A C++ implementation of the newer POCKET+ algorithm is available that has been created based on the #acr("CCSDS") standard and will be used on the #acr("PS").

=== ACM Router
The #acr("ACM") router is responsible for managing the configuration of the #acr("DVB-S2") system. This includes selection of modulation, coding rates, #acr("FECFRAME") length and #acr("DFL"). In the final system these decisions will be made based on information received from the ground station, however for this project they will be made based on a pre-defined schedule. This will allow for the system to be tested under a variety of conditions and for the system to be optimised for expected channel conditions.

=== PL Interfacing
The interface driver for the #acr("PL") will be created using the libiio library created by Analog Devices.


== System Architecture
// Alignment of packets to frames
// System diagram
// Throughput requirements?

#figure( 
    image("Figures/System_Diagram.drawio.png"),
    caption: "System Diagram"
  ) <SystemDiagram>



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
      task("R2.3 - Existing Implementations", (1+sem1,  1+os_break),style: tl_research)
        })

        taskgroup(title: [*R3 - Research - Packet Handling*], {
      task("R3.1 - XTCE Standard",         (3+sem1, 3+os_break),    style: tl_research)
      task("R3.2 - Libraries",             (6+sem1, 11+sem1),       style: tl_research)
        })              
        
        taskgroup(title:[*S - Systems Engineering*], {
      task("S1 - Requirements",            (4+sem1, 12+sem1),   style: tl_syseng)
        })

        taskgroup(title:[*I1 - Implementation - Transmitter*], {
      task("I1.1 - Resource Usage Analysis", (5+sem1,   8+sem1),   style: tl_implementation)
      task("I1.2 - Transceiver Integration", (11.5+sem1,3+sem2),   style: tl_implementation)
      task("I1.3 - Resource Optimisation",   (9+sem2,   11+sem2),  style: tl_implementation)
      task("I1.4 - Libiio Driver",           (0+sem2,   4+sem2),   style: tl_implementation)
      task("I1.5 - GNU Radio Integration",   (3+sem2,   4+sem2),   style: tl_implementation)
        })

        taskgroup(title:[*I2 - Implementation - Packet Handling*], {
      task("I2.1 - System Interfacing",      (2+exam, 0.5+sem2), style: tl_implementation)
      task("I2.2 - XTCE",                    (2+exam, 6+sem2),   style: tl_implementation)
      task("I2.3 - Scheduling",              (5+sem2, 7+sem2),   style: tl_implementation)
      task("I2.4 - PL Interfaces",           (2+sem2, 3+sem2),   style: tl_implementation)  
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
        week 3 S1
      ])
    )
    milestone(
      at: 2+exam,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Interim Report*\
        Exam Week 2
      ])
    )
    milestone(
      at: 7+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Poster*\
        week 7 S2
      ])
    )
    milestone(
      at: 11+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Final Report*\
        week 11 S2
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
      at: 11+sem1,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *MS1 - System Architecture*\
        week 11 S1
        
      ])
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

= Project Review

== Project Plan
The first semester has primarily been devoted to the research and planning of the project as this was an area that had not been fully investigated prior. The main outcome of this work has been an in-depth system architecture that will facilitate implementation efforts in semester two. The lack of December exams also provides a key opportunity to get started on development before returning to classes in January.

There are three key milestones outlined in the project timeline. The first being the system architecture, which has been defined in @Project_Context. The second is the creation of a "System Prototype" which will demonstrate the minimum features necessary to send a packet through the system. This is targeted for Week 3 of Semester 2. The final milestone is the report submission. This will mark the completion of the system and documentation of the project.

There are two key decision points, marked "DP1" and "DP2". DP1 has been reached, and marks the decision to target development hardware, as the TOTEM SDR could not be procured in time for the project. DP2 will be reached in Week 8 of Semester 2 and will mark the decision to focus on end to end testing of the system, rather than feature development and completeion of software and RTL components.

To ensure time is left for the final report, a design freeze will be implemented during week 9 of semester 2. This means that no major features or changes will be implemented from that point onwards to ensure that the system is finalised and tested in advance of the final report deadline.


== Technical Risks

// Colouring risks by L*S
//#let risk_colour = (1: color.rgb("#f75757"), 2: color.rgb("#f7a057"), 3: color.rgb("#f7f057"), 4: color.rgb("#aaf757"), 5: color.rgb("#57f757"))

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

#table(
  columns: (auto,1fr,auto,auto,auto),
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
)


== Sustainability

STRATHcube's primary mission to demonstrate the use of a #acr("PBR") is also combined with the secondary mission to collect telemetry data during re-entry to tackle some of the most important issues in the space industry today. The increasing number of satellites in orbit is leading to a large amount of space debris which poses a significant risk to operational satellites in congested areas such as sun synchronous orbits. This field is referred to as space situational awareness. The ability to detect and track space debris is crucial to ensure the safety of future missions however there are resolution issues with ground based solutions that can be solved by using a #acr("PBR") in orbit.

The main solution today for space debris is to de-orbit satellites at the end of their operational life. This process is difficult to model at present, as there are complex interactions between the satellite and the atmosphere at hypersonic speeds. The data collected during the re-entry of STRATHcube will be used to validate TITAN, a tool developed by the University of Strathclyde and overall improve the process of "Design for Demise" which is an increasingly important requirement for satellite design.

== Ethical Considerations and EDI

The main ethical considerations for this project lie in compliance to relevant telecommunications regulations from the #acr("ITU") and #acr("OFCOM"). During development, all transmissions will be conducted using certified equipment and through cables to ensure that no harmful interference is caused. 

The resulting source code will be made available to the public under an open-source license to ensure that the project is transparent and accessible to all. This will also allow for the project to be continued for further use in STRATHcube or as a resource for other projects.

Aditionally, space is a resource that underpins modern society and it is important to ensure that it is used responsibly. The primary and secondary missions of STRATHcube will positively contribute to space sustainability and as such will have a positive impact that will support society as a whole.

= References
#bibliography(
  title:none,
    full: true, "Bibliography/Dissertation.bib", style:"institute-of-electrical-and-electronics-engineers",

    )