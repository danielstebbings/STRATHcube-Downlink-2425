#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"

#set heading(offset: 1)

= Transmitter 

#figure(
  image("../Figures/Results/MATLAB/DAC-SM.png"),
  caption: "Spectrum at Output to DAC"
)

#figure(
  image("../Figures/Results/Vivado/Implementation.png"),
  caption: "Implemented Design on Zynq 7020 FPGA"
)

#figure(
  rotate(90deg,image("../Figures/Results/Vivado/Vivado-Block-Diagram.png")),
  caption: "Generated Vivado Block Diagram"
)

#figure(
  image("../Figures/Results/Vivado/Utilisation-Bar.png"),
  caption: "Utilisation of Implemented Design by Subsystem"
)