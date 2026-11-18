% load('kernels_10ms_stim_rename.mat')
load('kernels_10ms.mat')
% load('kernels_top_150.mat')
% kernels = best_size_kernels;
load('Flist')
figure;
stims_to_include = [8 1 5 2 3 11 10 9 12 13];
% stims_to_include = [5 1:4 6:10];
titles = {'MF','CT','CT 5%','CT 10%','CT 20%','Res. Harm.','Unres. Harm.','Alt. Phase','Rand. Phase','Tone'};

plot_idx = [1 3 5 7 9 2 4 6 8 10];

errs = zeros(length(stims_to_include),2);
ccs = zeros(length(stims_to_include),2);

for s = 1:length(stims_to_include) % for each stimulus (training stimulus)
    this_stim_res = kernels{stims_to_include(s),1}; % decoding kernel for this stimulus

    [~,fold_number] = get_best_RMSE(this_stim_res); % get the best error and fold number
    best_fold = this_stim_res{fold_number}; % get just the best kernel

    test_targets = best_fold.target(best_fold.test_idx);
    test_predictions = best_fold.prediction(best_fold.test_idx);

    train_targets = best_fold.target(best_fold.train_idx);
    train_predictions = best_fold.prediction(best_fold.train_idx);

    subplot(2,5,s)
    hold on
    plot(train_targets,train_predictions,'k.','marker','+','markersize',3)
    plot(test_targets,test_predictions,'k.','marker','o','markersize',3)
    title(titles{s})

    xlim([5.8 8.4])
    ylim([5.8 8.4])


    plot([5.8 8.4],[5.8 8.4],'k:')

    xticks(log(Flist(5:4:17)))
    xticklabels(Flist(5:4:17))

    yticks(log(Flist(5:4:17)))
    yticklabels(Flist(5:4:17))

    % text(7, 6.3, sprintf('CC (train): %.2f',best_fold.cc_train),'FontSize',8,'color','k')
    % text(7, 6.1, sprintf('CC (test): %.2f',best_fold.cc_test),'FontSize',8,'color','k')
    fontname('helvetica light')

    ccs(s,1) = best_fold.cc_train;
    ccs(s,2) = best_fold.cc_test;

    [~,octave_diffs_train] = get_octave_rmse(train_targets,train_predictions,'logHz');
    [~,octave_diffs_test] = get_octave_rmse(test_targets,test_predictions,'logHz');

    errs(s,1) = mean(octave_diffs_train);
    errs(s,2) = mean(octave_diffs_test);

    text(7, 6.3, sprintf('err (train): %.2f',errs(s,1)),'FontSize',8,'color','k')
    text(7, 6.1, sprintf('err (test): %.2f',errs(s,2)),'FontSize',8,'color','k')

    if s==6
        xlabel('actual F0')
        ylabel('predicted F0')
    end
    % set(gca,'fontsize',12)
end