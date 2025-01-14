/*
 * File Name:         hdl_prj/ipcore/HDL_Chirp_ip_v1_0/include/HDL_Chirp_ip_addr.h
 * Description:       C Header File
 * Created:           2025-01-14 13:38:25
*/

#ifndef HDL_CHIRP_IP_H_
#define HDL_CHIRP_IP_H_

#define  IPCore_Reset_HDL_Chirp_ip                                 0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_HDL_Chirp_ip                                0x4  //enabled (by default) when bit 0 is 0x1
#define  IPCore_PacketSize_AXI4_Stream_Write_Master_HDL_Chirp_ip   0x8  //Packet size for AXI4-Stream Write Master interface, the default value is 1024. The TLAST output signal of the AXI4-Stream Write Master interface is generated based on the packet size.
#define  IPCore_Timestamp_HDL_Chirp_ip                             0xC  //contains unique IP timestamp (yymmddHHMM): 2501141338
#define  maxTxCount_Data_HDL_Chirp_ip                              0x100  //data register for Inport maxTxCount
#define  txStart_Data_HDL_Chirp_ip                                 0x104  //data register for Inport txStart
#define  txSel_Data_HDL_Chirp_ip                                   0x108  //data register for Inport txSel

#endif /* HDL_CHIRP_IP_H_ */
