load('kernels_10ms')

%% get ranks
% stims_to_decode = [1 11 10 13]; % CT0, low, high, tone
stims_to_decode = [1 5 2 3 8 11 10 9 12 13];

load('Type')
stim_labels = unique(type);

all_s_importance = cell(length(stims_to_decode),1);

ranks = zeros(1085,length(stims_to_decode));
importances = zeros(1085,length(stims_to_decode));

for ss = 1:length(stims_to_decode)

    this_stim_k = kernels{stims_to_decode(ss)};

    % take the best fold
    [~,best_fold_idx] = get_best_RMSE(this_stim_k);
    best_fold = this_stim_k{best_fold_idx};
    best_fold_kernel = best_fold.kernel.k_fh;

    best_fold_kernel = best_fold_kernel(1:1085,:);
    
    importance = sum(abs(best_fold_kernel),2);

    neuron_list = 1:1085;
    [importance_sorted,rank] = sort(importance,'descend');

    [~,i] = sort(rank,'ascend');
    b = neuron_list(i)';
    ranks(:,ss) = b;
    importances(:,ss) = importance;

    all_s_importance{ss} = {rank, importance};

end


%% decode again

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
params.data_type = 'lin_decoder_format_10ms';

params.data_fname = ['./' params.data_type '.mat'];

params.data_fname = params.data_type;

params.spikes_file = ['E:\Veronica\pitch_ephys\DansMATLABData\' animal... 
        '/Batch0824/Spikes_' animal '_' pen '_Good_Pitch.mat'];

n_repeats = 5;

% steps = [1:50 100:50:1000]; % to sequentially add
steps = [1:200 300:100:1000]; % to sequentially remove
n_steps = length(steps);
kernels = cell(length(stims_to_decode),n_steps,n_repeats);
errs = zeros(length(stims_to_decode),n_steps,n_repeats);

for s = 1:length(stims_to_decode)

    params.stim = stims_to_decode(s);

    for i = 1:length(steps) %n_neurons

            fprintf('\n\nstimulus %d, including %d neurons\n',s,steps(i))

            % top_i = find(ranks(:,s)>=steps(i)); % to sequentially remove
            top_i = find(ranks(:,s)<=steps(i)); % to sequentially add
    
            params.units_to_include = top_i;

        for ii = 1:n_repeats
    
            res = get_stimulus_kernel(params);
    
            kernels{s,i,ii} = res.target_F0;
    
            [~,f] = get_best_RMSE(res.target_F0);
            errs(s,i,ii) = res.target_F0{f}.rms_err_test;
        end
    end

    save('decode_w_top_neurons_sept26','kernels','errs','-v7.3')

end


%% convert to octave errors

octave_errs = zeros(size(errs));

for s = 1:length(stims_to_decode)

    for i = 1:length(steps) %n_neurons
        
        for ii = 1:n_repeats

             model =  kernels{s,i,ii};
    
            [~,f] = get_best_RMSE(model);
            best_kernel = model{f};
            octave_errs(s,i,ii) = get_octave_rmse(best_kernel.target(best_kernel.test_idx),best_kernel.prediction(best_kernel.test_idx),'logHz');
        end
    end
end

%% average across runs

octave_errs_avg = zeros(size(errs,1),size(errs,2));
octave_errs_errs = zeros(size(errs,1),size(errs,2));

for s = 1:length(stims_to_decode)

    for i = 1:n_steps
        
        octave_errs_avg(s,i) = mean(octave_errs(s,i,:));
        octave_errs_errs(s,i) = std(octave_errs(s,i,:)) / sqrt(length(octave_errs(s,i,:)));
    end
end

octave_errs_unaverage = octave_errs;
%% add max error in

octave_errs = octave_errs_avg;
figure;

cm_guide = jet(15);

stims_to_include = [1 5 2 3 8 11 10 9 12 13];
% stims_to_include = label_order;
stims_to_include = 1:10;


cm = zeros(length(stims_to_include),3);
cm(1:5,:) = cm_guide(1:5,:);
cm(6,:) = cm_guide(7,:);
cm(7:9,:) = cm_guide(11:13,:);
cmap = cm;

% cmap = cm([1 6 7 10],:);
lines = [];

% stims_to_include = [1 6 7];

for s = 1:length(stims_to_decode)


    this_s_errs = octave_errs(s,:);
    this_s_errs_errs = octave_errs_errs(s,:);

    shadedErrorBar(1:n_steps,this_s_errs(1:n_steps),this_s_errs_errs(1:n_steps),{'linewidth',2,'color',cmap(s,:)},1);

    final_errs = this_s_errs((n_steps-25):n_steps);

    % max_err = mean(final_errs);
    % 
    % max_80 = max_err + max_err*0.15;
    % 
    % [~,i] = min(abs(this_s_errs - max_80));
    % 
    hold on
    % xline(i,'--','color',cmap(s,:),'linewidth',2)

end

% legend(lines,{'CT','low','high','tone'})

xlabel('# of neurons included')
ylabel('error (octave)')


%% with n_neurons


octave_errs = octave_errs_avg;
figure;

cm_guide = jet(15);

stims_to_include = [1 5 2 3 8 11 10 9 12 13];
% stims_to_include = label_order;

cm = zeros(length(stims_to_include),3);
cm(1:5,:) = cm_guide(1:5,:);
cm(6,:) = cm_guide(7,:);
cm(7:9,:) = cm_guide(11:13,:);
cmap = cm([1 6 7 10],:);

lines = [];

groups = cell(4,1);
groups{1} = [1 2 3 4 5];
groups{2} = 6;
groups{3} = [7 8 9];
groups{4} = 10;

legend_lines = cell(length(groups),1);

for g = 1:length(groups)

    this_group_stims = groups{g};

    this_group_errors = zeros(length(this_group_stims),size(octave_errs,2));

    for s = 1:length(this_group_stims)
    
        this_s_errs = octave_errs(this_group_stims(s),:);
        this_group_errors(s,:) = this_s_errs;
    
    end

    avg_group_errs = mean(this_group_errors);
    std_group_errs = std(this_group_errors) / sqrt(size(this_group_errors,1));

    if size(this_group_errors,1)==1
        avg_group_errs = this_group_errors(1,:);
        std_group_errs = zeros(1,n_steps);
    end

    legend_lines{g} = shadedErrorBar(1:n_steps,avg_group_errs(1:n_steps),std_group_errs(1:n_steps),{'linewidth',2,'color',cmap(g,:)},1);

    final_errs = avg_group_errs(1:2);
    final_errs = avg_group_errs((n_steps-50):n_steps);

    max_err = mean(final_errs);

    max_85 = max_err + max_err*0.15;

    [~,i] = min(abs(avg_group_errs - max_85));

    hold on
    xline(i,'--','color',cmap(g,:),'linewidth',2)
end

% legend(lines,{'CT','low','high','tone'})

xlabel('# of neurons included')
ylabel('RMSE (octave)')
fontname('helvetica light')

g = legend_lines;

legend([g{1} g{2} g{3} g{4}],'both cues','spectral','temporal','tone')


%% with steps


octave_errs = octave_errs_avg;
figure;

cm_guide = jet(15);

stims_to_include = [1 5 2 3 8 11 10 9 12 13];
% stims_to_include = label_order;

cm = zeros(length(stims_to_include),3);
cm(1:5,:) = cm_guide(1:5,:);
cm(6,:) = cm_guide(7,:);
cm(7:9,:) = cm_guide(11:13,:);
cmap = cm([1 6 7 10],:);

lines = [];

groups = cell(4,1);
groups{1} = [1 2 3 4 5];
groups{2} = 6;
groups{3} = [7 8 9];
groups{4} = 10;

legend_lines = cell(length(groups),1);

for g = 1:length(groups)

    this_group_stims = groups{g};

    this_group_errors = zeros(length(this_group_stims),size(octave_errs,2));

    for s = 1:length(this_group_stims)
    
        this_s_errs = octave_errs(this_group_stims(s),:);
        this_group_errors(s,:) = this_s_errs;
    
    end

    avg_group_errs = mean(this_group_errors);
    std_group_errs = std(this_group_errors) / sqrt(size(this_group_errors,1));

    if size(this_group_errors,1)==1
        avg_group_errs = this_group_errors(1,:);
        std_group_errs = zeros(1,length(steps));
    end

    legend_lines{g} = shadedErrorBar(1:length(steps),avg_group_errs(1:length(steps)),std_group_errs(1:length(steps)),{'linewidth',2,'color',cmap(g,:)},1);

    % final_errs = avg_group_errs(1:2);
    % final_errs = avg_group_errs((length(steps)-50):length(steps));

    % max_err = mean(final_errs);

    % max_85 = max_err + max_err*0.15;

    % [~,i] = min(abs(avg_group_errs - max_85));

    hold on
    % xline(i,'--','color',cmap(g,:),'linewidth',2)
end

% legend(lines,{'CT','low','high','tone'})

xlabel('# of neurons included')
ylabel('RMSE (octave)')
fontname('helvetica light')

g = legend_lines;

legend([g{1} g{2} g{3} g{4}],'both cues','spectral','temporal','tone')
