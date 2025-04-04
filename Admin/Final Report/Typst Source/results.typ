#import "@preview/acrostiche:0.5.1": *
#import "@preview/subpar:0.2.1"
#import "@preview/codelst:2.0.2": sourcecode

#set heading(offset: 1)

= Simulation
// TODO: ref ITU spectrum mask
The system was succesfully simulated and the output waveform measured using a spectrogram block. This was compared against the ITU out-of-band spectrum mask for the amateur and amateur-satellite service, as shown in @DAC-Spectrum-ITU-Mask. The green indicates that the waveform succesfully complies. A MATLAB function called spectMask() was created to generate the mask coefficients, the code for which is shown in @spectMask-Listing. The mask is defined in terms of necessary bandwidth, which was set to 150 kHz, and transmit power, which was set to 1 W.

#figure(
  image("../Figures/Results/MATLAB/DUT-OUT-BLACK.png"),
  caption: "Spectrum at output to DAC with ITU out of band emission spectra mask. Note that the power scale does not reflect the true output power, as the DAC only uses the upper 12 bits."
) <DAC-Spectrum-ITU-Mask>

#figure(sourcecode[```MATLAB
function [mask] = spectMask(Bn, Ptx)
%SPECTMASK Creates mask limit boundaries based on ITU-R SM.1541-7 Fig 43
%   Bn   : Necessary bandwidth (Hz)
%   Ptx  : Transmit power (W)
%   Mask : all dBc
arguments
    Bn  (1,1) = 150e3;
    Ptx (1,1) = 1;
end
    bound_50  = -10;
    bound_120 = -1*(31 + 10*log10(Ptx));
    bound_225 = -1*(38 + 10*log10(Ptx));
    posmask = [0,             0;  ...
               Bn/2,          0;  ...
               Bn/2,   bound_50;  ...
               Bn*1.2, bound_50;  ...
               Bn*1.2, bound_120; ...
               Bn*2.25, bound_120; ...
               Bn*2.25, bound_225; ...
               ];
    negmask = flip([posmask(:,1).*-1, posmask(:,2)],1);
    mask = [negmask;posmask];
end
```], 
caption: [Primary Payload Packet Definition]) <spectMask-Listing>

Late in testing it was found that the transmitter was not functioning correctly with the generated packet inputs. The nextFrame signal did not get reasserted after the first frame was transmitted. Additionally, the flag output did not indicate that valid frames were being transmitted. The waveform observed is shown in @flag-waveform, and the circuit for the flag signal generation shown in @flag-generation.

#figure(
  image("../Figures/Results/MATLAB/Flag-Waveform.png"),
  caption:"Logic analyser circuit of DVB-S2 inputs and outputs. The input data is being sent, however only the MSB of flag is being set, and never the LSB."
) <flag-waveform>

#figure(
  image("../Figures/Results/MATLAB/flag-circuit.png"),
  caption:"Flag signal generation. The MSB of the flag signal indicates the end of a dummy header, and the LSB the end of a valid PL Header carryig data."
) <flag-generation>

Assertion logic was added to verify that the serialisation of packet data was functioning correctly. The circuit is shown in @assert-circuit. By modifying the circuit, it was confirmed that packet data was being serialised correctly, however the transmitter was still not functional. The resulting waveform can be seen in @assert-wav.

#figure(
  image("../Figures/Results/MATLAB/Serialisation-Assert.png"),
  caption: "Serialisation verification circuit. The AXI packets are input into Parallel_In, and bit shifted to isolate the payload byte. At the same time, the output of Packet Parser is connected to Serial_In. This is upsampled to match the rates of the two signals with zero padding. The assertion triggers if the parallel and serial are not equal, while both inputs are valid."
) <assert-circuit>

#figure(
  image("../Figures/Results/MATLAB/Serial-Assert-Waveform.png"),
  caption:"Logic analyser waveform of assertion circuit. The serialised data, Assert_S, can be seen to be identical to the parallel data, Assert_P with zeros inserted. The signals are only not equal during the zero padding, from Assert_Sneq0."
) <assert-wav>

The serialisation circuit was also analysed using a logic analyser, resulting in @parse-fifo-waveform, and found to be functioning correctly.

#figure(
  image("../Figures/Results/MATLAB/parse-FIFO-waveform.drawio.svg"),
  caption:"AXI-Stream Interface Logic Analyser Waveform"
) <parse-fifo-waveform>

Unfortunately, the issue with the transmitter interface was not able to be corrected before the end of the project, however the design was still able to be exported to Vivado to test feasibility.

= Code Generation & Hardware Implementation
The HDL Coder design was exported to Vivado. The generated block diagram is shown in @vivado-block-diagram. This design was succesfully implemented and synthesised. The resource report showed that the design fit onto the chip, however there was very little Block RAM left over. The usage by subsystem and resource type is shown in @resource-util-Bar. The placed and routed design on the chip is shown in @implemented-design. The design also succesfully passed timing, with the slack shown @timing-analysis.

#figure(
  table(
    columns:3,
    align:(center),
    table.header(
      [*Worst Negative Slack*],[*Worst Hold Slack*],[*Worst Pulse Width Slack*]
    ),
    [0.126 ns],[0.016 ns],[0.264]
  ),
  caption: "Timing Analysis Results"
) <timing-analysis>

#pagebreak()
#set page(flipped: true)
#figure(
  rotate(0deg,image("../Figures/Results/Vivado/Vivado-Results.drawio.png",width:110%)),
  caption: "Generated Vivado IP Block Diagram. Most blocks are used for interfacing with the transceiver, or the PS."
) <vivado-block-diagram>
#pagebreak()
#set page(flipped: false)

#figure(
  image("../Figures/Results/Vivado/Utilisation-Bar.png",width:80%),
  caption: "Utilisation of implemented design by subsystem and type. The DVB-S2 transmitter block requires relatively little resources, with the exception of Block RAM, of which it uses 87.1%."
) <resource-util-Bar>

#figure(
  image("../Figures/Results/Vivado/Implementation.png",width:80%),
  caption: "Implemented design on Zynq 7020 SoC FPGA. Areas coloured in blue are FPGA resources used by the design. "
) <implemented-design>





