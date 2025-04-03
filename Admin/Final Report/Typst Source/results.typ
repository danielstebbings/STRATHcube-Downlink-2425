#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"
#import "@preview/codelst:2.0.2": sourcecode

#set heading(offset: 1)

= Transmitter 

// TODO: ref ITU spectrum mask
The system was succesfully simulated and the output waveform measured using a spectrogram block. This was compared against the ITU out-of-band spectrum mask for the amateur and amateur-satellite service, as shown in @DAC-Spectrum-ITU-Mask. The green indicates that the waveform succesfully complies to the mask. A MATLAB function called spectMask() was created to generate the mask coefficients, the code for which is shown in 

#figure(
  image("../Figures/Results/MATLAB/DAC-SM.png"),
  caption: "Spectrum at output to DAC with ITU out of band emission spectra mask. Note that the power scale does not reflect the true output power, as the DAC only uses the upper 12 bits."
) <DAC-Spectrum-ITU-Mask>

#figure(sourcecode[```C++
struct PPL_pkt_64k : Packet{
    double standard_deviation;  // Standard deviation of data
    double codebook[16];        // Quantization levels
    uint32_t data[2048];        // compressed PPL data

    cereal::PortableBinaryOutputArchive serialise();
};
```], 
caption: [Primary Payload Packet Definition]) <spectMask-Listing>


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


