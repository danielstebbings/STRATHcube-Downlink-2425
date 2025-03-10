function [data_Out,TSorGS_Out,DFL_Out,UPL_Out,SYNC_Out,MODCOD_Out,FECFRAME_Out] = gendata(nFrames,nPackets, ...
                                                                                            TSorGS_In,DFL_In,UPL_In,SYNC_In,MODCOD_In,FECFRAME_In, ...
                                                                                            frm_bits, pkt_bits, pl_cnt_bits, ...
                                                                                            frameEnd_pos, frameStart_pos, pktEnd_pos, pktStart_pos)
%GENDATA Generates test data samples for the dvb-s2 stream block
% Outputs data bits and control signals padded accordingly
% Data packets contains counters for frame, packet, and byte, as well as
% start and end markers.
% ---------------------------
% Bit Maps
% data_Out:
%   31 downto 12:   0 / padding
%   11 downto  4:   Data Byte
%   3:              frameEndIn
%   2:              frameStartIn
%   1:              pktEndIn
%   0:              pktStartIn
% Data Byte:
%   7                  downto (7-frm_bits): Frame Count
%   (7-frame_bits-1)   downto (byte_bits) : Packet Count
%   (payload_bits - 1)    downto 0:            Data payload Count   
%
% ---------------------------
% Outputs all of length data_Out
% TODO: Multiple control settings / function run

    arguments
        % Packet Generation
        nFrames         (1,1) uint32              % Frames to generate
        nPackets        (1,1) uint32             % Packets to generate / frame
        
        % Control Signals
        TSorGS_In       (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(TSorGS_In,    4)} % fixdt(0,2,0)
        DFL_In          (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(DFL_In,   65536)} % uint16
        UPL_In          (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(UPL_In,   65536)} % uint16
        SYNC_In         (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(SYNC_In,    256)} % uint8
        MODCOD_In       (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(MODCOD_In,   32)} % fixdt(0,5,0)
        FECFRAME_In     (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(FECFRAME_In,  2)} % logical
        
        % Marker bit settings
        frm_bits        (1,1) = 1;
        pkt_bits        (1,1) = 2;
        pl_cnt_bits     (1,1) = 5;

        % Control Signal bit positions
        frameEnd_pos    (1,1) = 3;
        frameStart_pos  (1,1) = 2;
        pktEnd_pos      (1,1) = 1;
        pktStart_pos    (1,1) = 0;
    end
    % Validate Inputs
    for i=[TSorGS_In,DFL_In,UPL_In,SYNC_In,MODCOD_In,FECFRAME_In,nPackets]
        if length(i) ~= 1
            error("Config Params must be of length 1");
        end
    end
    assert(UPL_In < DFL_In,                     "Packet size larger than Datafield");
    assert(nPackets*UPL_In==DFL_In,             "Packets / Frame larger than Datafield");
    assert(frm_bits+pkt_bits+pl_cnt_bits == 8, "bit fields in data byte must add to 8 bits");
    assert(frm_bits < 8 && pkt_bits < 8 && pl_cnt_bits < 8, "bit fields must not individually be 8 bits")

    % Fixing Types
    TSorGS_In_t = fi(TSorGS_In,0,2,0);
    DFL_In_t    = uint16(DFL_In);
    UPL_In_t    = uint16(UPL_In);
    SYNC_In_t   =  
    FECFRAME_In_t = logical(FECFRAME_In)
    
    % Generate nFrames each with nPackets, each containing UPL[bits] / 8 bytes
    axiDataArray = zeros(1,nFrames.*nPackets.*UPL_In./8,'uint32');

    frame_it    = uint32(0);
    packet_it   = uint32(0);
    payload_it  = uint32(0);

    for axi_it = 0:length(axiDataArray)-1
        axi_pkt = uint32(0);
        payload = uint32(0);
        flags   = uint32(0);
        UPL_it  = UPL_In; % TODO: change for UPL_In matrix
        DFL_it  = DFL_In; % TODO: change for DFL_In matrix
        
        % Creating payload byte
        % 0b[00...][byte_it] -> 0b[0...][byte_bits]
        payload = bitor(payload,mod(payload_it,2^pl_cnt_bits));
        % 0b[000...][packet_it] -> 0b[00...][pkt_bits][byte_bits]
        payload = bitor(payload,bitshift( ...
                            mod(packet_it,2^pkt_bits), ... % Modulo to remain length pkt_bits
                            pl_cnt_bits) ...
                    );
        % 0b[0...][frame_it] -> 0b[0...][frm_bits][pkt_bits][byte_bits]
        payload = bitor(payload,bitshift(...
                            mod(frame_it,2^frm_bits), ...
                            pl_cnt_bits+pkt_bits) ...
                            );
        % payload is of the form: 0b[0...][frm count][pkt count][byte count]
        assert(payload<256, "Payload byte should be a byte! payload_it: %d , payload val: %d",payload_it,payload)

        % Creating control flag bits
        bits_sent = (axi_it+1)*8;
        packet_start = uint32(mod(bits_sent-8,  UPL_it)  == 0);
        packet_end   = uint32(mod(bits_sent,    UPL_it)  == 0);
        frame_start  = uint32(mod(bits_sent-8,  DFL_it)  == 0);
        frame_end    = uint32(mod(bits_sent,    DFL_it)  == 0);
        assert(packet_start<2 && packet_end < 2 && frame_start < 2 && frame_end<2,"Flags should be 1 bit");

        % Creating control flag field
        flags = bitor(flags, bitshift( ...
                                packet_start, ...
                                pktStart_pos ...
                                ) ...
                    );
        flags = bitor(flags, bitshift( ...
                                packet_end, ...
                                pktEnd_pos ...
                                ) ...
                    );
        flags = bitor(flags, bitshift( ...
                                frame_start, ...
                                frameStart_pos ...
                                ) ...
                    );
        flags = bitor(flags, bitshift( ...
                                frame_end, ...
                                frameEnd_pos ...
                                ) ...
                    );
        
        % Create axi packet
        % 0b[0...][payload byte][flags]
        payload_startpos = 4; % Flags always 4 bits
        axi_pkt = bitor(flags, bitshift( ...
                                    payload, ...
                                    payload_startpos ...
                                    ) ...
                    );
        % Place in array
        axiDataArray(axi_it+1) = axi_pkt;

        % Update counters
        if frame_end
            frame_it = frame_it + 1;
        end
        if packet_end
            packet_it = packet_it + 1;
        end
        payload_it = payload_it + 1;
    end % Axi Stream loop



% Assign outputs
data_Out     = axiDataArray;
% Match length of control signals
TSorGS_Out   = repelem(TSorGS_In_t,   length(axiDataArray)); 
DFL_Out      = repelem(DFL_In_t,    length(axiDataArray));
UPL_Out      = repelem(UPL_In_t,      length(axiDataArray));
SYNC_Out     = repelem(SYNC_In,     length(axiDataArray));
MODCOD_Out   = repelem(MODCOD_In,   length(axiDataArray));
FECFRAME_Out = repelem(FECFRAME_In, length(axiDataArray));
    

end % Function

