#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"

#set heading(offset: 1)

= Transmitter 

#figure(
  image("../Figures/Results/MATLAB/DAC-SM.png"),
  caption: "Spectrum at output to DAC with ITU out of band emission spectra mask. Note that the power scale does not reflect the true output power, as the DAC only uses the upper 12 bits."
)

#figure(
  image("../Figures/Results/Vivado/Implementation.png",width:80%),
  caption: "Implemented design on Zynq 7020 SoC FPGA. Areas coloured in blue are FPGA resources used by the design. "
)

#figure(
  rotate(90deg,image("../Figures/Results/Vivado/Vivado-Block-Diagram.png")),
  caption: "Generated Vivado IP Block Diagram. Most blocks are used for interfacing with the transceiver, or the PS."
)

#figure(
  image("../Figures/Results/Vivado/Utilisation-Bar.png"),
  caption: "Utilisation of implemented design by subsystem and type. The DVB-S2 transmitter block requires relatively little resources, with the exception of Block RAM, of which it uses 87.1%."
)

#figure(
  image("../Figures/Implementation/block-diagram/software-interface.png"),
  caption: "Generated software interface. Packets are transmitted by sending data into the \"data\" port of the AD936x Transmitter block. This block can also be used to configure the radio, including center frequency"
)

= Packet Handling

