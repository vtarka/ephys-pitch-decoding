function [results, permutation,used_trials] = get_stimulus_kernel_all_timbres(params)

    if nargin==0
        params = struct;
    end
    
    %% defaults
    
    regularisation = 'ridge';
    n_folds = 5;
    shuffle_trial_labels = 0;
    randomise_trial_order = 1;
    normalize_yn = 0;
    log_F0 = 1;
    
    units_to_include = 'all';
    
    % animal and penetration to load
    animal = 'Ronnie';
    pen = 'P05';
    bin_size = 1; % ms
    data_type = sprintf('lin_decoder_format_%dms',bin_size);
    
    stim = 4; % stim to include in decoder, 1:13 for all stims, 1:15 for all stims for Noah  
    F0s = 3:17;
    
    % data binned and formatted for linear decoder
    data_fname = ['/media/veronica/Kat Data/Veronica/pitch_ephys/population-decoding/ana-decoding/pitch_data/'...
        data_type '_' animal '_' pen '.mat'];
    
    % original spiking and stim data
    spikes_file = ['/media/veronica/Kat Data/Veronica/pitch_ephys/DansMATLABData/' animal '/Batch0824/Spikes_' animal '_' pen '_Good_Pitch.mat'];
    
    
    %% make struct fields into variables
    fields = fieldnames(params);
    for ii = 1:length(fields)
        var = fields{ii};
        val = getfield(params, fields{ii});
    
        if isstr(val)
            eval(sprintf('%s = ''%s'';', var, val));
        elseif isscalar(val)
            eval(sprintf('%s = %d;', var, val));
        elseif isvector(val)
            eval([var ' = [' sprintf('%d,', val) '];']);
        end
    end

    %% Loading data
    
    % load data files
    load(data_fname)
    % loads:
    %%% x_nwt: formatted data, d1 = neuron, d2 = time, d3 = trial (or trial avg)
    %%% unit_key: the ID# for each unit in d1 of x_nwt
    %%% stim_key: the stimulus for each trial (n_windows x n_trials)
    %%% F0_key: the F0 for each trial (n_windows x n_trials)

   if ~strcmp(units_to_include,'all')
        X_nwt = X_nwt(units_to_include,:,:);
    end

    if normalize_yn
        X_nwt_n = normalize_data(X_nwt);
    end

    load(spikes_file,'F0') % loads the original list of F0 per trial
    
    % % declare the time windows depending on which animal this is
    % if strcmp(animal,'Noah')
    %     windows = [0:bin_size:(450-bin_size) ; bin_size:bin_size:450]'/1000;
    % else
    %     windows = [0:bin_size:(350-bin_size) ; bin_size:bin_size:350]'/1000;
    % end


    %% fixing the stimuli
    % get list of all F0s presented
    Flist = unique(F0);
    
    % Get rid of stims/freq combos that weren't presented
    F0_key_vec = F0_key(1,:); % take the F0 key just for the first window
    
    X_nwt = X_nwt(:,:,F0_key_vec~=0); % get rid of any index where the F0 key is 0 (meaning this stim wasn't presented)
    
    % eliminate these indices from the keys as well
    stim_key = stim_key(:,F0_key_vec~=0); 
    F0_key = F0_key(:,F0_key_vec~=0);


    %% select stim
    
    % stimuli to be used in the decoder (see key at top of file)
    stim_key_vec = stim_key(1,:);
    
    % select only these stims from the big data set
    X_nwt = X_nwt(:,:,ismember(stim_key_vec,stim));
    
    % adjust the keys to reflect the selected stims 
    stim_key = stim_key(:,ismember(stim_key_vec,stim)); 
    F0_key = F0_key(:,ismember(stim_key_vec,stim));

    stim_key_vec = stim_key(1,:);
    F0_key_vec = F0_key(1,:);

    %% select frequencies
    
    % select only these stims from the big data set
    X_nwt = X_nwt(:,:,ismember(F0_key_vec,F0s));
    
    % adjust the keys to reflect the selected stims 
    stim_key = stim_key(:,ismember(F0_key_vec,F0s)); 
    F0_key = F0_key(:,ismember(F0_key_vec,F0s));

    stim_key_vec = stim_key(1,:);
    F0_key_vec = F0_key(1,:);

    %% randomly sample trials across the timbres
    % the idea is to make sure we still have 13 instances of each F0 to
    % make it as fair to compare against 1-timbre models as possible

    X_nwt_sample = [];
    stim_key_sample = [];
    F0_key_sample = [];
    used_trials = []; % keep track of the trials we used in this iteration

    unique_F0s = unique(F0_key_vec);
    for f = 1:length(unique_F0s)

        this_f0_trials = find(ismember(F0_key_vec,unique_F0s(f)));
        % get just trials with this f0
        X_nwt_f = X_nwt(:,:,this_f0_trials);

        n_trials = size(X_nwt_f,3);

        % randomly choose 13 of these trials to include

        rand_trials = randsample(n_trials,13);
        X_nwt_f_sample = X_nwt_f(:,:,rand_trials);
        F0_key_f = ones(13,1)*unique_F0s(f);
        stim_key_f = stim_key_vec(this_f0_trials);
        stim_key_f = stim_key_f(rand_trials);
        stim_key_f = stim_key_f';

        % concatenate
        X_nwt_sample = cat(3,X_nwt_sample,X_nwt_f_sample);
        F0_key_sample = cat(1,F0_key_sample,F0_key_f);
        stim_key_sample = cat(1,stim_key_sample,stim_key_f);
        used_trials = cat(1,used_trials,this_f0_trials(rand_trials));
    end

    % overwrite the old stuff
    X_nwt = X_nwt_sample;
    stim_key_vec = stim_key_sample;
    F0_key_vec = F0_key_sample;

    %% prepare the trial labels
    n_trials = size(X_nwt, 3);
    n_test = floor(n_trials/n_folds);
    
    % use 10% of training data as validation data, or a minimum of 10 trials
    n_val = max(floor((n_trials-n_test)*.1), 10);
    
    n_clusters = size(X_nwt, 1);
    all_psthes = mean(X_nwt, 3);

    F0_key_vec = Flist(F0_key_vec);

    permutation = 1:n_trials;

    % shuffle trial order if desired
    if randomise_trial_order
        rand_perm = randperm(n_trials);
        X_nwt = X_nwt(:,:,rand_perm);
        F0_perm = F0_key_vec(rand_perm);
        permutation = rand_perm;
    else
        F0_perm = F0_key_vec;
    end
    
    % shuffle trial labels if desired (control)
    if shuffle_trial_labels
        X_nwt = X_nwt(:,:, randperm(n_trials));
        F0_perm = F0_key_vec(randperm(n_trials));
    end
       
    if log_F0 % if we want to represent F0 as log space
        F0_perm = log(F0_perm);
    end
    
    %% run the decoder
    
    target_F0 = {};
    
    all_test_idx = [];
    
    for fold = 1:n_folds
        test_start_idx = 1 + n_test*(fold-1);

        % add any extra trials (after division into n equal folds) on to the final test set
        if fold==n_folds
            test_idx = test_start_idx:n_trials;
        else
            test_idx = test_start_idx:test_start_idx+n_test-1;
        end

        all_test_idx = cat(2, all_test_idx, test_idx);
        train_idx = setdiff(1:n_trials, test_idx);

        target_F0{end+1} = decode_bw(X_nwt, F0_perm, train_idx, test_idx, regularisation, n_val);
    end
    
    % check all trials are included in exactly one test set
    assert(n_trials==length(unique(all_test_idx)))
    assert(all(1:n_trials==sort(all_test_idx)))
    
    results.target_F0 = target_F0;

end


function normalized_data = normalize_data(X_nwt)

normalized_data = zeros(size(X_nwt));

for uu = 1:size(X_nwt,1) % for each neuron

    this_uu_psths = squeeze(X_nwt(uu,:,:));

    mi = min(min(this_uu_psths));
    ma = max(max(this_uu_psths));

    n_this_uu_psths = ( this_uu_psths - mi ) / ( ma - mi );

    n_this_uu_psths = ( this_uu_psths - mean(this_uu_psths,'all') / (std(this_uu_psths,0,'all')) );

    normalized_data(uu,:,:) = n_this_uu_psths;
end

end