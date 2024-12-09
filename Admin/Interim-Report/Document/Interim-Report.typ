
#import "@preview/timeliney:0.1.0"
#import "@preview/subpar:0.2.0"
#import "@preview/acrostiche:0.4.1": *

// Set up page, paragraphs, text size
#set page(margin: (top: 1.25cm, bottom: 1cm, left: 1.5cm, right: 2.5cm), numbering: "1", number-align: right)
#set par(
  spacing: 0.65em,
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
  "ITU": "International Telecommunication Union",
  "OFCOM": "Office of Communications",
  
))


= Project Context

== STRATHcube
STRATHcube is a student led satellite project at the University of Strathclyde that will be launched from the #acr("ISS") with the aim of demonstrating the use of a #acr("PBR") for in-orbit detection of space debris. This project aims to create an engineering model of the downlink communication system for the satellite using #acr("COTS") development boards.

A research project this summer investigated the configuration of the downlink communication system for the satellite, creating a link budget and selecting #acr("DVB-S2") as the modulation scheme. The scheme has multiple key advantages, as it has robust #acr("FEC") capabilities that allow it to operate extremely close to the shannon limit for a given #acr("SNR"). Additionally, the #acr("ACM") capabilities of the system allow it to adapt to changing channel conditions, improving the efficiency of the system.

== DVB-S2 Modulation
=== Overview
The #acr("DVB-S2") standard defines a modulation scheme specifically designed for satellite 
communications. To improve the efficiency of the system, the modulation constellation and coding 
rate can be adapted based on channel conditions using #acr("ACM"). Despite what the name may 
imply, the standard is not limited to video broadcasting and can be used for transmission of any 
packetised data, the data carried by the system is referred to as a stream. There are three main types of data stream: Transport, Generic Packetised and Generic Continuous. Each of these are defined by their #acr("UPL"), being the number of bytes in a packet. @DVBS2Full shows the full possible system diagram for a DVB-S2 system, while @DVBS2 shows the condensed version for a Generic Packetised stream.

A Generic Packetised stream may have a #acr("UPL") between 1 and 65535 Bytes. Variable #acr("UPL"), or sizes greater than 65535 Bytes are treated as a Generic Continuous Stream. The data stream is then sliced into Data Fields of size #acr("DFL"). After a header is inserted, this comprises a #acr("BBFRAME"). 

The #acr("BBFRAME") is then padded to align with the requirements of the #acr("BCH") and #acr("LDPC") encoders. This length, referred to in the standard as k#sub("BCH"), is dependent on the modulation, coding rate and #acr("FECFRAME") size. As such, the efficiency of the system can be improved by optimising the #acr("UPL") and #acr("DFL") to minimise the padding required. Additionally the #acr("FECFRAME") size can be chosen between short (16200 bits) and normal (64800 bits) to balance the responsiveness of the system with the overhead of the error correction. This is the responsibility of the ACM router.

The #acr("FECFRAME") is then mapped to a constellation, pilots inserted, scrambled and modulated to the carrier frequency.


== Configuration Decisions



#figure(
    image("Figures/DVB-S2-Sliciing.png"),
    caption: "DVB-S2 Slicing Diagram"+ ref(<dvbs2_standard>)
    ) <DVBS2Slice>
)

#figure(
    image("Figures/DVB-S2_Full.png"),
    caption: "DVB-S2 System Diagram"+ ref(<dvbs2_standard>)
    ) <DVBS2Full>

#figure(
   image("Figures/DVB-S2.png"),
    caption: "DVB-S2 System Diagram"
    ) <DVBS2>

== Packet Handling
=== XTCE Standard
=== System Architecture
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

== Technical Risks

== Sustainability

STRATHcube's primary mission to demonstrate the use of a #acr("PBR") is also combined with the secondary mission to collect telemetry data during re-entry to tackle some of the most important issues in the space industry today. The increasing number of satellites in orbit is leading to a large amount of space debris which poses a significant risk to operational satellites in congested areas such as sun synchronous orbits. This field is referred to as space situational awareness. The ability to detect and track space debris is crucial to ensure the safety of future missions however there are resolution issues with ground based solutions that can be solved by using a #acr("PBR") in orbit.

The main solution today for space debris is to de-orbit satellites at the end of their operational life. This process is difficult to model at present, as there are complex interactions between the satellite and the atmosphere at hypersonic speeds. The data collected during the re-entry of STRATHcube will be used to validate TITAN, a tool developed by the University of Strathclyde and overall improve the process of "Design for Demise" which is an increasingly important requirement for satellite design.

== Ethical Considerations

The main ethical considerations for this project lie in compliance to relevant telecommunications regulations from the #acr("ITU") and #acr("OFCOM"). During development, all transmissions will be conducted using certified equipment and through cables to ensure that no harmful interference is caused. 

= References
#bibliography(
  title:none,
    full: true, "Bibliography/Dissertation.bib", style:"institute-of-electrical-and-electronics-engineers",

    )