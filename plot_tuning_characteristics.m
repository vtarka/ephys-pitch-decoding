

bin_size = 10;

load('kernels_10ms.mat')
load('lin_decoder_format_10ms.mat')
%% get ranks
stims_to_plot = [1 11 10 13]; % CT0, low, high, tone
stims_to_plot = [1 5 2 3 8 11 10 9 12 13];

load('Type')
stim_labels = unique(type);

% colours = zeros(length(stims_to_decode),1085,4);

cmap = turbo(1085);
cmap = flip(cmap);

onset_neuron_bool = zeros(1085,length(stims_to_plot));

all_s_importance = cell(length(stims_to_plot),1);

ranks = zeros(1085,length(stims_to_plot));
importances = zeros(1085,length(stims_to_plot));

for ss = 1:length(stims_to_plot)

    this_stim_k = kernels{stims_to_plot(ss)};

    % take the best fold
    [~,best_fold_idx] = get_best_RMSE(this_stim_k);
    best_fold = this_stim_k{best_fold_idx};
    best_fold_kernel = best_fold.kernel.k_fh;

    best_fold_kernel = best_fold_kernel(1:1085,:);

    importance = sum(abs(best_fold_kernel),2);
    [~,i] = max(abs(best_fold_kernel),[],2);

    if bin_size==10
        onset_neuron_bool(:,ss) = i<=20;
    elseif bin_size==50
        onset_neuron_bool(:,ss) = i<=4;
    else
        error('invalid bin size')
    end

    neuron_list = 1:1085;
    [importance_sorted,rank] = sort(importance,'descend');

    [~,i] = sort(rank,'ascend');
    b = neuron_list(i)';
    ranks(:,ss) = b;
    importances(:,ss) = importance;

    all_s_importance{ss} = {rank, importance};

end

%%

figure;
n_neurons = 109;
n_stims = length(stims_to_plot);
cmap = hsv(length(stims_to_plot));

rs = zeros(n_neurons,n_stims,n_stims);
errs = zeros(n_neurons,n_stims,n_stims);
top_neuron_bool = zeros(size(rs));

for i = 1:n_neurons
    for s = 1:n_stims

        rank_i = find(ranks(:,s)==i);

        s_onset_bool = onset_neuron_bool(rank_i,s);

        if s_onset_bool
            if bin_size==10
                window = 1:10;
            elseif bin_size==50
                window = 1:2;
            end
        else
            if bin_size==10
                window = 20:29;
            elseif bin_size==50
                window = 5:6;
            end
        end

        tcs = zeros(n_stims,15);
        
        for ss = 1:n_stims
            s_rank = ranks(rank_i,ss);
            top_neuron_bool(i,s,ss) = s_rank<109;
            tcs(ss,:) = get_single_neuron_tuning_curve(X_nwt,stim_key,F0_key,stims_to_plot(ss),rank_i,window);
        end

        for ss = 1:n_stims
            rs(i,s,ss) = corr(tcs(s,:)',tcs(ss,:)');
        end
    end
end


% %% plot  3d
% 
% for i = 1:n_neurons
% 
%     for s = 1:n_stims
% 
%         subplot(1,n_stims,s)
%         hold on
% 
%         if ss==s
%             continue
%         end
% 
%         this_stim_corrs = squeeze(rs(i,s,:));
%         idx = 1:n_stims;
%         idx_to_include = idx~=s;
%         this_stim_corrs = this_stim_corrs(idx_to_include);
% 
%         scatter3(this_stim_corrs(1),this_stim_corrs(2),this_stim_corrs(3),'k')
%     end
% end


%% plot histograms

titles = {'CT','CT5','CT10','CT20','MF','low','high','alt','rand','tone'};
figure;

cm_guide = jet(15);

cm = zeros(n_stims,3);
cm(1:5,:) = cm_guide(1:5,:);
cm(6,:) = cm_guide(8,:);
cm(7:9,:) = cm_guide(11:13,:);

average_corrs = nan(n_stims);
errs = nan(n_stims);

for ss = 1:n_stims
    for s = 1:n_stims

        if ss == s
            continue
        end

        % figure(99)
        % 
        % subplot(n_stims,n_stims,((ss-1)*n_stims)+s)



        this_stim_corrs = rs(:,ss,s);
        this_stim_corrs_to_plot = this_stim_corrs;
        this_stim_corrs_to_plot = this_stim_corrs(top_neuron_bool(:,ss,s)==1);

        average_corrs(ss,s) = mean(this_stim_corrs_to_plot);
        errs(ss,s) = std(this_stim_corrs_to_plot) / sqrt(length(average_corrs));
        % 
        % histogram(this_stim_corrs_to_plot,-1:0.1:1)
        % 
        % hold on
        % xline(mean(this_stim_corrs_to_plot),'k:','linewidth',2)
        % title(sprintf('%s %s',titles{ss},titles{s}))
    end

    figure(100)
    hold on
    errorbar(1:n_stims,average_corrs(ss,:),errs(ss,:),'*-','linewidth',2,'color',cm(ss,:),'markersize',10)
end

figure(100)
xticks(1:n_stims)
xticklabels(titles)
ylim([-0.6 0.7])
xlim([1 10])
% l = legend(titles,'location','southwest','numcolumns',5);
set(gca,'fontsize',14)
% title(l,'high ranking neuron stimulus')
xlabel('stimulus where this neuron also ranks highly')
ylabel('F0-tuning correlation')

function f0_tuning = get_single_neuron_tuning_curve(X_nwt,stim_key,F0_key,stim,unit,window)

stim_key = stim_key(1,:);
this_stim = find(stim_key==stim);
X_nwt_su = squeeze(X_nwt(unit,:,this_stim));

F0_key = F0_key(1,this_stim);
unique_F0s = unique(F0_key);

f0_tuning = zeros(length(unique_F0s),1);

for ff = 1:length(unique_F0s)

    this_ff = find(F0_key == unique_F0s(ff));
    
    X_nwt_su_ff = X_nwt_su(:,this_ff);

    n_spikes = sum(X_nwt_su_ff(window,:),1);

    f0_tuning(ff) = mean(n_spikes);

end
end