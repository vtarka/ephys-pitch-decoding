function [octave_rmse,octave_differences] = get_octave_rmse(target_F0,predicted_F0,label_type)

if strcmp(label_type,'int') % use if decoding with integer labels for the F0s
    Flist = [250 297 354 420 500 595 707 841 1000 1189 1414 1682 2000 2378 2828 3364 4000];
    t = Flist(target_F0);
    p = Flist(predicted_F0);
elseif strcmp(label_type,'Hz') % use if decoding from the exact F0
    t = target_F0;
    p = predicted_F0;
elseif strcmp(label_type,'logHz') % use if decoding from log(F0)
    t = exp(target_F0);
    p = exp(predicted_F0);
end

octave_errors = ones(size(t));
octave_differences = ones(size(t));

for i = 1:length(t)

    octave_differences(i) = octaves(t(i),p(i));
    octave_errors(i) = octaves(t(i),p(i))^2;

end

sum_octave_errors = sum(octave_errors);

octave_rmse = sqrt(sum_octave_errors/length(target_F0));
end