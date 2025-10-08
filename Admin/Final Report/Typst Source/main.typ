#import "@local/opinionated-eng-strath:0.2.0": *
#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/acrostiche:0.5.1": *
#import "@preview/wordometer:0.1.4" : word-count, total-words
#import "@preview/subpar:0.2.1"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/spreet:0.1.0"
#import "@preview/rexllent:0.3.0": spreet-parser


#init-acronyms((
  "STAC": ("Spacecraft Tracking & Command Station"),
  "VHF" : ("Very High Frequency"),
  "UHF" : ("Ultra High Frequency"),
  "FE"  : ("Front End"),
  "LVDS": ("Low Voltage Differential Signalling"),
  "DVB-S2": "Digital Video Broadcasting - Satellite - Second Generation",                          
  "ACM": "Adaptive Coding and Modulation",
  "TS": "Transport Stream",
  "XTCE": "XML Telemetric and Command Exchange",
  "SDR": "Software Defined Radio",
  "UPL": "User Packet Length",
  "DFL": "Data Field Length",
  "BBFRAME": "Baseband Frame",
  "IQ": "In-phase and Quadrature",
  "SPI": "Serial Peripheral Interface",
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
  "PS": "Processing System",
  "PL": "Programmable Logic",
  "CCSDS": "Consultative Committee for Space Data Systems",
  "ESA": "European Space Agency",
  "FYS": "Fly Your Satellite",
  "RF": "Radio Frequency",
  "CCDD": "Core Flight System (CFS) Command and Data Dictionary",
  "IPC": "Inter-Process Communication",
  "ISM": "Industrial, Scientific, and Medical",
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
  "ADC": "Analog to Digital Converter",
  "DAC": "Digital to Analog Converter",
  "ETSI": "European Telecommunications Standards Institute",
  "VCM": "Variable Coding and Modulation",
  "VL-SNR": "Very Low Signal-to-Noise Ratio",
  "BPSK": "Binary Phase Shift Keying",
  "PDU": "Protocol Data Unit",
  "AWGN": "Additive White Gaussian Noise",
  "RTL": "Register Transfer Level",
  "TT&C": "Telemetry, Tracking and Command",
  "CCM" : "Constant Coding and Modulation",
  "EDHPC": ("European Data Handling & Data Processing Conference"),
  "TBC": "To Be Confirmed",
  "OBC": "On Board Computer",
  "EIRP": "Effective Isotropic Radiated Power",
  "RAM" : "Random Access Memory",
  "FMC" : "FPGA Mezzanine Card",
  "BBHEADER" : "Base Band Header",
  "APSK" : "Amplitude and Phase Shift Keying",
  "MATYPE" : "Mode Adaption Type",
  "MODCOD" : "MODulation and CODing rate",
  "TLE" : ("Two-Line Element set"),
  "UART": "Universal Asynchronous Receiver-Transmitter",
  "MSB" : "Most Significant Bit",
  "LSB" : "Least Significant Bit",
))


// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: strathy.with(
  title: "Downlink System Design for the STRATHcube Satellite Mission",

  //takes in a list of dicts (name: full_name, reg: registration_number)
  authors: (
    (name: "Daniel Stebbings", reg: "202118874"),
  ),
  
  declaration: [
  I hereby declare that this work has not been submitted for any other degree/course at this University or any other institution and that, except where reference is made to the work of other authors, the material presented is original and entirely the result of my own work at the University of Strathclyde under the supervision of Louise Crockett.
  ],

  abstract: [
    //TODO: Update and change!
    Efficient downlink of recorded telemetry is a critical challenge in CubeSat missions, constrained by power limitations, bandwidth restrictions, and dynamic channel conditions imposed during a ground station pass. Further, many CubeSats use the Ultra High Frequency (UHF) amateur band which introduces the further issue of in-band interference which cannot be accounted for in advance. 
    
    To maximise throughput under these conditions, Adaptive Coding and Modulation (ACM) can be used. Digital Video Broadcasting – Satellite Second Generation (DVB-S2) is one such ACM system, with near Shannon limit performance and a modular standard allowing it to be matched to the use case. Despite this, there are no space rated UHF DVB-S2 transmitters currently on the market; this necessitates its implementation on a Software Defined Radio (SDR). While integrating an SDR can be costly and complex for many missions, the design of STRATHcube already includes one, minimising additional expenses.  

    STRATHcube is a student led 2U CubeSat mission at the University of Strathclyde, the primary payload being a technology demonstrator of a Passive Bistatic Radar (PBR) using an SDR and communicating in the UHF band. Consequently, there will already be a powerful System on Chip (SoC) Field Programmable Gate Array (FPGA) based SDR included on the mission. This allows for a DVB-S2 transmitter to be implemented as a piggy-back on the primary payload using spare resources.  

    This dissertation outlines the downlink system design for STRATHcube. Performance and link analysis was conducted, analysing communication windows over the course of the mission and expected theoretical performance. A high level architecture of the system was created and 
    the design implemented in hardware using MathWorks HDL Coder. Work also began on a Generic Stream Encapsulation (GSE) implementation using C++.

    Initial performance analysis was conducted in comparison to a baseline system which uses Constant Coding and Modulation (CCM) and optimises for maximum availability and showed a significant uplift in data throughput over the course of the mission. Additionally, resource analysis of the target FPGA SoC and the synthesised design show that the implementation is feasible in hardware.
  ],
//  acknowledgements: [
//
//    // 
//
//    // template acknowledgement 
//
//    // Rephrase, taken from paper acks
//    Thanks are given to the sponsors of the STRATHcube, without whom this project would not be possible: The University of Strathclyde Alumni Fund,
//    the Institute of Mechanical Engineers, the Royal Aeronautical Society, the University
//    of Strathclyde Mechanical and Aerospace Engineering Department, and the University
//    of Strathclyde Aerospace Centre of Excellence.
//  ],
  
  subtitle: [
  Supervisor: Louise Crockett \
  //Second Assessor: \ // TODO: Second Asssessor
  Department of Electronic and Electrical Engineering \
  University of Strathclyde, Glasgow
  ],
  
  // date: [your custom date]
  //default is datetime.today().display("[day] [month repr:long] [year]")
  
  // whether to gen a list of figs
  figures: true,
  
  // special space fro the glossary
  glossary: [#print-index(title: "Definitions",sorted:"up")],
  
  // whether to gen the ack at the bottom
  ack: false,

  // compact layeout for assignments, set to false for more "grandeur"
  compact: false
)
// table titles at the top if you like it that way
#show figure.where(
  kind: table
): set figure.caption(position: top)

#set math.equation(numbering: "(1)")

// body

//Abstract
//1. Introduction
//2. Background
//3. ACM Analysis
//4. HDL Implementationsity of Strathclyde to create a 2U CubeSat. It has two payloads aimed at tackling important issues in space sustainability.

// Payloads

= Introduction

== CubeSat Communications
A typical ground station pass is depicted in @cubesat-pass, showing some of the sources of attenuation and interference. These factors are more impactful in the #acr("UHF") amateur satellite allocation, as this band is shared between several satellites, and is adjacent to a license free #acr("ISM") allocation used by devices such as car keys. Due to the small size of CubeSats, high power transmission and large high gain antennas are infeasible which means that the received signal power at the ground station is relatively low and more vulnerable to the effects of interference.

To mitigate these issues, many large satellites requiring high data throughput modify their modulation and coding settings over time, in a process called #acr("VCM"), where this is pre-planned, or #acr("ACM"), where this is based on real time measurements of channel conditions. This allows much higher throughput for a given bandwidth, which is particularly relevant in the constrained amateur allocations.

Although #acr("ACM")/#acr("VCM") has a high performance improvement, there are few examples of CubeSats using these systems in the #acr("UHF") band, due to the high complexity required and the fact that high rate communications are typically conducted in the S band or higher, as higher bandwidths are available. For this reason, any implementation for STRATHcube must be developed using a #acr("SDR") which increases cost and time requirements.

One system for high rate satellite data transmission is #acr("DVB-S2"). Originally designed for the transmission of video data, it has since been expanded to support generic data streams. This system is typically used on high throughput satellites operating on bandwidths of multiple megahertz at frequencies in the tens of gigahertz, for which #acr("ACM") and #acr("VCM") are particularly important due to atmospheric effects. For this reason, the standard includes support for #acr("CCM"), #acr("VCM") and #acr("ACM"). Additionally, it has a highly modular structure allowing it to be adapted for a given application.

#figure(
  image("../Figures/Introduction/pass-cropped.svg",height:30%,),
  caption: "Factors affecting a ground station pass. At (1) the satellite is at a low elevation and, due to its circular orbit, will be at its longest range and the highest attenuation from the atmosphere. When the satellite is directly overhead, (3), the distance is at minimum and the signal strength at maximum. There are also various sources of interference, such as from the Sun and galactic noise, (2), other satellites in the same band, (4), or terrestrial devices, (5). "
) <cubesat-pass>

== STRATHcube
=== Mission Overview
STRATHcube is a student-led 2U CubeSat mission in development at the University of Strathclyde as part of the European Space Agency's #acr("ESA") Fly Your Satellite! and Design Booster programs. The mission addresses critical aspects of space sustainability through its two payloads.

The primary payload involves the demonstration of a #acr("PBR") system for in-orbit space debris detection. This payload operates by measuring the signal power of Iridium satellite transmissions in order to detect the attenuation caused by passing debris. The acquired data requires ground-based processing, necessitating reliable high-speed downlink capabilities. A key operational constraint arises from the substantial volume of data generated during each observation pass. While onboard data compression mitigates this to some extent, the downlink speed remains the limiting factor governing the payload's operational time.

The secondary payload focuses on characterising aerothermal effects during atmospheric re-entry, specifically investigating the conditions leading to solar panel fragmentation. This payload becomes operational in the hours before the demise of the satellite and relies on the Iridium satellite network for data transmission.

 However, this secondary communication channel operates at significantly lower data rates compared to the primary #acr("UHF") system and incurs additional operational costs.

A render of the satellite is shown in @strathcube-render, although this has a slightly outdated model.
#figure(
  image("../Figures/Introduction/strathcube-render.png", width:50%),
  caption: "Render of STRATHcube in re-entry configuration. The dipole antenna for UHF communications is deployed in the center."
) <strathcube-render>

=== Communication Architecture
The primary communication system will operate in the amateur space service #acr("UHF") allocation which spans 3 MHz, from 435 to 438 MHz. The ground station implementation is currently under investigation, with options including the use of the currently non-operational #acr("STAC") or the use of existing ground stations elsewhere. Both uplink and downlink communications will use the onboard TOTEM SDR.

The secondary communication system will communicate through the Iridium satellite constellation, as re-entry may occur outside of the range of any ground station. Additionally, ionisation effects create a communications black out zone that prevents communication from the spacecraft directly to the ground.
=== Mission Phases <mission-phases-section>
The mission timeline comprises four distinct operational phases. The Early Operations and Commissioning Phase begins immediately following deployment from the #acr("ISS") at an initial altitude of approximately 415 kilometers. This critical 10-day period involves antenna deployment, system activation, and establishment of communications with the ground station.

The primary phase occupies the majority of the mission, during which the satellite alternates between #acr("PBR") measurement collection and dedicated downlink periods using the primary #acr("UHF") communication system. This phase continues until the satellite reaches the altitude trigger of 170 kilometers, expected to occur around 180 days post-deployment and initiating the Transition Phase.

During the Transition Phase, the satellite undergoes reconfiguration to prepare for atmospheric re-entry. Finally, the Secondary Phase encompasses the re-entry process itself, where the secondary payload actively records sensor data and transmits available measurements through the Iridium network until communication becomes impossible and the demise of the satellite.

These phases are shown graphically in @strathcube-phases @thomas_mcilwraith_daniel_betoin_cameron_fergus_freya_groves_aidan_bennis_hannah_douglas_sami_rahman_ethan_dyer_louis_galasso_strathcube_2025[fig. 3].

#figure(
  image("../Figures/Introduction/conops_with_background.png"),
  caption:"STRATHcube mission phases. "
) <strathcube-phases>

== Objectives
The project aimed to advance the design of the downlink communications system for STRATHcube while actively contributing to design reviews. Key objectives included:

+ Developing a detailed system design for downlink communications.
+ Building an engineering model of the downlink system using development boards for validation.

Given the complexity of the STRATHcube mission, the project scope was deliberately constrained to prevent "scope-creep". The focus was solely on downlink communications, deferring uplink system design for future work. Further, implementation on hardware was reserved as an optional stretch goal.

To maintain flexibility for later development, the implementation was designed to be modular, preventing unnecessary constraints on subsequent development. This approach ensured that progress could be made efficiently while laying a strong foundation for future enhancements.

= Literature Review <Lit-Review-Section>

#include("lit_review.typ")
= ACM Analysis <ACM-Analysis-Section>
#include("link_budget.typ")
= System Design <System-Design-Section>
#include("system_architecture.typ")

= Implementation <Implementation-Section>
#include("Implementation.typ")

= Implementation and Simulation Results <Results-Section>
#include("results.typ")

= Discussion <Discussion-Section>
// Transmitter spectrum
The transmitter complies to the spectral mask for all tested inputs. This also held true for the DVB-S2 transmitter block when tested in the original example code, ensuring that the observed interfacing issues did not have an effect.

The logic analyser waveform of the AXI-Stream interfacing logic was found to match extremely well to the intended timing diagram, as the measured waveform matches the timing shown in @Parser-Timing clock for clock. Further, the implemented assertion proved that the data field was serialised correctly, as it did not trigger during the simulation. This indicates that further investigation of the original DVB-S2 HDL Coder example design to ensure that the designed system is appropriate.

The resource usage of the implemented design was found to comply with the goal of no more than 50% usage on any one resource, with the exception of Block RAM. High RAM usage is to be expected for a HDL Coder design, as extra buffering is used between blocks. In order to integrate the PBR design with the downlink implementation, this may require further optimisation.

The design was found to meet timing, however this was by fractions of a nanosecond in all cases. The clock period was around 15 ns, so this is an extremely small margin. The clock tolerance settings were left at default, so further analysis will be required to determine if this margin is large enough. The synthesis settings could also be modified to allow the solver to run for more iterations to potentially find a better place and route solution.

With reference to @implemented-design, it is clear that the design is extremely spread out over the chip, meaning long chains of logic, which likely impacted timing closure. Therefore, optimisation of the Block RAM usage might also improve the timing of the design, allowing higher clock rates to be used.

== Further Work
The work on the downlink communications has several avenues for further development. The first priority, is to fix the interfacing issues with the transmitter block. Another avenue for work is testing the design in hardware using development boards. This is expected to take some time to complete, as the AXI packet handling code has not been fully verified to ensure compliance to the protocol. The packet handling systems could also be worked upon, with the investigation of the ACM routing being of particular importance.

Once the system is operational, the addition of DVB-S2X features could be of interest. The #acr("VL-SNR") features could improve system performance considerably at low elevations. The impact of interference is also yet to be analysed in the context of the STRATHcube mission, which may necessitate the link budget to be reassessed.

As part of the ESA Baseline Design Review, several work packages were created that are relevant to the future of this project. They include interference analysis of the ground station site and creation of a receiver for the downlink communications. These are detailed in Appendix B.

An extended abstract regarding the work completed so far has been created and submitted to the European Data Handling & Data Processing Conference for consideration, as shown in Appendix B. If accepted, further development on hardware implementation and packet handling will be conducted as part of that work.

= Conclusion
The development of the downlink communications system has now been significantly furthered over the course of this project. A detailed review of CubeSat communications and the context of the STRATHcube mission was conducted to ensure that the design was feasible, and to identify design requirements. One of the main requirements identified was the maximisation of data transmitted over the mission, to allow the thorough testing of the primary payload.

ACM was analysed with this context to identify the possible performance uplift over the course of the mission. MATLAB code was created for this analysis and integrated into internal tools. The investigation found that ACM offered significant benefits and that it was worth the extra system complexity.

A system architecture was then defined, with all key blocks for packet handling detailed and relevant tools and standards identified. An initial implementation of the transmitter system was created, with further work required on interfacing for the design to be fully functional. Initial code was developed for a GSE implementation, with further work required.



#pagebreak()
#show bibliography: set heading(numbering: "1")
#bibliography((
    "../Bibliographies/Link-Budget.bib",
    "../Bibliographies/DVB-S2.bib",
    "../Bibliographies/Hardware.bib",
    "../Bibliographies/Implementation.bib",
    "../Bibliographies/Packets.bib",
    "../Bibliographies/STRATHcube.bib"
  ))

#pagebreak()
#let appendix(body) = {
  set heading(numbering: numbly(
  "Appendix {1:A}:", // use {level:format} to specify the format
  "{1:A}.{2}.", // if format is not specified, arabic numbers will be used, supplement: [Appendix])
  "{1:A}.{2}.{3}", // if format is not specified, arabic numbers will be used, supplement: [Appendix])
  ))
  counter(heading).update(0)
  body
}

#show: appendix


#include("code-listings.typ")

#pagebreak()
#set page(flipped: true)
= Work Packages <Work-packages>

== TTC
#set text(size: 6pt)
#let ttc-wp=csv("../Figures/Appendices/WP-Breakdown(TTC).csv")

#table(
                      columns:12,
                      align:(left),
                      table.header(
                        [*Code*],[*Domain*],[*Title*],[*Responsible*],[*Duration*],[*Deliverables*],[*Prerequisites*],[*Description*],[*Required Resources/Facilities*],[*Predecessor WPs*],[*Successor WPs*],[*Completeness*]
                      ),
                      ..ttc-wp.slice(1).flatten(),
                    )

#pagebreak()

#set text(lang: "en", size: 12pt)
== Ground Station

#set text(size: 6pt)
#let gs-wp=csv("../Figures/Appendices/WP-Breakdown-GS.csv")

#table(
                      columns:12,
                      align:(left),
                      table.header(
                        [*Code*],[*Domain*],[*Title*],[*Responsible*],[*Duration*],[*Deliverables*],[*Prerequisites*],[*Description*],[*Required Resources/Facilities*],[*Predecessor WPs*],[*Successor WPs*],[*Completeness*]
                      ),
                      ..gs-wp.slice(1).flatten(),
                    )


#pagebreak()
#set page(flipped: false)
#set text(lang: "en", size: 12pt)

= Extended Abstract Submitted to European Data Handling & Data Processing Conference 