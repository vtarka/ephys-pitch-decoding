
Animals = {'Noah','Noah','Noah','Noah','Noah','Noah','Noah','Noah',...
    'Ronnie','Ronnie','Ronnie','Ronnie','Derry','Derry','Derry','Derry',...
    'Dory','Dory','Dory','Dory'};

Pens = {'P01','P02','P03','P04','P05','P06','P07','P08',...
    'P04','P05','P08','P13','P02','P03','P05','P08',...
    'P00','P01','P02','P04'};

Qualia = 'Good';



% %stimList:         'CT0'    'CT10'    'CT20'    'CT40'    'CT5'    'F0MaskHigh'    'F0MaskLow'    'allHarm'      'alt'     'high'    'low'    'rand'    'tone'
% %  # (Noah #)       1       2          3         4        5             6            7             8 (9)       9 (11)    10 (12)   11 (13)  12 (14)   13 (15)
for ap = 1:length(Animals)

    load(['E:\Veronica\pitch_ephys\DansMATLABData\' Animals{ap} '\Batch0824\Spikes_' Animals{ap} '_' Pens{ap} '_Good_Pitch.mat']);

    stims = unique(type);
    Flist = unique(F0);
    repeats = unique(Y(:,5));
    units = unique(Y(:,3));
    % windows = [0:5:90;10:5:100]'/1000;
    % windows = [0:2:96; 4:2:100]'/1000;
    % windows = [0:5:290; 10:5:300]'/1000;

    if ap < 9
%         windows = [0:8:442; 8:8:450]'/1000;
        % windows = [0:4:446; 4:4:450]'/1000;
%         windows = [0:449; 1:450]'/1000;
        % windows = [0:10:140; 10:10:150]'/1000;
        % windows = [0 0.2];
        windows = [[0:10:160 270:10:490];[10:10:170 280:10:500]]'/1000;
        % windows = [300:10:440; 310:10:450 ]'/1000;
        % windows = [[0:25:175 300:25:425];[25:25:200 325:25:450]]'/1000;
        % windows = [[0:50:150 300:50:450];[50:50:200 350:50:500]]'/1000;
        % windows = [[0:100:100 300:100:400];[100:100:200 400:100:500]]'/1000;
         
    else
%         windows = [0:8:342; 8:8:350]'/1000;
        % windows = [0:4:346; 4:4:350]'/1000;
%         windows = [0:349; 1:350]'/1000;

        % windows = [0:10:140; 10:10:150]'/1000;
        % windows = [0 0.2];

        windows = [0:10:390; 10:10:400]'/1000;
        % windows = [200:10:340; 210:10:350]'/1000;

        % windows = [0:25:325; 25:25:350]'/1000;
        % windows = [0:50:350; 50:50:400]'/1000;
        % windows = [0:100:300; 100:100:400]'/1000;
    end
    
    

    [X_nwt,unit_key,stim_key,F0_key] = format_data_for_linear_decoder(Y,F0,Flist,stims,type,repeats,units,responsive,offset_responsive,windows,1);

    fname = ['./pitch_data_fulltrial_10ms/lin_decoder_format_' Animals{ap} '_' Pens{ap} '.mat'];
    save(fname,'X_nwt','unit_key','stim_key','F0_key')

% 
%     [X_nwt,unit_key,stim_key,F0_key] = format_data_for_linear_decoder_avgd(Y,F0,Flist,stims,type,repeats,units,responsive,windows);
% 
%     fname = ['./pitch_data/lin_decoder_format_avgd_8ms_' Animals{ap} '_' Pens{ap} '.mat'];
%     save(fname,'X_nwt','unit_key','stim_key','F0_key')


end