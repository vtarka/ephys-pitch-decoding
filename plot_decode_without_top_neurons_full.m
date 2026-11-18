% load('decode_wo_top_neurons_1_by_1_feb26_full_3')
% firstkernels = kernels(:,:,1:5);
% firsterrs = errs(:,:,1:5);
% 
% %%
% 
% load('decode_wo_top_neurons_1_by_1_feb26_second100')
% secondkernels = kernels(:,:,1:5);
% seconderrs = errs(:,:,1:5);
% 
% %%
% load('decode_wo_top_neurons_1_by_1_july26_200thru1000_5_repeats.mat')
% thirdkernels = kernels;
% thirderrs = errs;
% 
% %%
% 
% kernels = cat(2,firstkernels,secondkernels,thirdkernels);
% errs = cat(2,firsterrs,seconderrs,thirderrs);

% load('decode_w_top_neurons_1_by_1_feb26_full200')

% 
% load('decode_wo_top_neurons_sept26.mat')
% firstkernels = kernels(1:5,:,:);
% firsterrs = errs(1:5,:,:);
% 
% load('decode_wo_top_neurons_sept26_stims6-10.mat')
% secondkernels = kernels(6:10,:,:);
% seconderrs = errs(6:10,:,:);
% 
% kernels = cat(1,firstkernels,secondkernels);
% errs = cat(1,firsterrs,seconderrs);

load('decode_w_top_neurons_sept26.mat')
%% convert to octave errors

% kernels(:,201,:) = [];
% errs(:,201,:) = [];
% stims_to_decode = [1 5 2 3 8 11 10 9 12 13];
stims_to_decode = 1:10;
n_repeats = 5;
n_steps = size(kernels,2);

load('Type')
stim_labels = unique(type);

octave_errs = zeros(size(errs));

for s = 1:length(stims_to_decode)

    for i = 1:n_steps
        
        for ii = 1:n_repeats

             model =  kernels{s,i,ii};

             if isempty(model)
                 abc=1;
             end
    
            [~,f] = get_best_RMSE(model);
            best_kernel = model{f};
            octave_errs(s,i,ii) = get_octave_rmse(best_kernel.target(best_kernel.test_idx),best_kernel.prediction(best_kernel.test_idx),'logHz');
            [octave_diffs] = get_octave_rmse(best_kernel.target(best_kernel.test_idx),best_kernel.prediction(best_kernel.test_idx),'logHz');

            octave_errs(s,i,ii) = octave_diffs;
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

    final_errs = this_s_errs(75:100);

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


%%

steps = [1:200 300:100:1000];

octave_errs = octave_errs_avg;
figure;

cm_guide = jet(15);

stims_to_include = [1 5 2 3 8 11 10 9 12 13];
% stims_to_include = label_order;

cm = zeros(length(stims_to_include),3);
cm(1:5,:) = cm_guide(1:5,:);
cm(6,:) = cm_guide(7,:);
cm(7:9,:) = cm_guide(11:13,:);
cmap = cm([1 6 8 10],:);

lines = [];

groups = cell(4,1);
groups{1} = [1 2 3 4 5];
groups{2} = 6;
groups{3} = [7 8 9];
groups{4} = 10;

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

    % shadedErrorBar(1:n_steps,avg_group_errs(1:n_steps),std_group_errs(1:n_steps),{'linewidth',2,'color',cmap(g,:)},1);

    % shadedErrorBar(log(steps(1:200)),avg_group_errs(1:200),std_group_errs(1:200),{'linewidth',2,'color',cmap(g,:)},1);
    shadedErrorBar((steps(1:200)),avg_group_errs(1:200),std_group_errs(1:200),{'linewidth',2,'color',cmap(g,:)},1)
    hold on

    extra_dots = 201:208; % this is 300:100:1000 exclusion
    extra_dot_idx = 225:25:400;
    extra_dot_idx = 230:10:300;

    for ed = 1:length(extra_dots)

        % plot(log(steps(ed)),avg_group_errs(ed),'color',cmap(g,:),'marker','o','markersize',5,'linewidth',2)
        % errorbar(log(steps(ed)),avg_group_errs(ed),std_group_errs(ed),'color',cmap(g,:),'linewidth',2)

        plot(extra_dot_idx(ed),avg_group_errs(extra_dots(ed)),'color',cmap(g,:),'marker','o','markersize',5,'linewidth',2)
        if g==1 || g==3
            errorbar(extra_dot_idx(ed),avg_group_errs(extra_dots(ed)),std_group_errs(extra_dots(ed)),'color',cmap(g,:),'linewidth',2)
        end
    end

    % shadedErrorBar(extra_dot_idx,avg_group_errs(extra_dots),std_group_errs(extra_dots),{'color',cmap(g,:),'linewidth',2},1)
    % breakplot(steps,avg_group_errs,200,850,'Line',100)

    % BreakXAxis(steps,avg_group_errs,200,960,6)

    final_errs = avg_group_errs(175:200);

    

    max_err = mean(final_errs);
    err_diff = 1-max_err;
    max_90 = 1 - (err_diff*0.9);

    % max_85 = max_err - max_err*0.15;

    [~,i] = min(abs(avg_group_errs - max_90));

    disp(i)

    hold on
    % xline(i,'--','color',cmap(g,:),'linewidth',2)
end

% legend(lines,{'CT','low','high','tone'})

xlabel('# of neurons included')
ylabel('error (octave)')
fontname('helvetica light')
% xticks(log([1 3 10 30 100 300 1000]))
% xticklabels([1 3 10 30 100 300 1000])

% xlim([1 275])
% xticks(0:50:400)
% xticklabels([0:50:200 300:100:1000])

xticks([0:50:200 230:10:300])
xticklabels([0:50:200 300:100:1000])


%%

% figure(10)
% t = tiledlayout(1,9,'TileSpacing','compact');
% bgAx = axes(t,'XTick',[],'YTick',[],'Box','off');
% bgAx.Layout.TileSpan = [1 2];
% 
% steps = [1:200 300:100:1000];
% 
% octave_errs = octave_errs_avg;
% figure;
% 
% cm_guide = jet(15);
% 
% stims_to_include = [1 5 2 3 8 11 10 9 12 13];
% % stims_to_include = label_order;
% 
% cm = zeros(length(stims_to_include),3);
% cm(1:5,:) = cm_guide(1:5,:);
% cm(6,:) = cm_guide(7,:);
% cm(7:9,:) = cm_guide(11:13,:);
% cmap = cm([1 6 8 10],:);
% 
% lines = [];
% 
% groups = cell(4,1);
% groups{1} = [1 2 3 4 5];
% groups{2} = 6;
% groups{3} = [7 8 9];
% groups{4} = 10;
% 
% for g = 1:length(groups)
% 
%     this_group_stims = groups{g};
% 
%     this_group_errors = zeros(length(this_group_stims),size(octave_errs,2));
% 
%     for s = 1:length(this_group_stims)
% 
%         this_s_errs = octave_errs(this_group_stims(s),:);
%         this_group_errors(s,:) = this_s_errs;
% 
%     end
% 
%     avg_group_errs = mean(this_group_errors);
%     std_group_errs = std(this_group_errors) / sqrt(size(this_group_errors,1));
% 
%     if size(this_group_errors,1)==1
%         avg_group_errs = this_group_errors(1,:);
%         std_group_errs = zeros(1,n_steps);
%     end
% 
%     x = -50*pi:0.1:50*pi;
%     y=10*sin(0.1*x);
% 
%     ax1 = axes(t);
%     plot(ax1,x,y)
%     xline(ax1,15,':');
%     ax1.Box = 'off';
%     xlim(ax1,[-100 -70])
%     xlabel(ax1, 'First Interval')
% 
%     % Create second plot
%     ax2 = axes(t);
%     ax2.Layout.Tile = 2;
%     plot(ax2,x,y)
%     xline(ax2,45,':');
%     ax2.YAxis.Visible = 'off';
%     ax2.Box = 'off';
%     xlim(ax2,[70 100])
%     xlabel(ax2,'Second Interval')
% 
%     % Link the axes
%     linkaxes([ax1 ax2], 'y')
%     title(t,'Attenuated Cosine Function')
% 
%     % shadedErrorBar(1:n_steps,avg_group_errs(1:n_steps),std_group_errs(1:n_steps),{'linewidth',2,'color',cmap(g,:)},1);
% 
%     shadedErrorBar(log(steps),avg_group_errs(1:n_steps),std_group_errs(1:n_steps),{'linewidth',2,'color',cmap(g,:)},1);
% 
%     final_errs = avg_group_errs(175:200);
% 
%     max_err = mean(final_errs);
%     err_diff = 1-max_err;
%     max_90 = 1 - (err_diff*0.9);
% 
%     % max_85 = max_err - max_err*0.15;
% 
%     [~,i] = min(abs(avg_group_errs - max_90));
% 
%     disp(i)
% 
%     hold on
%     % xline(i,'--','color',cmap(g,:),'linewidth',2)
% end
% 
% % legend(lines,{'CT','low','high','tone'})
% 
% xlabel('# of neurons included')
% ylabel('error (octave)')
% fontname('helvetica light')