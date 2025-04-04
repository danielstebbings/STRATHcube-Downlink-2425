# STRATHCube-Downlink-2425
Creation of the downlink communication system for the STRATHcube satellite.

This project can be viewed [on GitHub](https://github.com/danielstebbings/STRATHCube-Downlink-2425/tree/main)

## Directory Structure
```
├── Admin
│   ├── EDHPC
│   │   ├── Extended Abstract
│   │   └── IEEE-Conference-LaTeX-template_10-17-19
│   ├── Final Report
│   │   ├── Bibliographies
│   │   ├── Figures
│   │   └── Typst Source
│   ├── Interim-Report
│   │   └── Document
│   └── Oral
├── gnuradio
│   ├── DVB-S2 Experiments
│   │   └── iguraurad
│   └── Tutorials
│       └── first-flowgraph
├── MATLAB_Files
│   ├── ACM_Analysis
│   └── Transmitter
│       ├── dvb-axis
│       ├── DVBS2HDLTransmitterExample
│       └── Testing
└── Packet_Handling
    ├── CCDD_Stuff
    │   └── CCDD
    └── GSE
        ├── build
        ├── include
        └── out
```
### Admin
Documents created about the project, including the final dissertation document.

### gnuradio
Some files created during the initial investigation of implementation. Can be ignored at this time.

### MATLAB Files
Simulink and MATLAB files created for the Adaptive Coding and Modulation analysis, as well as the transmitter implementation.

The dvb-axis folder contains the HDL-Coder design detailed in the submitted report.

See MATLAB Files / README.md for more information

### Packet Handling
Preliminary work on the implementation of Generic Stream Encapsulation. A database for packet definition was also generated using [CCDD](https://github.com/nasa/CCDD).

See Packet_Handling / README.md for more information.

