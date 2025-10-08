#import "@preview/charged-ieee:0.1.4": ieee

// Acronyms
#import "@preview/acrostiche:0.5.1": *

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
  "FSPL": "Free Space Path Loss",
))


#show: ieee.with(
  title: [Analysis and Implementation of DVB-S2 in the UHF Band for STRATHcube Downlink Communications ],
  abstract: [
    // clarity on the CCM system also being DVB-S2 
    This paper outlines the downlink system design for STRATHcube. Performance and link analyses were conducted, analysing communication windows over the course of the mission and expected theoretical performance. The design was implemented in hardware using MathWorks HDL Coder and C++ code developed for packet handling in software.  

    Initial performance analysis was conducted in comparison to a typical system which uses Constant Coding and Modulation (CCM) and optimises for maximum availability, showing a significant uplift in data throughput over the course of the mission. Additionally, resource analysis of the target FPGA SoC and the implemented design, as well as timing analysis show that the system will be implementable in hardware.
  ],
  authors: (
    (
      name: "Daniel Stebbings",
      department: [Department of Electronic and Electrical Engineering],
      organization: [University of Strathclyde],
      location: [Glasgow, UK],
      email: "danielastebbings@gmail.com"
    ),
    (
      name: "Dr Louise Crockett",
      department: [Department of Electronic and Electrical Engineering],
      organization: [University of Strathclyde],
      location: [Glasgow, UK],
      email: "louise.crockett@strath.ac.uk"
    ),
    (
      name: "Prof. Carmine Clemente",
      department: [Department of Electronic and Electrical Engineering],
      organization: [University of Strathclyde],
      location: [Glasgow, UK],
      email: "carmine.clemente@strath.ac.uk"
    ),
    (
      name: "Prof. Massimiliano Vasile",
      department: [Department of Mechanical and Aerospace Engineering],
      organization: [University of Strathclyde],
      location: [Glasgow, UK],
      email: "massimiliano.vasile@strath.ac.uk"
    ),

  ),
  index-terms: ("CubeSat", "Communications", "DVB-S2", "Software Defined Radio"),
  bibliography: bibliography((
    "./Bibliographies/Link-Budget.bib",
    "./Bibliographies/DVB-S2.bib",
    "./Bibliographies/Hardware.bib",
    "./Bibliographies/Implementation.bib",
    "./Bibliographies/Packets.bib",
    "./Bibliographies/STRATHcube.bib"
  )),
  figure-supplement: [Fig.],
)

= Introduction

== CubeSat Communications

Efficient downlink of data is a critical challenge in CubeSat missions, as they are highly constrained in power, bandwidth, and by dynamic channel conditions imposed during a ground station pass. These issues are further exacerbated in the commonly used #acr("UHF") amateur allocation due to in band interference and further bandwidth constraints.

There are several dynamic factors inherit in satellite to ground communications, including pointing losses, total slant range and scintillation effects. Some of these factors can be predicted, however others such as interference, are transient and have an outsized impact on error rates. For this reason systems with #acr("ACM") can improve link availability and spectral efficiency compared to #acr("CCM") or those that change but do not adapt, #acr("VCM"), however this does come at the cost of increased complexity.

#acr("DVB-S2") is one such #acr("ACM") system, with near Shannon limit performance and a modular standard allowing it to be matched to the usecase. Despite this, it has not seen common use in the #acr("UHF") band for CubeSats as it typically requires complex and expensive #acr("SDR") based hardware with higher power draw. However, STRATHcube will already include such hardware for its primary payload, presenting an opportunity for increased downlink capability for minimal added cost.   

In @grayver_software_2015 a design for an Zynq 7020 #acr("FPGA") #acr("SoC") SDR based communication system in
the 915 MHz UHF band leveraging ACM is presented. The
system used similar modulation to DVB-S2, with a different
coding method. Their analysis showed an almost doubling in throughput compared to CCM. This proved that ACM systems
for CubeSats are feasible and could offer large performance benefits. The presented system is found to have a notably high power consumption during transmission, however it is argued that this is offset by the notably higher data throughput and the short length of ground station passes.

== The STRATHcube Mission

STRATHcube is a 2U CubeSat in development at the University of Strathclyde and part of the _ESA Fly Your Satellite! Design Booster_ program. It has two payloads, each targeting a key area of space sustainability.

The primary payload is a technology demonstrator of a Passive Bistatic Radar (PBR) for the detection of space debris using an SDR. The satellite will record IQ data for analysis on the ground, although compressed, the downlink datarate will be one of the primary bottlenecks for its operation. Consequently, there will already be a powerful Field Programmable Gate Array (FPGA) based SDR included on the mission allowing a DVB-S2 transmitter to be implemented as a "piggy-back" on the primary payload using spare resources.  

The secondary payload aims to measure the aerothermal effects leading to solar panel fragmentation  by recording and transmitting sensor data during the moments up to re-entry. This is unlikely to occur near a ground station and instead a secondary transceiver is to be used that communicates via the Iridium network.

The #acr("STAC") based at the University of Strathclyde is the current planned ground station for the mission. It is equipped with two circularly polarised #acr("UHF") antennas from M#super("2") Antenna Systems Inc @m2_antenna_systems_inc_436cp30_2017, an SP-7000 pre-amplifier from SSB Electronic and an Ettus Research B210 #acr("SDR") for reception. The station has been out of use for some time, so rated performance values may not match the current state of the hardware.

== Mission Phases

The mission shall be split into four distinct operational phases that drive the requirements for the downlink communications. The satellite is planned to be deployed from the #acr("ISS").

+ Early Operations and Commissioning (~10 days): Deployment from the #acr("ISS") and system activation.
+ Primary Operations (~170 days): Alternating PBR measurements and data downlink during ground station windows until altitude trigger (~170km)
+ Transition Phase: Reconfiguration for re-entry. Involves transition to communications primarily via Iridium network.
+ Secondary Phase: Re-entry data collection and downlink until demise.

The #acr("UHF") downlink communications will occur during the first three phases, driving subsequent analysis. 

== Objectives

This work focused on the development of STRATHcube's downlink communications system design, with objectives to:
+ Develop detailed downlink system design
+ Develop an engineering model targeting development boards

The scope was limited to exclude the uplink design, with deployment onto hardware as an optional goal. Due to this, the system was designed to be modular to facilitate future development.

= Adaptive Coding and Modulation Analysis

== Link Budget Analysis

A new link budget was created to identify the received #acr("SNR") at each time step during the pass. Parameters were divided into static, those that would not change during a pass, and dynamic, those that would, as shown by @tab:static_link_params and @tab:dynamic_link_params.

#figure(
  table(
    columns: (auto,auto,auto),

    align: (left,center, center),
    table.header(
      [*Name*],[*Value*],[*Source*]
    ),
    table.cell(colspan: 3, align(center,strong("System"))),
    [Frequency ($f$)],[437 MHz],[Centre of UHF Amateur Satellite Service Allocation],
    [Bandwidth ($B$)],[25 kHz],[],
    [Target Margin], [3 dB],[],

    table.cell(colspan: 3, align(center,strong("STRATHCube"))),
    [Transmit Power ($P_"Tx"$)],                  [$1 "W"$ ($0 "dBW"$)],        [TOTEM UHF FE Limit, @alen_space_frontenduhf_2021],
    [Cable Losses ($L_"Cable"$)],                 [$0.116 "dB"$],   [20cm RG-188/AU], // Big margin, AcubeSAT calc
    [Antenna VSWR],                               [$1.9:1$],        [ISIS Antenna Datasheet @isispace_cubesat_nodate],// ISIS ant datasheet
    [Antenna Matching Loss ($L_"Matching"$)],     [$0.44 "dB"$],    [@eq:Reflection_Loss], 
    [Connector Losses ($L_"Connector"$)],         [$0.2 "dB"$],     [4 Connectors \@ 0.05dB, Estimation],
    [Switch Losses ($L_"Switch"$)],               [$0.5 "dB"$],     [Estimation], //AcubeSAT, unsure if real
    [Transmit Antenna Gain ($G_"Tx"$)],           [$0 "dBi"$],      [ISIS Antenna Datasheet @isispace_cubesat_nodate],
    [*#acr("EIRP")*],                                     [*$-1.26 "dBW"$*],[@eq:EIRP],

    table.cell(colspan: 3, align(center,strong("Ground Station"))),
    [Receive Antenna Gain ($G_"Rx"$)], [$15.5 "dBic"$], [STAC UHF Antenna @m2_antenna_systems_inc_436cp30_2017],
    [Polarisation Loss ($L_"Pol"$)],          [$3    "dB"$],   [Linear to circular],
    [Pointing Loss ($L_"Point"$)],            [$1    "dB"$],   [Estimation],
    [Preamplifier Gain ($G_"Preamp"$)],       [$20   "dB"$],   [SP-7000 Datasheet @ssb_sp-7000_2012 ],
    [Preamplifier Noise Figure ($F_"Preamp"$)], [$0.9   "dB"$],   [SP-7000 Datasheet @ssb_sp-7000_2012 ],
    [Line Losses],                          [$5.47 "dB"$],   [36m of RG213], 
    [Receive SDR Noise Figure ($F_"SDR"$)], [$8    "dB"$],   [Ettus Research B210 Datasheet @ettus_research_b210_nodate],
    [Terrestrial Noise Figure ($F_"T"$)],        [$6    "dB rel. "k T_0 B$],   [Outdoor manmade noise in city at 425 MHz @noauthor_radio_2016[Tab. 3]],
    [Terrestrial Noise Power ($P_"T"$)],[$-154.0 "dBW"$], [@eq:noise_power],
  ),
  caption: "Static Link Parameters"
) <tab:static_link_params>

#figure(
  table(
    columns: (auto,auto,auto),

    align: (left,center, center),
    table.header(
      [*Name*],             [*Values*], [*Source*]
    ),
    [Elevation],            [$10° "to" 40°$], [10° threshold to be counted as pass, 40° max elevation found through simulation ],
    [Altitude],             [$170 "km" "to" 425 "km" $], [Deployment altitude from ISS to transition altitude trigger],
    [Slant Range (SR)],     [$260 "km" "(40° @ 170km)" \  "to" \ 1505 "km" "(10° @ 425km)"  $], [MATLAB function @mathworks_matlab_nodate],
    [#acr("FSPL")], [$133.5 "dB" "(260km)" \ "to" \ 148.8  "dB" "(1550km)"  $],[@eq:FSPL],
    [Atmospheric Losses (AL)],   [$0.074 "dB" "(40°)" \ "to" \ 0.318 "dB" "(10°)"    $], [Includes gaseous, scintillation, cloud and rain losses. Calculated using ITU-Rpy @portillo_itu-rpy_2017],
  ),
  caption: "Dynamic Link Parameters"
) <tab:dynamic_link_params>


$ Γ   = ("VSWR"-1) / ("VSWR"+1)  $
$ L_"Matching,dB"  = 10  log_10 (1- Γ^2) ["dB"] $ <eq:Reflection_Loss>


$ "EIRP"_"dB" =  10 log_10 (P_"Tx,W") - L_"Line,dB" - L_"Switch,dB" 
#linebreak()
- L_"Match,dB" + G_"Tx,dB" ["dBW"] $ <eq:EIRP>


$ "P"_"T,dB" = F_"T" + 10 log_10 (k  T_0  B) $ <eq:noise_power>

Free Space Path Loss: @sklar_digital_2009[eq. 5.10]
$ "FSPL" = 20 log_10 ((4 pi d f)/ (c)) ["dB"] $ <eq:FSPL>

Where $k = 1.38 times 10^(-23) "J/K"$ is the Boltzmann constant and $T_0 = 290 "K"$ is the reference temperature.

The final received signal power can be calculated the #acr("EIRP") less all losses and the received noise power as the terrestrial noise power with amplification from the preamp and including the noise figure of each element of the receive chain.

$ P_"Rx,dB" = "EIRP"_"dB" - "FSPL"_"dB" - "AL"_"dB" - L_"Pol,dB"  
          #linebreak()
           -L_"Point,dB" + G_"Rx,dB" + G_"Preamp,dB" 
           #linebreak()
           - L_"Line,dB" ["dBW"] $

$ P_"N,dB" = P_"T,dB" + G_"Preamp,dB" + F_"Preamp,dB" 
              #linebreak()
              + F_"SDR,dB" ["dBW"] $

Therefore the #acr("SNR") of the received signal is simply:

$ "SNR" = P_"Rx,dB" - P_"N,dB" ["dB"] $

#acr("DVB-S2") uses #acr("APSK") modulation, from QPSK to 32APSK and coding rates from 1/4 to 9/10. Further modulation and coding options were added with DVB-S2X to support an even wider SNR range, although these were not considered during this investigation. Additionally, there are two options for the frame length, Normal and short, and pilots can be optionally inserted to improve receiver performance. 

The minimum #acr("SNR") required was taken from @etsi_en_2014[Tab. 13] which assumed a normal frame length, no pilots, 50 #acr("LDPC") decoding iterations, perfect carrier and synchronisation recovery, no phase noise, and an #acr("AWGN").

Interference is likely to be present in this band due to amateur radio users, spurious emissions and other sources. Further,  phase noise will likely be induced due to multipath and atmospheric effects. The calculated margin will therefore be optimistic compared to the practical system. To offset this, when calculating data rate the spectral efficiency for a system with pilots was used from @ccsds_ccsds_2023. 

The link budget and margin for an adverse and a favourable scenario is shown in @tab:budget with the optimal modulation and coding rate selected to meet the 3dB margin requirement. The data rate was calculated directly from the spectral efficiency and bandwidth using @eq:spect_eff_2_cap.

$ "Data Rate" = #sym.eta times B ["bps"] $ <eq:spect_eff_2_cap>

#figure(
  table(
    columns: 3,
    inset: 6pt,
    align: (horizon,horizon,horizon), 
    table.header(
      [*Parameter*],[*Adverse*],[*Favourable*],
    ),

    [Elevation],  [$10 #sym.degree$],[$40 #sym.degree$], 
    [Altitude],   [$425 "km"$],      [$170 "km"$],
    [Noise Power],table.cell(colspan: 2, align(center,$-125.1 "dBW"$)),
    [Signal Power],[$-123.2 "dBW"$],[$-107.7 "dBW"$],
    [SNR],        [$1.9 "dB"$],      [$17.4 "dB"$],
    [Optimal Modulation and Coding Rate], [$"QPSK" 1/3$],[$"32APSK" 5/6$],
    [Required SNR], [$-1.24 "dB"$],[$14.28 "dB"$],
    [Margin],       [$3.14 "dB"$],[$3.12 "dB"$],
    [Spectral Efficiency],        [$0.6408$], [$4.0306$],
    [Data Rate],  [$16.020 "kb/s"$], [$100.76 "kb/s"$]
  ),
  caption: "Link Budget" 
) <tab:budget>

== Adaptive vs Constant 

Proof-of-concept analysis was conducted to assess if the performance gains offered by #acr("ACM") justify the increased complexity. A simulation of the orbit was used to identify the elevation angle and satellite altitude during pass opportunities over the #acr("STAC") for the full duration of the mission. 

Due to the location of the ground station, the observed elevations did not rise above 40#sym.degree, greatly reducing the overall data throughput, as the higher order modulations were seldom reached. 

#figure(
  image("FIgures/Altitude_vs_time.svg"),
  caption:"STRATHcube altitude from deployment to mode transition."
)<img:alt_vs_time>

#figure(
  image("FIgures/Elevation_Time.svg"),
  caption:"STRATHcube pass elevation histogram."
)<img:elev_times>

#figure(
  image("FIgures/elevation_vs_modcod.svg"),
  caption: "Optimal MODulation and CODing rate by elevation and altitude."

)<img:elev2modcod>

@tab:total_data shows the total data downlinked by each strategy. The adaptive system was able 3.19#sym.times the amount of data versus the constant system, indicating that the increased system complexity is outweighed by the improved performance.  

#figure(
  table(
    columns: 2,
    inset: 6pt,
    align: (horizon,horizon), 
    table.header(
      [*Strategy*],[*Total Data Downlinked (Gb) *]
    ),
    [Constant],[1.88],
    [Adaptive],[6.01]
  ),
  caption: "Total Data Downlinked by Strategy"
) <tab:total_data>

== Areas for Further Investigation

// TODO: ROLLOFF
The link budget presented was developed to show viability of an adaptive DVB-S2 system, as such there was comparatively less investigation of the ground station receiver system. The implementation of the receiver will be challenging, and require further investigation of the in band interference present at the site. Additionally, the bandwidth calculations did not account for filter roll-off, this is discussed further in.

= Transmitter Design and Implementation