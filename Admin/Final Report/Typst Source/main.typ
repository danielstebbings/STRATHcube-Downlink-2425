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
  "VCM": "Variable Coding and Modulation"
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
  I confirm and declare that this report and the project work is entirely the product of my own effort and I have not used or presented the work of others herein without acknowledgment
  ],

  abstract: [
   
  ],
  
  subtitle: [
  Supervised by Louise Crockett \
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
//4. HDL Implementation
//Appendices




= Introduction
//Todo: Delete this!
//#show: word-count
//#total-words
= Literature Review


#include("lit_review.typ")
= ACM Analysis
#include("link_budget.typ")
= System Architecture


= Implementation
== Transmitter
#include("transmitter.typ")
== Packet Handling
= Results
= Discussion
= Conclusion
== Further Work

/*= Code listings

#figure(sourcecode[```C
example_c_code() =
example_c_code() = 
example_c_code() = 
example_c_code() = 
example_c_code() = 
```], caption: [code listing])
*/

#show bibliography: set heading(numbering: "1")
#bibliography(("../Bibliographies/Link-Budget.bib","../Bibliographies/DVB-S2.bib","../Bibliographies/Hardware.bib"))

