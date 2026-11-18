
load('kernels_10ms.mat')
% stims = [1 5 2 3 8 11 10 9 12 13];
stims_to_include = [8 1 5 2 3 11 10 9 12 13];
% kernels = kernels(stims);

% labels = {'click train (CT)','CT 5% jitter','CT 10% jitter','CT 20% jitter','missing F0','resolved harmonics','unresolved harmonics','alternating phase','random phase','pure tone'};
labels = {'MF','CT','CT 5%','CT 10%','CT 20%','Res. Harm.','Unres. Harm.','Alt. Phase','Rand. Phase','Tone'};
for s = 1:length(stims_to_include) %length(kernels)

    this_stim_res = kernels{stims_to_include(s),1}; % decoding kernel for this stimulus
    this_stim_kernel = this_stim_res;
    % this_stim_kernel = kernels{s};

    test_errs = zeros(length(this_stim_kernel),1);
    test_ccs = zeros(length(this_stim_kernel),1);

    train_errs = zeros(size(test_errs));
    train_ccs = zeros(size(test_ccs));

    for f = 1:length(this_stim_kernel)

        % [~,fold_number] = get_best_RMSE(this_stim_res); % get the best error and fold number
        % best_fold = this_stim_res{fold_number}; % get just the best kernel

        this_fold = this_stim_kernel{f};
        % this_fold = best_fold;

        test_targets = this_fold.target(this_fold.test_idx);
        test_predictions = this_fold.prediction(this_fold.test_idx);

        [~,this_fold_err] = get_octave_rmse(test_targets,test_predictions,'logHz');
        this_fold_cc = this_fold.cc_test;

        test_errs(f) = mean(this_fold_err);
        test_ccs(f) = this_fold_cc;


        train_targets = this_fold.target(this_fold.train_idx);
        train_predictions = this_fold.prediction(this_fold.train_idx);

        [~,this_fold_err] = get_octave_rmse(train_targets,train_predictions,'logHz');
        this_fold_cc = this_fold.cc_train;

        train_errs(f) = mean(this_fold_err);
        train_ccs(f) = this_fold_cc;
    end

    % [~,sort_order] = sort(test_errs);
    
    figure(1);
    subplot(2,5,s)
    hold on
    plot(test_errs,'marker','*','color','blue','linewidth',3)
    plot(train_errs,'marker','*','color','black','linewidth',3)
    yline(mean(test_errs),'linestyle',':','color','blue','linewidth',2)
    yline(mean(train_errs),'linestyle',':','color','black','linewidth',2)

    yline(1,'linestyle',':','Color','black','linewidth',2)
    ylim([0 1.2])
    ylabel('error (octave)')
    % xlim([0 6])
    xticks(1:5)
        xlabel('fold')
    fontname('Helvetica Light')
    title(labels{s})
    hold off

    figure(2);
    subplot(2,5,s)
    hold on
    plot(test_ccs,'marker','*','color','blue','linewidth',3)
    plot(train_ccs,'marker','*','color','black','linewidth',3)
    yline(mean(test_ccs),'linestyle',':','color','blue','linewidth',2)
    yline(mean(train_ccs),'linestyle',':','color','black','linewidth',2)

    ylim([0.8 1])
    ylabel('CC')
    xlim([1 5])
    xticks(1:5)
    xlabel('fold')
    fontname('Helvetica Light')
    set(gca,'fontsize',12)
    title(labels{s})
    hold off
    

end