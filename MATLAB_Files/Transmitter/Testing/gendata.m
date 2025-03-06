function [data_Out,TSorGS_Out,DFL_Out,UPL_Out,SYNC_Out,MODCOD_Out,FECFRAME_Out] = gendata(nFrames,nPackets,TSorGS_In,DFL_In,UPL_In,SYNC_In,MODCOD_In,FECFRAME_In, frm_bits, pkt_bits, byte_bits)
%GENDATA Generates test data samples for the dvb-s2 stream block
% Outputs data bits and control signals padded accordingly
%   Return

    arguments
        nFrames         (1,1)               % Frames to generate
        nPackets        (1,:)               % Packets to generate / frame
        TSorGS_In       (1,:)
        DFL_In          (1,:)
        UPL_In          (1,:)
        SYNC_In         (1,:)
        MODCOD_In       (1,:)
        FECFRAME_In     (1,:)
        frm_bits        (1,1) = 1;
        pkt_bits        (1,1) = 2;
        byte_bits       (1,1) = 5;
    end
    % Validate Inputs
    for i=[TSorGS_In,DFL_In,UPL_In,SYNC_In,MODCOD_In,FECFRAME_In,nPackets]
        if length(i) ~= nFrames_In
            error("Config Params must be of length Frames_In");
        end
    end
    assert(UPL_In < DFL_In, "Packet size larger than Datafield");
    assert(nPackets*UPL_In<DFL_In,"Packets / Frame larger than Datafield");
    assert(frm_bits+pkt_bits+byte_bits == 8, "bit fields in data byte must add to 8 bits");
    assert(frm_bits < 8 && pkt_bits < 8 && byte_vits < 8, "bit fields must not individually be 8 bits")

    

    axiDataArray = zeros(1,nFrames.*nPackets.*UPL_In./8,'uint32');

    frame_it    = uint32(0);
    packet_it   = uint32(0);
    byte_it     = uint32(0);

    for axi_it = 1:length(axiDataArray)
        axi_pkt = uint32(0);
        byte = uint32(0);
        byte = bitor(byte,uint32(byte_it));
        byte = bitor(byte,bitshift(packet_it,byte_bits));
        byte = bitor(byte,bitshift(frame_it,byte_bits+pkt_bits));
        % Byte is of the form: [frm][pkt][byte_cnt]
        assert(byte<256, "byte should be a byte!")




        packet_start = mod((axi_it+1)*8,UPL_Out);
        packet_end   = 0;
        frame_start  = 0;
        frame_end    = 0;





        % Update counters
        frame_it    = mod(frame_it + 1,2^frame_bits);
        packet_it   = mod(packet_it + 1,2^pkt_bits);
        byte_it     = mod(byte_it + 1,2^frame_bits);
        



    end



end

