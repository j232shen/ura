function [filtered_emg] = filter_emg(muscleTrials)
% This function takes the 2D trials matrix for one muscle, filters each
% signal, and then returns a 2D matrix of the filtered signals.
    
    % EMG sampling frequency
    fs = 2000; 
    [b, a] = butter(4, [30 500]/(fs/2), 'bandpass'); 

    % filtering emg
    filtered_emg = zeros(size(muscleTrials));
    for i = 1:size(muscleTrials, 1) % for each row
        signal = muscleTrials(i,:);

        bpf = filtfilt(b, a, signal); % band pass filter
        hwr = abs(detrend(bpf)); % getting rid of offset + half wave rectifier

        % moving window average -> creating envelope
        window_length = 75;
        filtered_emg(i,:) = movmean(hwr, window_length);
    end
end