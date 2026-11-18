load('lin_decoder_format_10ms.mat')

example_trials = 6:10;
n_example_trials = length(example_trials);

figure;

n_example_trials = 5;

example_trials = randi(2535,n_example_trials,1);

for t = 1:n_example_trials
    % 
    % trial_onset_window = 35*(t-1)+1;
    % trial_offset_window = trial_onset_window + 35;

    trial_data = X_nwt(:,1:40,example_trials(t));
    % trial_data = smoothdata(trial_data,2,'movmean',2);

    subplot(1,n_example_trials,t)
    imagesc(trial_data)

    xticks(10:10:30)
    yticks(200:200:1000)
end

t = colormap('turbo');
t(1:4,:) = repmat([1 1 1],4,1);
t(5:265,:) = repmat([0 0 0], length(5:265),1);
colormap(t)

%% plot kernel

load('kernels_10ms')
figure;
n_kernels = 5;

stims = [1 5 2 3 8 11 10 9 12 13];
deep_red = [214 0 0] / 255;
mid_red = [255 72 72] / 255;
mid_blue = [6 8 255] / 255;
deep_blue = [66 68 255] / 255;
white = [1 1 1];
cm = [deep_red; mid_red; white; white; white; mid_blue; deep_blue];
t = customcolormap([0 0.25 0.45 0.5 0.55 0.75 1],cm,128);

for s = 1:length(stims)
    CT = kernels{stims(s)};
    
    [~,f] = get_best_RMSE(CT);
    
    fold = CT{f};
    
    kernel = fold.kernel.k_fh;
    kernel = movmean(kernel,2,2);
    ordering = 1:size(kernel,1);

    if s==0

        [~,imax] = max(abs(kernel),[],2);
        max_weights = zeros(size(kernel,1),1);
    
        for i = 1:size(kernel,1)
            max_weights(i) = kernel(i,imax(i));
        end
    
        pos_weights = kernel(max_weights>0,:);
        pos_idx = find(max_weights>0);

        neg_weights = kernel(max_weights<0,:);
        neg_idx = find(max_weights<0);

        zero_weights = kernel(max_weights==0,:);
        zero_idx = find(max_weights==0);
    
        [~,imax_i_descend_pos] = sort(imax(max_weights>0),'ascend');
        [~,imax_i_descend_neg] = sort(imax(max_weights<0),'ascend');
        [~,imax_i_descend_zero] = sort(imax(max_weights==0),'ascend');
    
        % kernel_to_plot = [pos_weights(imax_i_descend_pos,:); neg_weights(imax_i_descend_neg,:); zero_weights(imax_i_descend_zero,:)];
        ordering = [pos_idx(imax_i_descend_pos); neg_idx(imax_i_descend_neg); zero_idx(imax_i_descend_zero)];
        kernel_to_plot = kernel(ordering,:);
    else
        kernel_to_plot = kernel(ordering,:);
    end

    % kernel_to_plot = kernel(imax_i_descend,:);

    % [~,i_i] = sort(imax,'ascend');
    % kernel_to_plot = kernel_to_plot(i_i,:);
    % 
    nexttile;
    imagesc(kernel_to_plot)
    colormap(t)
    
    % colormap(flipud(colormap(slanCM('RdBu'))))

    % clim([-max(max_weights) max(max_weights)])
    clim([-1.5 1.5]*0.0001)
    xticks([])
    yticks([])
    % xticks(10:10:30)
    % xticklabels(100:100:300)
    % yticks(200:200:800)
end

