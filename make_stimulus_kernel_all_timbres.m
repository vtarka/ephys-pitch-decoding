
% %stimList:         'CT0'    'CT10'    'CT20'    'CT40'    'CT5'    'F0MaskHigh'    'F0MaskLow'    'allHarm'      'alt'     'high'    'low'    'rand'    'tone'
% %  # (Noah #)       1       2          3         4        5             6            7             8 (9)       9 (11)    10 (12)   11 (13)  12 (14)   13 (15)

n_iterations = 1000; % how many times to train a all-timbre model

stims = [8 1 5 2 3 11 10 9 12 13];
% stims = [1 5 2];

params = struct;
params.regularisation = 'ridge';
params.n_folds = 5;
params.shuffle_trials_labels = 0;
params.randomise_trial_order = 1;
params.F0s = 3:17;
params.normalize_yn = 1;
params.log_F0 = 1;

params.animal = 'Ronnie'; animal = params.animal;     
params.pen = 'P04'; pen = params.pen;
params.bin_size = 10;
%     params.data_type = sprintf('lin_decoder_format_%dms',params.bin_size);
params.data_type = 'lin_decoder_format_10ms';

params.data_fname = ['./' params.data_type '.mat'];

params.data_fname = params.data_type;

params.spikes_file = ['E:\Veronica\pitch_ephys\DansMATLABData\' animal... 
        '/Batch0824/Spikes_' animal '_' pen '_Good_Pitch.mat'];

kernels = cell(n_iterations,1);
permutations = cell(n_iterations,1);

for i = 1:n_iterations

    params.stim = stims; %stims(ss);
    [res,permutation,used_trials] = get_stimulus_kernel_all_timbres(params);

    kernels{i} = res.target_F0;
    permutations{i} = permutation;
    trials{i} = used_trials;

end

filename = './kernels_10ms_all_timbres';
save(filename,'kernels','permutations','trials')
