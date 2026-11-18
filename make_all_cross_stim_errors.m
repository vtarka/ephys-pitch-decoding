% This script tests linear decoding models trained on one timbre (called 'stimulus') on another timbre
% DEPENDENCIES: kernelconv function from BenLib Github repo
% INPUT: kernels_*.mat file that contains all the decoding models for every kernel
%        lin_decoder_format_*.mat that contains X_nwt, F0_key, stim_key, pen_key, and unit_key variables
%        see README for more details on input data
% OUTPUT: cross_prediction_errors_*.mat
% AUTHOR: Veronica Tarka, veronica.tarka@dpag.ox.ac.uk, 2025

%% THINGS TO SET
bin_size_ms = 10; % time bin size to analyse
trial_window = ''; % on of 'onset','offset','fulltrial'

%%
% load(sprintf('kernels_%dms_%s',bin_size_ms,trial_window)) % load kernels
% load(sprintf('lin_decoder_format_%dms_%s.mat',bin_size_ms,trial_window))  % load raw data

load("kernels_10ms.mat")
load("lin_decoder_format_10ms.mat")
load('Flist')

stims = 1:13;

% pre-allocate space
results = cell(length(stims)); % store results of cross-decoding
err = zeros(length(stims)); % store the RMSE of cross-decoding
best_kernels = cell(length(stims),1); % store the best fold from each stimulus

for s_train = 1:length(kernels) % for each stimulus (training stimulus)
    this_stim_res = kernels{s_train,1}; % decoding kernel for this stimulus
    this_stim_perm = permutations{s_train,1};

    [~,fold_number] = get_best_RMSE(this_stim_res); % get the best error and fold number
    best_fold = this_stim_res{fold_number};
    best_kernel = best_fold.kernel; % get just the best kernel
    best_kernels{s_train} = best_kernel; % store the best kernel

    for s_test = 1:length(stims) % for each stimulus (testing stimulus)

        if s_test==s_train % if train and test are the same, we can't apply the kernel to the full dataset (it includes training data)
            
            % take the error of the best fold
                   
            res = struct;
            res.rms = best_fold.rms_err_test;
            res.cc = best_fold.cc_test;
            res.target = best_fold.target;
            res.prediction = best_fold.prediction;
            res.test_idx = best_fold.test_idx;

            octave_error = get_octave_rmse(res.target(res.test_idx),res.prediction(res.test_idx),'logHz');
            % octave_error = res.rms;

            results{s_train,s_test} = res;
            err(s_train,s_test) = octave_error;

        else
            [X_nwt_s,F0_key_s,stim_key_s] = format_data_one_stim(X_nwt,Flist,F0_key,stim_key,stims(s_test),3:17); % get just the stimuli and F0s that we want

            X_nwt_s = normalize_data(X_nwt_s); % since we trained on normalized data, we should test on normalized data

            res = struct;
            res.target = log(F0_key_s); % trained on log(F0) so test on log(F0)
            res.prediction = kernelconv(X_nwt_s, best_kernel)'; % make prediction

            cc_train = corrcoef(res.target, res.prediction);
            res.cc = cc_train(1,2);
            res.rms = rms(res.target-res.prediction);

            octave_error = get_octave_rmse(res.target,res.prediction,'logHz');
            % octave_error = res.rms;

            results{s_train,s_test} = res;
            err(s_train,s_test) = octave_error;

        end      
    end
end

% filename = sprintf('cross_prediction_errors_%dms_%s',bin_size_ms,trial_window);
filename = 'cross_prediction_errors_10ms';
save(filename,'results','err','best_kernels')


function [X_nwt_s,F0_key_s,stim_key_s] = format_data_one_stim(X_nwt,Flist,F0_key,stim_key,stim,F0s)

 %% fixing the stimuli
    
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

    % stim_key_vec = stim_key(1,:);
    F0_key_vec = F0_key(1,:);

    %% select frequencies
    
    % select only these stims from the big data set
    X_nwt = X_nwt(:,:,ismember(F0_key_vec,F0s));
    
    % adjust the keys to reflect the selected stims 
    stim_key = stim_key(:,ismember(F0_key_vec,F0s)); 
    F0_key = F0_key(:,ismember(F0_key_vec,F0s));

    stim_key_vec = stim_key(1,:);
    F0_key_vec = F0_key(1,:);

    X_nwt_s = X_nwt;
    F0_key_s = Flist(F0_key_vec);
    stim_key_s = stim_key_vec;
end

function normalized_data = normalize_data(X_nwt)

normalized_data = zeros(size(X_nwt));

for uu = 1:size(X_nwt,1) % for each neuron

    this_uu_psths = squeeze(X_nwt(uu,:,:));

    mi = min(min(this_uu_psths));
    ma = max(max(this_uu_psths));

    n_this_uu_psths = ( this_uu_psths - mi ) / ( ma - mi );

    n_this_uu_psths = ( this_uu_psths - mean(this_uu_psths,'all') / (std(this_uu_psths,0,'all')) );

    n_this_uu_psths(isnan(n_this_uu_psths)) = 0;
    normalized_data(uu,:,:) = n_this_uu_psths;
end

end