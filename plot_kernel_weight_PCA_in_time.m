load('kernels_10ms')

bin_size = 25;

nneurons = size(kernels{1}{1}.kernel.k_fh,1);
nwindows = size(kernels{1}{1}.kernel.k_fh,2);


% label_order = [1 5 2 3 4 8 11 7 6 10 9 12 13];
label_order = [1 5 2 3 8 11 10 9 12 13];

weights = zeros(nneurons,nwindows,length(label_order));

stim_key = zeros(size(weights));

for ss = 1:length(label_order) % for each stimulus

    this_stim_k = kernels{label_order(ss)};

    % take the best fold
    [~,best_fold_idx] = get_best_RMSE(this_stim_k);
    best_fold = this_stim_k{best_fold_idx};
    best_fold_kernel = best_fold.kernel.k_fh;

    weights(:,:,ss) = best_fold_kernel;
    stim_key(:,:,ss) = label_order(ss);
end

%% PCA

weights_2D = reshape(weights,nneurons,[]);
stim_key = reshape(stim_key,nneurons,[]);
stim_key_vector = stim_key(1,:);

[coeff,scores,latent,~,explained] = pca(weights_2D');

%% plot

cm_guide = jet(15);

stims_to_include = [1 5 2 3 8 11 10 9 12 13];
% stims_to_include = label_order;

cm = zeros(length(stims_to_include),3);
cm(1:5,:) = cm_guide(1:5,:);
cm(6,:) = cm_guide(8,:);
cm(7:9,:) = cm_guide(11:13,:);

% coeff = coeff';
% scores = scores';
% cm = jet(length(label_order));

dims = [1 2 3];
% dims = 4:10;

figure; hold on

for dd = 1:length(dims)

    % subplot(1,length(dims),dd); hold on
    nexttile
    hold on

    for ss = 1:length(label_order)

        this_stim_scores = scores(stim_key_vector==label_order(ss),:);
        this_stim_scores_d = this_stim_scores(:,dims(dd));

        plot(movmean(this_stim_scores_d,2),'linewidth',2,'color',cm(ss,:)); %% used 7 for 10 ms
        % plot(this_stim_scores_d,'linewidth',2,'color',cm(ss,:));

    end

    % xticks(0:5:35)
    % xticklabels(0:50:350)
    % 
    xticks(0:10:30)
    xticklabels(0:100:300)
    % 
    % xticks(0:8)
    % xticklabels(0:50:300)
    xlabel('ms after onset')

    axis tight
    xline(20,':','linewidth',2)

    set(gca,'fontsize',14)
    fontname('Helvetica Light')

    title(sprintf('PC %d (%.1f%% var.)',dims(dd),explained(dims(dd))))
end

% ax3 = subplot(1,3,3);
% ax3_pos = get(ax3,'position');
% 
% load('Type')
% stim_labels = unique(type);
% legend(stim_labels(label_order),'location','eastoutside','fontsize',8)
% set(ax3,'position',ax3_pos)

% for ss = 1:length(kernels)
% 
%     this_stim_scores = scores(stim_key_vector==label_order(ss),:);
%     this_stim_scores_d = this_stim_scores(:,dd);
%     this_stim_scores = movmean(this_stim_scores,3,1);
% 
%     plot3(this_stim_scores(:,1),this_stim_scores(:,2),this_stim_scores(:,3),'linewidth',2,'color',cm(ss,:));
% 
% end
% 
% 
% load('Type')
% stim_labels = unique(type);
% legend(stim_labels(label_order),'location','eastoutside','fontsize',8)

%% plot onset and offset codes separately

% cm_guide = jet(25);
% 
% stims_to_include = [1 5 2 3 8 11 10 9 12 13];
% % stims_to_include = label_order;
% 
% cm = zeros(length(stims_to_include),3);
% cm(1:4,:) = repmat(cm_guide(1,:),4,1);
% cm(5:6,:) = repmat(cm_guide(6,:),2,1);
% cm(7:9,:) = repmat(cm_guide(10,:),3,1);

% cm = zeros(length(stims_to_include),3);
% cm(1:5,:) = cm_guide(2:6,:);
% cm(6,:) = cm_guide(11,:);
% cm(7:9,:) = cm_guide(18:20,:);
% cm(10,:) = cm_guide(25,:);

% cm = jet(13);

dims = [1 2 3];

figure; hold on

windows = [1 19;19 40];
% windows = [1 6; 7 14];
% windows = [1 4;4 8];

for i = 1:2 % for onset and offset

    subplot(1,3,i); hold on

    % figure; hold on

    w = windows(i,1):windows(i,2);

    for ss = 1:length(stims_to_include)
    
        this_stim_scores = scores(stim_key_vector==stims_to_include(ss),:);
        % this_stim_scores = smoothdata(this_stim_scores);
        this_stim_scores = movmean(this_stim_scores,6,1);

        % if i==1
            plot3(this_stim_scores(w,dims(1)),this_stim_scores(w,dims(2)),this_stim_scores(w,dims(3)),'linewidth',3,'color',cm(ss,:));
        % else
            % plot3(this_stim_scores(w,dims(1)),this_stim_scores(w,dims(2)),this_stim_scores(w,dims(3)),'linewidth',3,'color',cm(ss,:));
        % end
       
    
    end

    % xticks([])
    % yticks([])
    % zticks([])
    % 
    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')
    grid on

    set(gca,'fontsize',16)
end


subplot(1,3,3); hold on
set(gca,'fontsize',14)

% plot onset and offset together
for ss = 1:length(stims_to_include)

    this_stim_scores = scores(stim_key_vector==stims_to_include(ss),:);
    this_stim_scores = movmean(this_stim_scores,6,1);

    w = windows(1,1):windows(1,2);

    plot3(this_stim_scores(w,dims(1)),this_stim_scores(w,dims(2)),this_stim_scores(w,dims(3)),'linewidth',3,'color',cm(ss,:));
    
    
    w = windows(2,1):windows(2,2);

    plot3(this_stim_scores(w,dims(1)),this_stim_scores(w,dims(2)),this_stim_scores(w,dims(3)),':','linewidth',3,'color',cm(ss,:));


    % xticks([])
    % yticks([])
    % zticks([])

end

    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')

grid on

% ax1 = subplot(1,3,1);
% ax1_pos = get(ax1,'position');
% 
% load('Type')
% stim_labels = unique(type);
% legend(stim_labels(stims_to_include),'location','westoutside','fontsize',8)
% set(ax1,'position',ax1_pos)
title('onset')

subplot(1,3,3)
title('offset')
fontname('helvetica light')


% add marker style legend
% ax3 = subplot(1,3,3);
% ax3_pos = get(ax3,'position');

% h = zeros(2,1);
% % for hh = 1:length(h)
% % 
% %     if hh <= 0
% %         h(hh) = plot(NaN,NaN,'color',cm(hh,:),'linewidth',5);
% %         labels{hh} = string(Flist(hh));
% %     else
% %        h(hh) = plot(NaN,NaN,'color','k','marker',marker_options{hh},'markersize',25,'linewidth',1.5); 
% %        labels{hh} = stim_labels{hh};
% %     end
% % end
% 
% h(1) = plot(NaN,NaN,'k','linewidth',2); 
% h(2) = plot(NaN,NaN,'k:','linewidth',2); 
% 
% l = legend(h,{'onset','offset'},'location','eastoutside');
% 
% set(ax3,'position',ax3_pos)

%% remove xtick labels
% 
for i = 1:3
    subplot(1,3,i)
    xticklabels({})
    yticklabels({})
    zticklabels({})
end
