function [filtered_mvc] = filter_mvc(mvc)
% This function takes the 1D signal array for MVC trial, filters each
% the trial, and then returns a 1D filtered signal array.
    
    % EMG sampling frequency
    fs = 2000; 
    [b, a] = butter(4, [30 500]/(fs/2), 'bandpass'); 

    % filtering EMG
    filtered_mvc = zeros(size(mvc));

    bpf = filtfilt(b, a, mvc); % band pass filter
    hwr = abs(detrend(bpf)); % getting rid of offset + half wave rectifier

    filtered_mvc = hwr;
    
    % moving window average -> creating envelope
    % filtered_mvc = movmean(lpf, 10);
end