#import "template.typ": *
#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/acrostiche:0.5.1": *
#import "@preview/wordometer:0.1.4" : word-count, total-words
#import "@preview/subpar:0.2.1"


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
))


// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
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
    Efficient downlink of recorded telemetry is a critical challenge in CubeSat missions, constrained by power limitations, bandwidth restrictions, and dynamic CM) must be used. Digital Video Broadcasting – Satellite Second Generation (DVB-S2) is one such ACM system, with near Shannon limit performance and a modular standard allowing it to be matched to the use case. Despite this, there are no space rated UHF DVB-S2 transmitters currently on the market which necessitates its implementation on a Software Defined Radio (SDR). While integrating an SDR can be costly and complex for many missions, the design of STRATHcube already includes one, minimising additional expenses.  

    STRATHcube is a student led 2U CubeSat mission at the University of Strathclyde, the primary payload being a technology demonstrator of a Passive Bistatic Radar (PBR) using an SDR and communicating in the UHF band. Consequently, there will already be a powerful System on Chip (SoC) Field Programmable Gate Array (FPGA) based SDR included on the mission allowing a DVB-S2 transmitter to be implemented as a piggy-back on the primary payload using spare resources.  

    This paper outlines the downlink system design for STRATHcube. Performance and link analyses were conducted, analysing communication windows over the course of the mission and expected theoretical performance. The design was implemented in hardware using MathWorks HDL Coder and work began on a Generic Stream Encapsulation (GSE) implementation using C++.

    Initial performance analysis was conducted in comparison to a typical system which uses Constant Coding and Modulation (CCM) and optimises for maximum availability and shows a significant uplift in data throughput over the course of the mission. 

    Additionally, resource analysis of the target FPGA SoC and the synthesised design show that the implementation is realisable in hardware.
  ],
  
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
  glossary: [#print-index(title: "Definitions")],
  
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
Efficient downlink of recorded telemetry is a critical challenge in CubeSat missions as they are constrained by power limitations, bandwidth restrictions, and dynamic channel conditions imposed during a ground station pass. Further, many CubeSats use the Ultra High Frequency (UHF) amateur band which introduces the further issue of in-band interference which cannot be accounted for in advance.

To mitigate these issues, many satellites designed for high throughput modify their modulation and coding settings over time, in a process called #acr("VCM"), where this is pre-planned, or #acr("ACM"), where this is based on real time measurements of channel conditions. This allows much higher throughput for a given bandwidth, which is key in the bandwidth constrained amateur allocations.

#acr("DVB-S2") is a system designed for high throughput satellite data transmission which includes support for #acr("CCM"), #acr("VCM") and #acr("ACM") and has a highly modular structure allowing it to be adapted for a given application. 

Although #acr("ACM")/#acr("VCM") has a high performance improvement, there are few examples of satellites using these systems in the #acr("UHF") band, due to the high complexity required and the fact that high rate communications are typically conducted in the S band. For this reason, any implementations must be created using #acr("SDR") which increase cost.

== STRATHcube
=== Mission Overview
STRATHcube is a student-led 2U CubeSat mission developed at the University of Strathclyde as part of the European Space Agency's #acr("ESA") Fly Your Satellite! and Design Booster programs. The mission addresses critical aspects of space sustainability through two distinct payloads.

The primary payload involves the demonstration of a #acr("PBR") system for in-orbit space debris detection. This payload operates by measuring signal power attenuation caused by debris passing between an Iridium communication satellite (acting as an external transmitter) and STRATHcube's receiver. The acquired data requires ground-based processing, necessitating reliable high-speed downlink capabilities. A key operational constraint arises from the substantial volume of data generated during each observation pass. While onboard data compression mitigates this to some extent, the downlink speed remains the limiting factor governing the payload's operational time.

The secondary payload focuses on characterizing aerothermal effects during atmospheric re-entry, specifically investigating solar panel fragmentation mechanisms. This payload becomes operational during the terminal mission phase and relies on the Iridium satellite network for data transmission, as re-entry may occur beyond ground station coverage. However, this secondary communication channel operates at significantly lower data rates compared to the primary #acr("UHF") system and incurs additional operational costs.

=== Communication Systems Architecture
STRATHcube incorporates two independent communication systems. The primary system utilizes the #acr("UHF") band for high-rate data transmission directly to ground stations, supporting the bulk of mission operations. 

 The secondary system employs the Iridium network for use during the secondary payload operations, where ground station contact cannot be guaranteed.

=== Mission Phases
The mission timeline comprises four distinct operational phases. The Early Operations and Commissioning Phase begins immediately following deployment from the #acr("ISS") at an initial altitude of approximately 415 kilometers. This critical 10-day period involves antenna deployment, system activation, and initial communications establishment.

The Nominal Operations Phase represents the mission's primary duration, during which the satellite alternates between #acr("PBR") measurement collection and dedicated downlink sessions using the primary #acr("UHF") communication system. This phase continues until the satellite reaches the altitude trigger of 170 kilometers, typically occurring around 180 days post-deployment and initiating the Transition Phase.

During the Transition Phase, the satellite undergoes reconfiguration to prepare for atmospheric re-entry. Finally, the Secondary Phase encompasses the re-entry process itself, where the secondary payload actively records sensor data and transmits available measurements through the Iridium network until communication becomes impossible.

== Objectives
The project aimed to advance the design of the downlink communications system for STRATHcube while actively contributing to design reviews. Key objectives included:

+ Developing a detailed system design for downlink communications.
+ Building an engineering model of the downlink system using development boards for validation.

Given the complexity of the STRATHcube mission, the project scope was deliberately constrained to ensure feasibility. The focus was solely on downlink communications, deferring uplink system design for future work. Further, implementation on hardware was reserved as an optional stretch goal.

To maintain flexibility for later development, the implementation was designed to be modular, preventing unnecessary constraints on subsequent phases. This approach ensured that progress could be made efficiently while laying a strong foundation for future enhancements.

= Literature Review

#include("lit_review.typ")
= ACM Analysis
#include("link_budget.typ")
= System Design
#include("system_architecture.typ")

= Implementation
#include("Implementation.typ")

= Results
#include("results.typ")

= Discussion
= Conclusion
== Further Work
// DVB-S2X - VL-SNR features

/*= Code listings

#figure(sourcecode[```C
example_c_code() =
example_c_code() = 
example_c_code() = 
example_c_code() = 
example_c_code() = 
```], caption: [code listing])
*/

#pagebreak()
#show bibliography: set heading(numbering: "1")
#bibliography(("../Bibliographies/Link-Budget.bib","../Bibliographies/DVB-S2.bib","../Bibliographies/Hardware.bib"))

