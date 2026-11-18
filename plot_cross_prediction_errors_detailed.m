
% %stimList:         'CT0'    'CT10'    'CT20'    'CT40'    'CT5'    'F0MaskHigh'    'F0MaskLow'    'allHarm'      'alt'     'high'    'low'    'rand'    'tone'
% %  # (Noah #)       1       2          3         4        5             6            7             8 (9)       9 (11)    10 (12)   11 (13)  12 (14)   13 (15)


pen = 'P04';
load('cross_prediction_errors_10ms')
bigtitle = 'all pens no time';

load('Flist')
load('Type')

% label_order = [1 5 2 3 4 8 11 7 6 10 9 12 13];
label_order = 1:10;

% spikes_file = ['D:/Ferret_Data/'...
%     animal '/Batch0824/Spikes_' animal '_' pen '_Good_Pitch.mat'];

% load(spikes_file,'F0','type')

% load('Type')
% load('Flist')

stim_order = [1 5 2 3 4 8 11 7 6 10 9 12 13];
% stim_order = 1:10;

err = err(stim_order,stim_order);

stim_labels = unique(type);
stim_labels = stim_labels(label_order);

stim_labels = {'click train (CT)','CT 5% jitter','CT 10% jitter','CT 20% jitter',...
    'missing fundamental','low harmonics','high harmonics','alternating phase','random phase','tone'};

fsize=12;

%% plot the cross-prediction error matrix (with whatever subset of stim are desired)

stim = 1:13;
stim = [1:4 6:7 10:13];
stim = 1:10;
% err = err(stim,stim);

figure;
ax(1) = subplot(1,2,1);
imagesc(err(stim,stim))
stim = 1:10;
xticks(1:length(stim))
xticklabels(stim_labels(stim))
yticks(1:length(stim))
yticklabels(stim_labels(stim))
cb = colorbar;
t = ylabel(cb, 'RMSE','Rotation',270,'fontsize',fsize);
pos = get(t,'position');
set(t,'position',[pos(1)+1 pos(2:end)])
set(gca,'fontsize',fsize)
xlabel('Test')
ylabel('Train')
colormap(flipud(parula))

%%
% normalize to how well the set does on itself
stim = [1:4 6:7 10:13];
% stim = 1:10;
norm_err = err;
for ss = stim
    for s = stim
        norm_err(s,ss) = err(s,ss) / err(ss,ss);
    end
end

sub_norm_err = norm_err(stim,stim);
max_err = max(max(abs(sub_norm_err)));
min_err = min(min(sub_norm_err));

ax(2) = subplot(1,2,2);
imagesc(norm_err(stim,stim))
stim = 1:10;
xticks(1:length(stim))
xticklabels(stim_labels(stim))
yticks(1:length(stim))
yticklabels(stim_labels(stim))
cb = colorbar;
% clim([-max_err max_err])
clim([min_err max_err])
colormap(ax(2),flipud(colormap(parula)))
% colormap(ax(2),customcolormap_preset('red-white-blue'))
t = ylabel(cb,'norm. RMSE','Rotation',270,'fontsize',fsize);
pos = get(t,'position');
set(t,'position',[pos(1)+0.5 pos(2:end)])
set(gca,'fontsize',fsize)
xlabel('Test')
ylabel('Train')


sgtitle(bigtitle)

