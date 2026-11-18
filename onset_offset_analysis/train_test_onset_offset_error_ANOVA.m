
load('kernels_onset_notime_with_permutation_shuffle.mat')
load('lin_decoder_format_onset_notime_feb26_shuffle')

onset_kernels = kernels;
onset_permutations = permutations;
onset_X_nwt = X_nwt;
onset_stim_key = stim_key;
onset_F0_key = F0_key;

load('kernels_offset_notime_with_permutation_shuffle.mat')
load('lin_decoder_format_offset_notime_feb26_shuffle')

offset_kernels = kernels;
offset_permutations = permutations;
offset_X_nwt = X_nwt;
offset_stim_key = stim_key;
offset_F0_key = F0_key;

% Flist = unique(F0);
% stims = 1:13;
load('Flist')

stims_to_include = [1 5 2 3 8 11 10 9 12 13];
stims = stims_to_include;

errs = zeros(length(stims),4); % on on, on off, off off, off on
ccs = zeros(length(stims),4);

all_errs_on = [];
all_stim_labels_on = [];
all_combo_labels_on = [];

all_errs_off = [];
all_stim_labels_off = [];
all_combo_labels_off = [];

all_errs = [];
all_stim_labels = [];
all_combo_labels = [];

chance = 1.01;

x_space = linspace(5.3,8.5);

stim_labels = zeros(size(ccs));
combo_labels = zeros(size(ccs));


for s_train = 1:length(stims_to_include)

    %% ON kernels
    % test on
    this_stim_res = onset_kernels{stims_to_include(s_train),1};
    this_stim_permutations = permutations{stims_to_include(s_train),1};

    [~,fold_number] = get_best_RMSE(this_stim_res);
    best_kernel = this_stim_res{fold_number}.kernel;
    best_fold = this_stim_res{fold_number};
    test_idx = best_fold.test_idx;

    targets = best_fold.target(test_idx);
    targets = targets - mean(targets);

    predictions = best_fold.prediction(test_idx);
    predictions = predictions - mean(predictions);

    [errs(s_train,1),octave_diffs] = get_octave_rmse(targets,predictions,'logHz'); % train on, test on
    ccs(s_train,1) = best_fold.cc_test;
    stim_labels(s_train,1) = s_train;
    combo_labels(s_train,1) = 1;

    all_errs_on = [all_errs_on; octave_diffs];
    all_stim_labels_on = [all_stim_labels_on; zeros(size(octave_diffs))+s_train];
    all_combo_labels_on = [all_combo_labels_on; zeros(size(octave_diffs))+1];

    all_errs = [all_errs; octave_diffs];
    all_stim_labels = [all_stim_labels; zeros(size(octave_diffs))+s_train];
    all_combo_labels = [all_combo_labels; zeros(size(octave_diffs))+1];

    % test off
    [X_nwt_s,F0_key_s,stim_key_s] = format_data_one_stim(offset_X_nwt,Flist,offset_F0_key,offset_stim_key,stims(s_train),3:17);
    X_nwt_s = normalize_data(X_nwt_s);

    unpermuted_test_trials = this_stim_permutations(test_idx);
    % new_test_trials = randsample(size(X_nwt_s,3),length(test_idx));
    % new_test_trials = 1:size(X_nwt_s,3);
    X_nwt_s = X_nwt_s(:,1,unpermuted_test_trials);

    res = struct;
    res.target = log(F0_key_s(unpermuted_test_trials));
    res.prediction = kernelconv(X_nwt_s, best_kernel)';

    targets = res.target;
    % m_targets = mean(targets);
    targets = targets - mean(targets);

    predictions = res.prediction;
    % m_predictions = mean(predictions);
    predictions = predictions - mean(predictions);

    cc_train = corrcoef(res.target, res.prediction);
    res.cc = cc_train(1,2);
    res.rms = rms(res.target-res.prediction);

    [errs(s_train,2),octave_diffs] = get_octave_rmse(targets,predictions,'logHz'); % train on, test off
    ccs(s_train,2) = res.cc;
    stim_labels(s_train,2) = s_train;
    combo_labels(s_train,2) = 2;

    all_errs_on = [all_errs_on; octave_diffs];
    all_stim_labels_on = [all_stim_labels_on; zeros(size(octave_diffs))+s_train];
    all_combo_labels_on = [all_combo_labels_on; zeros(size(octave_diffs))+2];

    all_errs = [all_errs; octave_diffs];
    all_stim_labels = [all_stim_labels; zeros(size(octave_diffs))+s_train];
    all_combo_labels = [all_combo_labels; zeros(size(octave_diffs))+2];



    %% OFF kernels
    % test off
    this_stim_res = offset_kernels{stims_to_include(s_train),1};
    this_stim_permutations = offset_permutations{stims_to_include(s_train),1};

    [~,fold_number] = get_best_RMSE(this_stim_res);
    best_kernel = this_stim_res{fold_number}.kernel;
    best_fold = this_stim_res{fold_number};
    test_idx = best_fold.test_idx;

    targets = best_fold.target(test_idx);
    targets = targets - mean(targets);

    predictions = best_fold.prediction(test_idx);
    predictions = predictions - mean(predictions);

    [errs(s_train,3), octave_diffs] = get_octave_rmse(targets,predictions,'logHz'); % train on, test on
    ccs(s_train,3) = best_fold.cc_test;
    stim_labels(s_train,3) = s_train;
    combo_labels(s_train,3) = 1;

    all_errs_off = [all_errs_off; octave_diffs];
    all_stim_labels_off = [all_stim_labels_off; zeros(size(octave_diffs))+s_train];
    all_combo_labels_off = [all_combo_labels_off; zeros(size(octave_diffs))+1];

    all_errs = [all_errs; octave_diffs];
    all_stim_labels = [all_stim_labels; zeros(size(octave_diffs))+s_train];
    all_combo_labels = [all_combo_labels; zeros(size(octave_diffs))+1];

    % test on
    [X_nwt_s,F0_key_s,stim_key_s] = format_data_one_stim(onset_X_nwt,Flist,onset_F0_key,onset_stim_key,stims(s_train),3:17);
    X_nwt_s = normalize_data(X_nwt_s);

    unpermuted_test_trials = this_stim_permutations(test_idx);
    % new_test_trials = randsample(size(X_nwt_s,3),length(test_idx));
    X_nwt_s = X_nwt_s(:,1,unpermuted_test_trials);

    res = struct;
    res.target = log(F0_key_s(unpermuted_test_trials));
    res.prediction = kernelconv(X_nwt_s, best_kernel)';

    cc_train = corrcoef(res.target, res.prediction);
    res.cc = cc_train(1,2);
    res.rms = rms(res.target-res.prediction);

    targets = res.target;
    targets = targets - mean(targets);

    predictions = res.prediction;
    predictions = predictions - mean(predictions);

    cc_train = corrcoef(res.target, res.prediction);
    res.cc = cc_train(1,2);
    res.rms = rms(res.target-res.prediction);

    [errs(s_train,4),octave_diffs] = get_octave_rmse(targets,predictions,'logHz'); % train on, test off
    ccs(s_train,4) = res.cc;
    stim_labels(s_train,4) = s_train;
    combo_labels(s_train,4) = 2;

    all_errs_off = [all_errs_off; octave_diffs];
    all_stim_labels_off = [all_stim_labels_off; zeros(size(octave_diffs))+s_train];
    all_combo_labels_off = [all_combo_labels_off; zeros(size(octave_diffs))+2];

    all_errs = [all_errs; octave_diffs];
    all_stim_labels = [all_stim_labels; zeros(size(octave_diffs))+s_train];
    all_combo_labels = [all_combo_labels; zeros(size(octave_diffs))+2];

end

%% run an ANOVA on onset stim


[p,tbl,stats] = anovan(all_errs_on,{all_stim_labels_on,all_combo_labels_on},'model','interaction','varnames',{'stim','combo'});
[results,~,~,gnames] = multcompare(stats,'dimension',[1 2]);

tbl = array2table(results,"VariableNames", ...
    ["Stimulus","Combination","Lower Limit","A-B","Upper Limit","P-value"]);
tbl.("Stimulus")=gnames(tbl.("Stimulus"));
tbl.("Combination")=gnames(tbl.("Combination"));

[p,tbl,stats] = anovan(all_errs_off,{all_stim_labels_off,all_combo_labels_off},'model','interaction','varnames',{'stim','combo'});
[results,~,~,gnames] = multcompare(stats,'dimension',[1 2]);

tbl = array2table(results,"VariableNames", ...
    ["Stimulus","Combination","Lower Limit","A-B","Upper Limit","P-value"]);
tbl.("Stimulus")=gnames(tbl.("Stimulus"));
tbl.("Combination")=gnames(tbl.("Combination"));

[p,tbl,stats] = anovan(all_errs,{all_stim_labels,all_combo_labels},'model','interaction','varnames',{'stim','combo'});
[results,~,~,gnames] = multcompare(stats,'dimension',[1 2]);

tbl = array2table(results,"VariableNames", ...
    ["Stimulus","Combination","Lower Limit","A-B","Upper Limit","P-value"]);
tbl.("Stimulus")=gnames(tbl.("Stimulus"));
tbl.("Combination")=gnames(tbl.("Combination"));



%% plot the average error

figure;

load('Type')
type = unique(type);
labels = type(stims_to_include);

colours = [
         0         0    0.7500;
         0         0    1.0000;
         0    0.2500    1.0000;
         0    0.5000    1.0000;
         0    0.7500    1.0000;
    0.5000    1.0000    0.5000;
    1.0000    0.7500         0;
    1.0000    0.5000         0;
    1.0000    0.2500         0;
         0         0         0
];


subplot(2,1,1)
hold on

significant_stims = [1 2 3 4 6 7 9];

for s = 1:length(stims_to_include)
    this_stim_idx = all_stim_labels_on==s;

    combo_1_idx = all_combo_labels_on==1;
    this_stim_errs_1 = all_errs_on(this_stim_idx & combo_1_idx);

    combo_2_idx = all_combo_labels_on==2;
    this_stim_errs_2 = all_errs_on(this_stim_idx & combo_2_idx);

    if ismember(s,significant_stims)
        errorbar([1 2],[mean(this_stim_errs_1) mean(this_stim_errs_2)],...
            [std(this_stim_errs_1)/sqrt(length(this_stim_errs_1)) std(this_stim_errs_2)/sqrt(length(this_stim_errs_2))],...
            'color',colours(s,:),'linewidth',2,'marker','*','markersize',5)
    else
        errorbar([1 2],[mean(this_stim_errs_1) mean(this_stim_errs_2)],...
            [std(this_stim_errs_1)/sqrt(length(this_stim_errs_1)) std(this_stim_errs_2)/sqrt(length(this_stim_errs_2))],...
            'color',colours(s,:),'linewidth',2,'marker','*','markersize',5,'linestyle',':')
    end
end


xticks(1:2)
xticklabels({'onset','offset'})
title('train onset')
set(gca,'fontsize',14)

fontname('Helvetica Light')

ylabel('mean octave error')

yline(1.01,'k--')
ylim([0.2 1.6])



subplot(2,1,2)
hold on

significant_stims = [1 2 3 4 5 6 7 8];

for s = 1:length(stims_to_include)
    this_stim_idx = all_stim_labels_off==s;

    combo_1_idx = all_combo_labels_off==1;
    this_stim_errs_1 = all_errs_off(this_stim_idx & combo_1_idx);

    combo_2_idx = all_combo_labels_off==2;
    this_stim_errs_2 = all_errs_off(this_stim_idx & combo_2_idx);

    if ismember(s,significant_stims)
        errorbar([1 2],[mean(this_stim_errs_1) mean(this_stim_errs_2)],...
            [std(this_stim_errs_1)/sqrt(length(this_stim_errs_1)) std(this_stim_errs_2)/sqrt(length(this_stim_errs_2))],...
            'color',colours(s,:),'linewidth',2,'marker','*','markersize',5)
    else
        errorbar([1 2],[mean(this_stim_errs_1) mean(this_stim_errs_2)],...
            [std(this_stim_errs_1)/sqrt(length(this_stim_errs_1)) std(this_stim_errs_2)/sqrt(length(this_stim_errs_2))],...
            'color',colours(s,:),'linewidth',2,'marker','*','markersize',5,'linestyle',':')
    end
end


xticks(1:2)
xticklabels({'offset','onset','-1*onset'})
title('train offset')
set(gca,'fontsize',14)
ylabel('mean octave error')
yline(1.01,'k--')
ylim([0.2 1.6])
xlabel('test window')
fontname('Helvetica Light')


%% plot CCs

figure;
subplot(2,1,1)

ccs_subset = ccs;

for s = 1:size(ccs_subset,1)
    hold on
    plot(ccs_subset(s,1:2),'color',colours(s,:),'linewidth',2,'marker','*','markersize',10)
end

xticks(1:2)
xticklabels({'onset','offset','-1*offset'})
title('train onset')
set(gca,'fontsize',14)

fontname('Helvetica Light')

ylabel('CC')

yline(0,'k--')
ylim([-1 1])

subplot(2,1,2)

ccs_subset = ccs;

for s = 1:size(ccs_subset,1)
    hold on
    plot(ccs_subset(s,3:4),'color',colours(s,:),'linewidth',2,'marker','*','markersize',10)
end

xticks(1:2)
xticklabels({'offset','onset','-1*onset'})
title('train offset')
set(gca,'fontsize',14)
ylabel('CC')
yline(0,'k--')
ylim([-1 1])
xlabel('test window')
fontname('Helvetica Light')

%% plot the average error for combined on/off ANOVA

figure;

load('Type')
type = unique(type);
labels = type(stims_to_include);

colours = [
         0         0    0.7500;
         0         0    1.0000;
         0    0.2500    1.0000;
         0    0.5000    1.0000;
         0    0.7500    1.0000;
    0.5000    1.0000    0.5000;
    1.0000    0.7500         0;
    1.0000    0.5000         0;
    1.0000    0.2500         0;
         0         0         0
];

hold on

significant_stims = 1:9;

for s = 1:length(stims_to_include)
    this_stim_idx = all_stim_labels==s;

    combo_1_idx = all_combo_labels==1;
    this_stim_errs_1 = all_errs(this_stim_idx & combo_1_idx);

    combo_2_idx = all_combo_labels==2;
    this_stim_errs_2 = all_errs(this_stim_idx & combo_2_idx);

    if ismember(s,significant_stims)
        errorbar([1 2],[mean(this_stim_errs_1) mean(this_stim_errs_2)],...
            [std(this_stim_errs_1)/sqrt(length(this_stim_errs_1)) std(this_stim_errs_2)/sqrt(length(this_stim_errs_2))],...
            'color',colours(s,:),'linewidth',2,'marker','*','markersize',5)
    else
        errorbar([1 2],[mean(this_stim_errs_1) mean(this_stim_errs_2)],...
            [std(this_stim_errs_1)/sqrt(length(this_stim_errs_1)) std(this_stim_errs_2)/sqrt(length(this_stim_errs_2))],...
            'color',colours(s,:),'linewidth',2,'marker','*','markersize',5,'linestyle',':')
    end
end

xticks(1:2)
xticklabels({'within window','across window'})
set(gca,'fontsize',14)

fontname('Helvetica Light')

ylabel('mean octave error')

yline(1.0,'k--')
ylim([0.2 1.4])


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