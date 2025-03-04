  #set math.equation(numbering: "(1)")
  #set text(lang: "gb", size: 12pt)

= Link Budget

STRATHcube is currently on the FYS design booster programme. For this a link budget was required. Much of the background research for this link budget was done by a previous student. The link budget was then reassessed and updated to reflect the impact of DVB-S2 and ACM.
//== DVB-S2 Modulation and Coding Rate Requirements
#let results=csv("../Figures/modvals.csv")

#let result_fig = figure(
  table(
    columns:8,
    align:(center),
    table.header(
      [*Bits / Symbol*],[*Mod - ulation*],[*Coding Rate*],[*Data Rate (bps)*],[*Spectral Efficiency (bps/Hz)*],[*Minimum Eb/N0 *],[*Minimum CNR (dB)*],[*Minimum CNR w. 10dB Margin (dB)*]
    ),
    ..results.slice(1).flatten(),
  ),
  caption:"DVB-S2 Modulation and Coding Rate Requirements, 150kHz Bandwidth"

)
== System Definitions

#figure(
  table(
    columns: (auto,auto,auto),
    inset: 6pt,
    align: (left,center, center),
    table.header(
      [*Name*],[*Value*],[*Source*]
    ),
    table.cell(colspan: 3, align(center,strong("System"))),
    [Frequency ($f$)],[435 MHz],[UHF Amateur Satellite Service Allocation],
    [Bandwidth ($B$)],[150 kHz],[],

    table.cell(colspan: 3, align(center,strong("STRATHCube"))),
    [Transmit Power ($P_"Tx"$)],       [$1.5 "W"$],      [Previous FYS limit],
    [Cable Losses ($L_"Cable"$)],         [$0.116 "dB"$],   [20cm RG-188/AU], // Big margin, Acubesat calc
    [VSWR],                 [$1.9:1$],        [ISIS Antenna Datasheet],// ISIS ant datasheet
    [Antenna Reflection Loss ($L_"Reflection"$)],[$0.44 "dB"$],    [@Reflection_Loss], // Acubesat link budget calculator
    [Connector Losses ($L_"Connector"$)],   [$0.2 "dB"$],       [4 Connectors \@ 0.05dB],
    [Switch Losses ($L_"Switch"$)],      [$0.5 "dB"$],       [Acubesat, included specutalively], //acubesat, unsure if real
    [Total Line Losses ($L_"Line"$)],  [$1.26 "dB"$],      [@Line_Loss],
    [Transmit Antenna Gain ($G_"Tx"$)],  [$0 "dBi"$],        [ISIS Antenna Datasheet],
    [*EIRP*],               [*$0.50 "dBW"$*],  [@EIRP],

    table.cell(colspan: 3, align(center,strong("Ground Station"))),
    [*Receive Antenna Gain ($G_"Rx"$)*], [*$13 "dBi"$*], [Arbitary Antenna], //https://www.rfsolutions.co.uk/antennas/directional-stacked-yagi-antenna-405-440mhz-with-13dbi-gain/
    [LNA Gain ($G_"LNA"$)],              [$22.5 "dB"$],           [Acubesat],
    [Line Losses],                       [$2.39 "dB"$],           [Acubesat],

    table.cell(colspan: 3, align(center,strong("Ground Station Noise Temperature"))),
    [Antenna ($T_"Ant"$)],                      [$154 "K"$],    [Acubesat],
    [Feedline ($T_"Feed"$)],                     [$290 "K"$],    [Acubesat],
    [LNA ($T_"LNA"$)],                          [$28 "K"$],     [Acubesat],
    [Frontend ($T_"FE"$)],                     [$1000 "K"$],   [Acubesat],
    [Cable Loss ($L_"Cable"$)],                   [$1.023 "dB"$], [Acubesat], //super high? Like 10m of cable
    [Transmission Line Coefficient (#sym.alpha)],[$0.6331$],     [Acubesat], //acube 
    [*Receiver Noise Temperature ($T_"Rx"$)*],   [*$249.365 "K"$*],[@Receiver_Noise_Temp],
 
    table.cell(colspan: 3, align(center,strong("Atmospheric Path Losses"))),
    [Scintillation ($L_"Scint,dB"$)],[$0.16 "dB"$],  [Acubesat],
    [Rain Fade ($L_"Rain,dB"$)],    [$0 "dB"$],     [Assumed as negligible in UHF],
    [Ionospheric ($L_"Ion,dB"$)],  [$0.4 "dB"$],   [Acubesat],
    [Polarisation ($L_"Pol,dB"$)], [$3 "dB"$],     [],
    [*AEPL*],[*$3.56 "dB"$*],[@Atmospheric_Effect_Loss],


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
    [Elevation], [$10 #sym.degree$],[$20 #sym.degree$ ],[$40 #sym.degree$],[],
    [Atmospheric Absorption ($L_"Atm"$)],[2.1 dB],[1.1 dB], [0.4 dB],[Acubesat]
  ),
  caption: "Dynamic Parameters"
)

== Methodology
Reflection loss can be calculated as follows:
$ L_"Reflection,W"   = P_"Tx,W" times ("VSWR"-1)^2 / ("VSWR"+1)^2 ["W"] #linebreak()
  L_"Reflection,dB"  = 10 times log_10 ((P_"Tx,W" - L_"Reflection,W")/ P_"Tx,W") ["dB"] $ <Reflection_Loss>

The Transmitter total line losses are calculated as follows:
$ L_"Line,dB" = L_"Cable,dB"+L_"Reflection,dB" + L_"Connectors,dB" + L_"Switch,dB" ["dB"] $ <Line_Loss>
EIRP:
$ "EIRP"_"dB" =  P_"Tx,dB" - L_"Line,dB" + G_"Tx,dB" ["dBW"] $ <EIRP>

Receiver noise temperature:
$ T_"Rx" = #sym.alpha times T_"Ant" + (1 - #sym.alpha) times T_"Feed" + (T_"FE" times L_"Cable") / (G_"LNA") [K] $ <Receiver_Noise_Temp>

Atmospheric Effect Path Loss and Atmospheric Path Loss:
$ "AEPL"_"dB" = L_"Scint,dB" + L_"Rain,dB" + L_"Ion,dB" + L_"Pol,dB" ["dB"] $ <Atmospheric_Effect_Loss>
$ "APL"_"dB" = "AEPL"_"dB" + L_"Atm,dB" ["dB"] $ <Atmospheric_Path_Loss>

// TODO: Add EsN0 to EbN0 to CNR calcs
// TODO: Spect eff to datarate
// TODO: total Spect eff calculation - Currently vibes based 100% 
// TODO: Add received signal power, received noise power

== Scenarios

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
    [CNR],                                      [12.9 dB],    [16.2 dB],    [20.5 dB],
    [Highest Achievable MODCOD w. 10dB Margin], [QPSK 3/5],   [8PSK 3/5],   [16APSK 3/4],
    [CNR Required],                             [2.2 dB],     [5.5 dB],      [10.2 dB],
    [Bitrate],                                  [179.6 kbps], [269.3 kbps], [448.3 kbps],                 
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
    [FSPL],                                     [142.56 dB],  [138.4 dB],   [133.5 dB],
    [CNR],                                      [15.6 dB],    [19.8 dB],    [25.4 dB],
    [Highest Achievable MODCOD w. 10dB Margin], [8PSK 3/5],   [16APSK 2/3], [32APSK 5/6],
    [CNR Required],                             [5.5 dB],     [9.0 dB],     [14.3 dB],
    [Bitrate],                                  [259.7 kbps], [455.9 kbps], [742.6 kbps],                 
  ),
  caption: "STRATHcube Transition Phase Budget"
)