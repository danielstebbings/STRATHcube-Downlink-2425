#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"
#set heading(offset: 1)

= Systems Engineering
// Development of requirements

= Transmitter
// Decision not to use DVB-S2X features

#figure(
  image("../Figures/System-Architecture/DVB-S2.png"),
  caption:"Transmitter Block Diagram"
)

= Packet Handling
// GSE Usage
// Why not gse-lite?
// -- PPL Data size req

= Full System

// TODO: PHY -> not that
// TODO: AD936x controller control signals
#figure(
  image("../Figures/System-Architecture/System_Diagram.drawio.svg",width:75%),
  caption: "System Diagram"
)