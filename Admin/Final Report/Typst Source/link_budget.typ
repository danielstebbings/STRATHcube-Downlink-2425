  #set math.equation(numbering: "(1)")
  #set text(lang: "gb", size: 12pt)
  #show figure: set block(breakable: true)

= Link Budget
// Acronym Reference
Much of the background research for this link budget was done by a previous student , identifying the AcubeSAT link budget @amarantidou_acubesat_2020 as a key source of information.
The link budget was then reassessed and updated to identify varying parameters and to reflect the impact of DVB-S2 and ACM. It has also been updated to reflect the information obtained regarding the STAC ground station @calum_clarke_group_2016. The current operation of the STAC is unknown, as such component values and performance figures are to be confirmed.
//== DVB-S2 Modulation and Coding Rate Requirements
#let results=csv("../Figures/modvals.csv")

#let result_fig = figure(
  table(
    columns:7,
    align:(center),
    table.header(
      [*Bits / Symbol*],[*Mod-ulation*],[*Coding Rate*],[*Spectral Efficiency (bps/Hz)*],[*Data Rate (bps)*],
      [*Minimum CNR (dB)*],[*Minimum CNR w. 10dB Margin (dB)*]
    ),
    ..results.slice(1).flatten(),
  ),
  caption:"DVB-S2 Modulation and Coding Rate Requirements, 150kHz Bandwidth, "

)
== System Definitions <System-Definitions>

#figure(
  table(
    columns: (auto,auto,auto),
    inset: 6pt,
    align: (left,center, center),
    table.header(
      [*Name*],[*Value*],[*Source*]
    ),
    table.cell(colspan: 3, align(center,strong("System"))),
    [Frequency ($f$)],[437 MHz],[Centre of UHF Amateur Satellite Service Allocation],
    [Bandwidth ($B$)],[150 kHz],[],

    table.cell(colspan: 3, align(center,strong("STRATHCube"))),
    [Transmit Power ($P_"Tx"$)],                  [$0 "W"$],        [TOTEM UHF FE Limit, @alen_space_frontenduhf_2021],
    [Cable Losses ($L_"Cable"$)],                 [$0.116 "dB"$],   [20cm RG-188/AU, AcubeSAT], // Big margin, AcubeSAT calc
    [VSWR],                                       [$1.9:1$],        [ISIS Antenna Datasheet @isispace_cubesat_nodate],// ISIS ant datasheet
    [Antenna Reflection Loss ($L_"Reflection"$)], [$0.44 "dB"$],    [@Reflection_Loss, AcubeSAT], // AcubeSAT link budget calculator
    [Connector Losses ($L_"Connector"$)],         [$0.2 "dB"$],     [4 Connectors \@ 0.05dB, AcubeSAT],
    [Switch Losses ($L_"Switch"$)],               [$0.5 "dB"$],     [AcubeSAT, included specutalively], //AcubeSAT, unsure if real
    [Total Line Losses ($L_"Line"$)],             [$1.26 "dB"$],    [@Line_Loss],
    [Transmit Antenna Gain ($G_"Tx"$)],           [$0 "dBi"$],      [ISIS Antenna Datasheet @isispace_cubesat_nodate],
    [*EIRP*],                                     [*$0.50 "dBW"$*], [@EIRP], 

    table.cell(colspan: 3, align(center,strong("Ground Station"))),
    [*Receive Antenna Gain ($G_"Rx"$)*], [*$14.15 "dBi"$*], [STAC UHF Antenna @calum_clarke_group_2016], 
    [LNA Gain ($G_"LNA"$)],              [$20   "dB"$],     [SP-7000 Datasheet, STAC @ssb_sp-7000_2012 ],
    [Line Losses],                       [$2.39 "dB"$],     [AcubeSAT],

    table.cell(colspan: 3, align(center,strong("Ground Station Noise Temperature"))),
    [Reference ($T_"Ref"$)],                      [$290 "K"$],      [Standard Value, @sklar_digital_2009[Sec. 5.5.2]], // Sklar Ref
    [Antenna / Sky ($T_"Ant"$)],                  [$154 "K"$],      [AcubeSAT],
    [Feedline ($T_"Feed"$)],                      [$290 "K"$],      [AcubeSAT],
    [LNA Noise Figure ($N_"LNA"$)],               [$0.9 "dB"$],     [SP-7000 Datasheet @ssb_sp-7000_2012, STAC], 
    [LNA ($T_"LNA"$)],                            [$66.8 "K"$],     [@Fig2Temp], //
    [Frontend Noise Figure],                      [$8 "dB"$],       [USRP B210 Maximum @ettus_research_b210_nodate],
    [Frontend ($T_"FE"$)],                        [$1539.8 "K"$],   [@Fig2Temp],
    [Cable Loss ($L_"Cable"$)],                   [$1.023 "dB"$],   [AcubeSAT], //super high? Like 10m of cable
    [Transmission Line Coefficient (#sym.alpha)], [$0.6331$],       [AcubeSAT], //acube 
    [*Receiver Noise Temperature ($T_"Rx"$)*],    [*$282.7 "K"$*],  [@Receiver_Noise_Temp],
 
    table.cell(colspan: 3, align(center,strong("Atmospheric Path Losses"))),
    [Scintillation ($L_"Scint,dB"$)], [$0.16 "dB"$],  [AcubeSAT],
    [Rain Fade ($L_"Rain,dB"$)],      [$0 "dB"$],     [Assumed as negligible in UHF],
    [Ionospheric ($L_"Ion,dB"$)],     [$0.4 "dB"$],   [AcubeSAT],
    [Polarisation ($L_"Pol,dB"$)],    [$3 "dB"$],     [],
    [*AEL*],                         [*$3.56 "dB"$*], [@Atmospheric_Effect_Loss],


  ),
  caption: "Static Parameters"
  // Citation Preben for all above!
)

#figure(
  table(
    columns: 5,
    inset: 6pt,
    align: (horizon,horizon,horizon,horizon,horizon), 
    table.header(
      [*Name*],[*Adverse*],[*Nominal*],[*Favourable*],[*Source(s)*]
    ),
    //[Pointing Loss],[ (90 #sym.degree error)],[3dB (30 #sym.degree error)],[0dB (10 #sym.degree error)],
    [Elevation], [$10 #sym.degree$],[$20 #sym.degree$ ],[$40 #sym.degree$],[@ACM-Analysis], //TODO: Updated elevation histogram for evidence
    [Atmospheric Absorption ($L_"Atm"$)],[2.1 dB],[1.1 dB], [0.4 dB],[AcubeSAT],
    [Slant Range],  table.cell(colspan: 3, align(center,"Calculated / Scenario")),[@Atmospheric_Path_Loss],
    [FSPL],         table.cell(colspan: 3, align(center,"Calculated / Scenario")),[@FSPL],
    [CNR],          table.cell(colspan: 3, align(center,"Calculated / Scenario")),[@CNR],
    [CNR Margin],   table.cell(colspan: 3, align(center,"Calculated / Scenario")),[@Margin],
  ),
  caption: "Dynamic Parameters"
)



== Methodology
=== Link Budget <Link-Budget-Equations> 
Reflection loss can be calculated as follows: @amarantidou_acubesat_2020
$ L_"Reflection,W"   = P_"Tx,W" times ("VSWR"-1)^2 / ("VSWR"+1)^2 ["W"] #linebreak()
  L_"Reflection,dB"  = 10 times log_10 ((P_"Tx,W" - L_"Reflection,W")/ P_"Tx,W") ["dB"] $ <Reflection_Loss>

The Transmitter total line losses are calculated as follows:
$ L_"Line,dB" = L_"Cable,dB"+L_"Reflection,dB" + L_"Connectors,dB" + L_"Switch,dB" ["dB"] $ <Line_Loss>
EIRP:
$ "EIRP"_"dB" =  10 times log_10 (P_"Tx,W") - L_"Line,dB" + G_"Tx,dB" ["dBW"] $ <EIRP>

Receiver noise temperature: @amarantidou_acubesat_2020
$ T_"Rx" = #sym.alpha times T_"Ant" + (1 - #sym.alpha) times T_"Feed" + (T_"FE" times L_"Cable") / (G_"LNA") [K] $ <Receiver_Noise_Temp>
Noise figure can be converted to noise temperature as follows: @sklar_digital_2009[eq. 5.28]
$ T = T_"Ref" ( 10^(F_"dB" / 10) -1 ) $ <Fig2Temp>

Atmospheric Effect Loss and Atmospheric Path Loss:
$ "AEL"_"dB" = L_"Scint,dB" + L_"Rain,dB" + L_"Ion,dB" + L_"Pol,dB" ["dB"] $ <Atmospheric_Effect_Loss>
$ "APL"_"dB" = "AEL"_"dB" + L_"Atm,dB" ["dB"] $ <Atmospheric_Path_Loss>

Slant Range: @mathworks_matlab_nodate 
$ "SR" = sqrt(R^2 + (R+H)^2 - 2 times R times (R+H) times cos(#sym.theta)) \
  "Where": \
  R = "Earth Radius" + "Ground Station Altitude" \
  H = "Satellite Altitude" - "Ground Station Altitude" \
  #sym.alpha = "Satellite Elevation Angle" \ 
  #sym.theta = arccos( (R - R sin^2(#sym.alpha) + sin(#sym.alpha) sqrt((R sin(#sym.alpha))^2 + H^2 + 2 R H)) / (R + H))
   $ <Slant_Range> 

Free Space Path Loss: @sklar_digital_2009[eq. 5.10]
$ "FSPL" = 20 log_10 ((4 pi d f)/ (c)) ["dB"] $ <FSPL>
Received CNR:
$ "CNR"_"Rx"  = "EIRP" - "FSPL" - "APL" + G_"Rx" + 228.6 - 10log_10 (T_"Rx") - 10log_10 (B) ["dB"] $ <CNR>
Link Margin:
$ "Margin" = "CNR"_"Rx" - "CNR"_"Required" ["dB"] $ <Margin>



=== Required CNR by Modulation and Coding Rate <Req-CNR>
Values for spectral efficiency and minimum $E_s / N_0$ are provided in @etsi_en_2014[Tab. 13]. Those values are derived from simulation of a DVB-S2 system with 50 LDPC decoding iterations, 64,800 bit FECFRAME, no pilots, perfect carrier and synchronization recovery, no phase noise and an AWGN channel. The system shall include pilots to improve decoding performance, the spectral efficiency of which was obtained from @ccsds_ccsds_2023[Tab. 3-1]. As such, the actual minimum $E_s / N_0$ will be lower, adding further margin under AWGN conditions.

Interference, demodulation and phase noise effects are still to be analysed, which will reduce the calculated link margin. For this reason a margin target of 10dB was selected.

Additionally, it was assumed that perfect filtering is in place and thus that the total system spectral efficiency is equal to that of the theoretical value for the modulation and coding rate. With that assumption, @ESN0_2_CNR and @spect_eff_2_cap were used to create @modcod_reqs_150khz.

$ E_s / N_0 = C / N ["dB"] $ <ESN0_2_CNR>
$ C = #sym.eta times B ["bps"] $ <spect_eff_2_cap>

#result_fig <modcod_reqs_150khz>

=== Adaptive Coding and Modulation Analysis <ACM-Analysis>

An initial proof of concept investigation was conducted to determine if implementation of ACM is worth the increased complexity. This investigation assumed a fixed orbit altitude of 409km and used ISS TLE data to propagate this for the full 
mission length of 180 days. Orbit propagation was conducted using the MATLAB Satellite Communications Toolbox @mathworks_satellite_nodate Satellite Scenario and Access objects.

Using the system parameters defined in @System-Definitions, the equations defined in @Link-Budget-Equations, and the required 
CNR values defined in @modcod_reqs_150khz, the max achievable data rate was precomputed for each elevation value from 0 to 90#sym.degree in 5#sym.degree increments for both 170km and 409km altitude orbits, the resulting rates shown are in @elevation2Throughput. //TODO: include elevation to throughput

#figure(
  image("../Figures/Elevation2Throughput.svg"),
  caption: "Elevation vs Throughput"
) <elevation2Throughput>

To improve performance, the simulation is run with two timesteps. First, a coarse search is run with a timestep of 100 seconds and the accessIntervals() function used to find the starting time of each ground station pass. Then, a fine search
using a timestep of 1 second is used to find the elevation of the satellite over time during each pass. 

The simulated elevation angles were then binned with values rounded down to the nearest multiple of 5. A histogram of the binned elevation angles versus the time spent within each elevation bin was then created. This was then multipled by the corresponding values in @elevation2Throughput to obtain an estimate of the total data downlinked over the course of the mission using ACM. For CCM it was assumed that the capacity value corresponding to 10#sym.degree elevation was used for the entire mission. The resulting plots are shown in @ACMvCCM.

//TODO: include ACM vs CCM plot
#figure(
  image("../Figures/ACMvCCM.svg"),
  caption:"ACM Performance Analysis"
  ) <ACMvCCM>
 

// TODO: Include Tom's updated propagation?




== Scenarios
#show figure: set block(breakable: false)
Current analysis has been restricted to link budgets based on elevation relative to ground station and satellite altitude as the impact of FSPL is dominant over most other factors. Additionally, the impact of component degradation is yet to be investigated and is to be determined. The scenarios were selected such that they represent the best and worst case for FSPL using the STAC ground station over the expected lifetime, with orbital parameters

=== Commisioning Phase
STRATHcube shortly after deployment from the international space station.

#figure(
  table(
    columns: (auto,auto,auto,auto),
    inset: 6pt,
    align: (horizon,horizon,horizon,horizon), 
    table.header(
      [*Name*],[*Adverse*],[*Nominal*],[*Favourable*]
    ),
    [Altitude], table.cell(colspan: 3, "409km"),
    [Slant Range],                              [1463km],     [1001km],     [611km],
    [FSPL],                                     [148.5 dB],   [145.2 dB],   [140.9 dB],
    [CNR],                                      [10.9 dB],    [14.1 dB],    [19.1 dB],
    [Highest Achievable MODCOD w. 10dB Margin], [QPSK 2/5],   [8PSK 3/5],   [16PSK 3/4],
    [CNR Required],                             [-0.3 dB],    [4.0 dB],     [9.0 dB],
    [Bitrate],                                  [115.6 kbps], [217.8 kbps], [386.2 kbps],                 
  ),
  caption: "STRATHcube Commissioning Phase Budget"
)

=== Transition Phase
STRATHcube at end of primary phase.

#figure(
  table(
    columns: (auto,auto,auto,auto),
    inset: 6pt,
    align: (horizon,horizon,horizon,horizon), 
    table.header(
      [*Name*],[*Adverse*],[*Nominal*],[*Favourable*]
    ),
    [Altitude], table.cell(colspan: 3, "170km"),
    [Slant Range],                              [743km],      [456km],      [260km],
    [FSPL],                                     [142.7 dB],   [138.4 dB],   [133.5 dB],
    [CNR],                                      [16.1 dB],    [20.4 dB],    [26.0 dB],
    [Highest Achievable MODCOD w. 10dB Margin], [8PSK 2/3],   [16APSK 3/4], [32APSK 9/10],
    [CNR Required],                             [6.62 dB],     [10.21 dB],   [16.05 dB],
    [Bitrate],                                  [290.4 kbps], [434.5 kbps], [653.5 kbps],                 
  ),
  caption: "STRATHcube Transition Phase Budget"
)
#show figure: set block(breakable: true)

== Areas for Further Investigation

// TODO: AcubeSAT citation
//.TODO: Interference citation
Thusfar the downlink link budget has been concerned with proving viability and performance limits for development of the  
transmitter system. As such, there has been comparatively less investigation of the receiver system and there has been a large
reliance on numbers derived from the AcubeSAT link budget. There are multiple key challenges for implementing a DVB-S2 receiver,
the largest issue being interference, which can be prevalent on the planned UHF band @quintana-diaz_detection_2022, another being carrier synchronisation and
phase correction.

// TODO: DVB-S2 Notch filter Paper
In @same_effects_2020 the effect of narrowband continuous wave interference was investigated for DVB-S2 QPSK communications and an adaptive notch filter designed. 
@Interference-Filter-Results @same_effects_2020[Fig. 27] shows the effect on BER of a Jamming to Signal Ratio (JSR) of just -6dB. Without filtering, and at low Eb/N0 values, 
the recovery is significantly degraded however the filter is able to improve performance to close to that of the theoretical peak.
The paper also notes that the filter could reduce performance in certain scenarios.

#figure(
  image("../Figures/DVB-S2_Interference.png",width:auto),
  caption: "Impact of interference on DVB-S2 QPSK signal reception."
) <Interference-Filter-Results>

// TODO: Work Package citation?