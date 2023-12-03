function [features] = get_features(normTrials, n)
    % you don't actually have to vary the muscle you're accessing...
    % they're all the same length
    features = struct('bicep', [], ...
        'tricep', [], ...
        'delt', [], ...
        'trap', [], ...
        'pecMajor', [], ...
        'infra', []);

    % 'n' is the input for # of windows
    window_length = (length(normTrials.bicep)/(n + 1))*2; % no point flooring this if you have to floor windowStart and windowEnd anyway... right???

    % calculate window length in ms
    fs = 1925.9;
    t = (window_length/fs)*1000;

    features.bicep = get_windows(normTrials.bicep, n, window_length);
    features.tricep = get_windows(normTrials.tricep, n, window_length);
    features.delt = get_windows(normTrials.delt, n, window_length);
    features.trap = get_windows(normTrials.trap, n, window_length);
    features.pecMajor = get_windows(normTrials.pecMajor, n, window_length);
    features.infra = get_windows(normTrials.infra, n, window_length);
end