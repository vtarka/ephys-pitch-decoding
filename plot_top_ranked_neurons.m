
load('kernels_10ms.mat')
label_order = [1 5 2 3 8 11 10 9 12 13];

load('Type')
stim_labels = unique(type);

colours = zeros(length(label_order),1085,4);

cmap = turbo(1085);
cmap = flip(cmap);

all_s_importance = cell(length(label_order),1);

ranks = zeros(1085,length(label_order));
importances = zeros(1085,length(label_order));

for ss = 1:length(label_order)

    this_stim_k = kernels{label_order(ss)};

    % take the best fold
    [~,best_fold_idx] = get_best_RMSE(this_stim_k);
    best_fold = this_stim_k{best_fold_idx};
    best_fold_kernel = best_fold.kernel.k_fh;

    best_fold_kernel = best_fold_kernel(1:1085,:);

    
    importance = sum(abs(best_fold_kernel),2);
    % importance = std(abs(best_fold_kernel),0,2);
    % importance = max(abs(best_fold_kernel),[],2);

    neuron_list = 1:1085;
    [importance_sorted,rank] = sort(importance,'descend');

    [~,i] = sort(rank,'ascend');
    b = neuron_list(i)';
    ranks(:,ss) = b;
    importances(:,ss) = importance;

    all_s_importance{ss} = {rank, importance};

end


%% plot importance for each stimulus
titles = {'CT','CT 5%','CT 10%','CT 20%','MF','Res. Harm.','Unres. Harm.','Alt. Phase','Rand. Phase','Tone'};

figure;
for ss = 1:length(label_order)
    this_s_importance = all_s_importance{ss,1}{1,2};

    sorted_importance = sort(this_s_importance,'descend');
    sum_importance = sum(this_s_importance);
    importance_cutoff = sum_importance*0.001;

    n_neurons = length(importance);
    second_derivative = zeros(n_neurons,1);

    importance = sorted_importance;
    for n = 2:(n_neurons-1)
        second_derivative(n) = importance(n+1) + importance(n-1) - 2*(importance(n));
    end

    

    % [~,i] = max(second_derivative);

    max_importance = max(importance);
    importance_cutoff = max_importance*0.1;
    [~,i] = min(abs(sorted_importance-importance_cutoff));

    subplot(2,5,ss)
    plot(sorted_importance,'linewidth',2,'color','k')
    hold on
    xline(i,'k:','linewidth',3)
    title(titles{ss})
    ylim([0 max_importance])

    fontname('helvetica light')

    if ss == 1 || ss == 6
        ylabel('importance')
    end

    if ss>5
        xlabel('neuron')
    end
end

%% plot importance for specific stimuli
colours = [
         0         0    0.7500;
         0         0    1.0000;
         0    0.2500    1.0000;
         0    0.5000    1.0000;
         0    0.7500    1.0000;
         0    0.836     0.363;
    1.0000    0.5000         0;
    1.0000    0.7500         0;
    1.0000    0.2500         0;
         0         0         0
];

figure;
subplot(1,2,1)
hold on
lines = cell(4,1);

stims = [1 2 3 4];
for s = 1:length(stims)

    this_s_importance = all_s_importance{s,1}{1,2};

    sorted_importance = sort(this_s_importance,'descend');

    max_importance = max(sorted_importance);
    importance_cutoff = max_importance*0.1;
    [~,i] = min(abs(sorted_importance-importance_cutoff));

    lines{s} = plot(sorted_importance,'linewidth',1,'color',colours(s,:));
    hold on
    xline(i,'color',colours(s,:),'linewidth',1,'linestyle','--')

    fontname('helvetica light')
end
l = legend([lines{1:4}],'0% jitter','5% jitter','10% jitter','20% jitter');
% title(l,'click train jitter')
ylabel('importance')
xlabel('neuron')

subplot(1,2,2)
hold on


stims = [1 6 7 10];
lines = cell(length(stims),1);
for s = 1:length(stims)

    this_s_importance = all_s_importance{stims(s),1}{1,2};

    sorted_importance = sort(this_s_importance,'descend');

    max_importance = max(sorted_importance);
    importance_cutoff = max_importance*0.1;
    [~,i] = min(abs(sorted_importance-importance_cutoff));

    lines{s} = plot(sorted_importance,'linewidth',1,'color',colours(stims(s),:));
    hold on
    xline(i,'color',colours(stims(s),:),'linewidth',1,'linestyle','--')

    fontname('helvetica light')
end
l = legend([lines{1:s}],'click train','resolved harm.','unresolved harm.','pure tone');
xlabel('neuron')
% title(l,'timbre')


%% adjust for those with 0 importance
% 
% non_zero_ranks = cell(size(ranks,2),1);
% 
% for s = 1:size(ranks,2)
% 
%     child_ranks = ranks(:,s);
% 
%     nonzero_importance_child = importances(:,s)~=0;
% 
%     indices_to_include = nonzero_importance_child;
%     % indices_to_include = 1085:-1:1;
% 
% 
%     child_ranks = ranks(indices_to_include,s);
% 
% 
%     [~,rank] = sort(child_ranks,'descend');
%     [~,i] = sort(rank,'ascend');
%     b = neuron_list(i)';
%     child_ranks = b;
% 
%     non_zero_ranks{s} = child_ranks;
% 
% end


%% plot how many neurons are shared in common in top 50 neurons

n_neurons = 109; % plot top 10%
% n_neurons = 55; % plot top 5%
shared_top = zeros(size(ranks,2));

min_rank = 1;
max_rank = 109; % plot top 10%
% max_rank = 55; % plot top 5%
min_shared = max_rank;

for ss = 1:size(ranks,2)
    for s = 1:size(ranks,2)
        if ss == s
            continue
        end

        [~,i_parent] = mink(ranks(:,ss),n_neurons);
        [~,i_child] = mink(ranks(:,s),n_neurons);

        i_parent = find(ranks(:,ss)>=min_rank & ranks(:,ss)<=max_rank);
        i_child = find(ranks(:,s)>=min_rank & ranks(:,s)<=max_rank);

        common_elements = intersect(i_parent,i_child);

        shared_top(ss,s) = length(common_elements);

        if length(common_elements)<min_shared
            min_shared = length(common_elements);
        end
    end
end

for ss = 1:size(ranks,2)
    for s = 1:size(ranks,2)
        if ss == s
            shared_top(ss,s) = min_shared;
        end
    end
end


figure
imagesc(shared_top)
colorbar
xticks(1:10)
xticklabels(stim_labels(label_order))
yticks(1:10)
yticklabels(stim_labels(label_order))
set(gca,'fontsize',14)
c = colorbar;
title(c,'shared neurons')
smallest_shared = min(min(shared_top));
clim([smallest_shared 50])

hold on
for ss = 1:size(ranks,2)
    square = polyshape([ss-1 ss-1 ss ss]+0.5,[ss-1 ss ss ss-1]+0.5);
    plot(square,'facecolor',[0.5 0.5 0.5],'facealpha',1,'edgecolor',[0.5 0.5 0.5])
end

%% Plot venn diagram of shared neurons between low, high, and CT0

v = shared_top([1 6 7],[1 6 7]);
ct_low = v(1,2);
ct_high = v(1,3);
low_high = v(2,3);

% get the overlap on all three
ct_idx = find(ranks(:,1)>=min_rank & ranks(:,1)<=max_rank);
low_idx = find(ranks(:,6)>=min_rank & ranks(:,6)<=max_rank);
high_idx = find(ranks(:,7)>=min_rank & ranks(:,7)<=max_rank);
ct_low_idx = intersect(ct_idx,low_idx);
ct_low_high = length(intersect(ct_low_idx,high_idx));


mysets = ["CT","low","high"];
mylabels = [109 109 109 ct_low ct_high low_high ct_low_high];

% figure;
venn(3,'sets',mysets,'labels',mylabels,'colors',[1 1 1; 1 1 1; 1 1 1],'alpha',0,'edgeC',[0 0 0],'edgeW',1)
% venn(3,'sets',mysets,'labels',mylabels)