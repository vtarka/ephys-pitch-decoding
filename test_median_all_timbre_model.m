load('kernels_10ms_all_timbres.mat')

RMSEs = nan(length(kernels),1); % record all so we 

for i = 1:length(kernels)
    this_stim_res = kernels{i};
    [best_RMSE,fold_number] = get_best_RMSE(this_stim_res);

    RMSEs(i) = best_RMSE;
end


%%
m = min(RMSEs); %median(RMSEs(1:end-1));
m_idx = find(RMSEs==m);

median_model = kernels{m_idx};
[~,best_fold] = get_best_RMSE(median_model);
best_median_model = median_model{best_fold};

median_trials = trials{m_idx};
median_trials = reshape(median_trials,15*13,1);


%% test the median model on all the timbres


load('lin_decoder_format_10ms.mat')

X_nwt_n = normalize_data(X_nwt);

% Get rid of stims/freq combos that weren't presented
F0_key_vec = F0_key(1,:); % take the F0 key just for the first window

X_nwt = X_nwt(:,:,F0_key_vec~=0); % get rid of any index where the F0 key is 0 (meaning this stim wasn't presented)

% eliminate these indices from the keys as well
stim_key = stim_key(:,F0_key_vec~=0); 
F0_key = F0_key(:,F0_key_vec~=0);

%% select stim
stim = [8 1 5 2 3 11 10 9 12 13];

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
F0s = 3:17;

% select only these stims from the big data set
X_nwt = X_nwt(:,:,ismember(F0_key_vec,F0s));

% adjust the keys to reflect the selected stims 
stim_key = stim_key(:,ismember(F0_key_vec,F0s)); 
F0_key = F0_key(:,ismember(F0_key_vec,F0s));

stim_key_vec = stim_key(1,:);
F0_key_vec = F0_key(1,:);


% need to remove the trials that were potentially in the training set
% X_nwt(:,:,median_trials) = [];
% F0_key(:,median_trials) = [];
% stim_key(:,median_trials) = [];

load('Flist')
figure;
stims_to_include = [8 1 5 2 3 11 10 9 12 13];
titles = {'MF','CT','CT 5%','CT 10%','CT 20%','Res. Harm.','Unres. Harm.','Alt. Phase','Rand. Phase','Tone'};

plot_idx = [1 3 5 7 9 2 4 6 8 10];

errs = zeros(length(stims_to_include),2);
ccs = zeros(length(stims_to_include),2);

for s = 1:length(stims_to_include) % for each stimulus (training stimulus)

    [X_nwt_s,F0_key_s,stim_key_s] = format_data_one_stim(X_nwt,Flist,F0_key,stim_key,stims_to_include(s),3:17); % get just the stimuli and F0s that we want
    
    X_nw_s = [];
    unique_F0s = unique(F0_key_s);
    for f = 1:length(unique_F0s)
        this_f_trials_idx = find(F0_key_s==unique_F0s(f));
        this_f_trials = X_nwt_s(:,:,this_f_trials_idx);
        X_nw_s = cat(3,X_nw_s,mean(this_f_trials,3));
    end

    this_stim_res = kernels{stims_to_include(s),1}; % decoding kernel for this stimulus

    % [~,fold_number] = get_best_RMSE(this_stim_res); % get the best error and fold number
    % best_fold = this_stim_res{fold_number}; % get just the best kernel
    % best_kernel = best_fold.kernel;
    best_kernel = best_median_model.kernel;

    res = struct;
    res.target = log(unique_F0s);% log(F0_key_s); % trained on log(F0) so test on log(F0)
    res.prediction = kernelconv(X_nw_s, best_kernel)'; % make prediction

    cc_test = corrcoef(res.target, res.prediction);
    res.cc = cc_test(1,2);
    % cc_train = xcorr(res.target, res.prediction);
    % res.cc = cc_train;
    res.rms = rms(res.target-res.prediction);

    [~,octave_error] = get_octave_rmse(res.target,res.prediction,'logHz');
    % octave_error = res.rms;

    % results{stims_to_include(s),stims_to_include(s)} = res;
    % err(stims_to_include(s),stims_to_include(s)) = octave_error;

    test_targets = res.target;
    test_predictions = res.prediction;

    % train_targets = best_fold.target(best_fold.train_idx);
    % train_predictions = best_fold.prediction(best_fold.train_idx);

    subplot(2,5,s)
    hold on
    % plot(train_targets,train_predictions,'k.','marker','+','markersize',3)
    plot(test_targets,test_predictions,'k.','marker','o','markersize',5)
    title(titles{s})

    xlim([5.8 8.4])
    ylim([5.8 8.4])


    plot([5.8 8.4],[5.8 8.4],'k:')

    xticks(log(Flist(5:4:17)))
    xticklabels(Flist(5:4:17))

    yticks(log(Flist(5:4:17)))
    yticklabels(Flist(5:4:17))





    text(6.5, 6.1, sprintf('error (octave): %.2f',mean(octave_error)),'FontSize',8,'color','k')
    % text(6.5, 6.1, sprintf('CC: %.2f',cc_test(1,2)),'FontSize',8,'color','k')
    fontname('helvetica light')

    % errs(s,1) = mean(octave_diffs_train);
    % errs(s,2) = mean(octave_diffs_test);

    if s==6
        xlabel('actual F0')
        ylabel('predicted F0')
    end
    % set(gca,'fontsize',12)
end

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