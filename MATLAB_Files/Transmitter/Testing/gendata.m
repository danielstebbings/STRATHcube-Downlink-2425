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
        if length(i) ~= 1 && length(i) ~= nFrames_In
            error("Config Params must be of length 1 or nFrames_In");
        end
    end
    assert(nPackets*UPL_In<DFL_In,"Packets / Frame larger than Datafield");
    assert
    
    axiDataArray = zeros(1,nFrames.*nPackets.*UPL_In./8,'uint32')

    % Generate Frames
    for frame_it = 1:nFrames_In
        TSorGS   = TSorGS_In(frame_it);
        DFL      = DFL_In(frame_it);
        UPL      = UPL_In(frame_it);
        SYNC     = SYNC_In(frame_it);     
        MODCOD   = MODCOD_In(frame_it);
        FECFRAME = FECFRAME_In(frame_it);

        nBytes = nPackets/8;
        assert(rem(nBytes,1)==0,"DFL/UPL must be divisible by 8");
        frm_cnt = mod(frame_it-1,2^(frm_bits));
        for pkt_it = 1:nPackets
            for byte_it = 1:nBytes
            end
        end

    end

    for byte_it = 1:axiDataArray/8
        frame_it = 




    end



end

