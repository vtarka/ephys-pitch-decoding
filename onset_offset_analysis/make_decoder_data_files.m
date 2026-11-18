
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

    if ap < 9
        windows = [0.3 0.4];         
    else
        windows = [0.2 0.3];
    end

    % windows = [0 0.1];

    [X_nwt,unit_key,stim_key,F0_key] = format_data_for_linear_decoder(Y,F0,Flist,stims,type,repeats,units,responsive,offset_responsive,windows,1);

    fname = ['./offset_notime/lin_decoder_format' Animals{ap} '_' Pens{ap} '.mat'];
    save(fname,'X_nwt','unit_key','stim_key','F0_key')

end