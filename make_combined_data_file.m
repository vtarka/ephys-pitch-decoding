
Animals = {'Noah','Noah','Noah','Noah','Noah','Noah','Noah','Noah',...
    'Ronnie','Ronnie','Ronnie','Ronnie','Derry','Derry','Derry','Derry',...
    'Dory','Dory','Dory','Dory'};

Pens = {'P01','P02','P03','P04','P05','P06','P07','P08',...
    'P04','P05','P08','P13','P02','P03','P05','P08',...
    'P00','P01','P02','P04'};

Qualia = 'Good';


all_X_nwt = [];
all_F0_key = [];
all_stim_key = [];
all_unit_key = [];
all_pen_key = [];

% %stimList:         'CT0'    'CT10'    'CT20'    'CT40'    'CT5'    'F0MaskHigh'    'F0MaskLow'    'allHarm'      'alt'     'high'    'low'    'rand'    'tone'
% %  # (Noah #)       1       2          3         4        5             6            7             8 (9)       9 (11)    10 (12)   11 (13)  12 (14)   13 (15)
for ap = 1:20

    animal = Animals{ap};
    pen = Pens{ap};

    load(['../pitch_data_fulltrial_10ms_feb26/lin_decoder_format_' animal '_' pen])

    if ap < 9
        [X_nwt,F0_key,stim_key] = select_trials(X_nwt,F0_key,stim_key,3:17,[1:7 9 11:15]);
        % [X_nwt,F0_key,stim_key] = select_trials(X_nwt,F0_key,stim_key,3:17,[1:7 10:15]);

        % rename the stimuli
        stim_key(stim_key==9) = 8;
        % stim_key(stim_key==10) = 8;
        stim_key(stim_key==11) = 9;
        stim_key(stim_key==12) = 10;
        stim_key(stim_key==13) = 11;
        stim_key(stim_key==14) = 12;
        stim_key(stim_key==15) = 13;
        
    else
        [X_nwt,F0_key,stim_key] = select_trials(X_nwt,F0_key,stim_key,3:17,1:13);
    end

    if ap == 1
        all_X_nwt = X_nwt;
        all_F0_key = F0_key;
        all_stim_key = stim_key;
        all_unit_key = unit_key;
        all_pen_key = zeros(size(unit_key))+ap;

    else
        all_X_nwt = cat(1,all_X_nwt,X_nwt);
        all_F0_key = cat(2,all_F0_key,F0_key);
        all_stim_key = cat(2,all_stim_key,stim_key);
        all_unit_key = cat(1,all_unit_key,unit_key);
        all_pen_key = cat(1,all_pen_key,zeros(size(unit_key))+ap);
    end

end

X_nwt = all_X_nwt;
unit_key = all_unit_key;
pen_key = all_pen_key;

% [X_nwt,F0_key,stim_key] = select_trials(X_nwt,F0_key,stim_key,3:17,1:13);

save('lin_decoder_format_10ms','X_nwt','F0_key','stim_key','unit_key','pen_key')