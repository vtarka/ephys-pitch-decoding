
% %stimList:         'CT0'    'CT10'    'CT20'    'CT40'    'CT5'    'F0MaskHigh'    'F0MaskLow'    'allHarm'      'alt'     'high'    'low'    'rand'    'tone'
% %  # (Noah #)       1       2          3         4        5             6            7             8 (9)       9 (11)    10 (12)   11 (13)  12 (14)   13 (15)


stims = 1:13;

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
params.bin_size = 1;
%     params.data_type = sprintf('lin_decoder_format_%dms',params.bin_size);
params.data_type = 'lin_decoder_format_offset_notime_feb26_shuffle';

params.data_fname = ['./' params.data_type '.mat'];

params.data_fname = params.data_type;

params.spikes_file = ['E:\Veronica\pitch_ephys\DansMATLABData\' animal... 
        '/Batch0824/Spikes_' animal '_' pen '_Good_Pitch.mat'];

kernels = cell(length(stims),1);
permutations = cell(length(stims),1);

for ss = 1:length(stims)

    params.stim = stims(ss);
    [res,perm] = get_stimulus_kernel(params);

    kernels{ss} = res.target_F0;
    permutations{ss} = perm;

end

filename = './kernels_offset_notime_with_permutation_shuffle';
save(filename,'kernels','permutations')
