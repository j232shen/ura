% function returns normalized emg signal given a raw emg signal and the
% corresponding mvc signal.

function [normTrials] = get_norm(trials, MVC)
    normTrials = struct('bicep', zeros(size(trials.bicep)), ...
        'tricep', zeros(size(trials.tricep)), ...
        'delt', zeros(size(trials.delt)), ...
        'trap', zeros(size(trials.trap)), ... 
        'pecMajor', zeros(size(trials.pecMajor)), ...
        'infra', zeros(size(trials.infra)));

    %% filtering EMG signals
    filtered_bicep = filter_emg(trials.bicep);
    filtered_tricep = filter_emg(trials.tricep);
    filtered_delt = filter_emg(trials.delt);
    filtered_trap = filter_emg(trials.trap);
    filtered_pecMajor = filter_emg(trials.pecMajor);
    filtered_infra = filter_emg(trials.infra);

    % filtering MVC
    filtered_mvc_bicep = filter_mvc(MVC(1,:)); 
    filtered_mvc_tricep = filter_mvc(MVC(5,:));
    filtered_mvc_delt = filter_mvc(MVC(9,:));
    filtered_mvc_trap = filter_mvc(MVC(13,:));
    filtered_mvc_pecMajor = filter_mvc(MVC(17,:));
    filtered_mvc_infra = filter_mvc(MVC(21,:));
    
    % finding max of mvc
    mvc_bicep = max(filtered_mvc_bicep);
    mvc_tricep = max(filtered_mvc_tricep);
    mvc_delt = max(filtered_mvc_delt);
    mvc_trap = max(filtered_mvc_trap);
    mvc_pecMajor = max(filtered_mvc_pecMajor);
    mvc_infra = max(filtered_mvc_infra);
    
    % normalizing to mvc
    normTrials.bicep = filtered_bicep./mvc_bicep;
    normTrials.tricep = filtered_tricep./mvc_tricep;
    normTrials.delt = filtered_delt./mvc_delt;
    normTrials.trap = filtered_trap./mvc_trap;
    normTrials.pecMajor = filtered_pecMajor./mvc_pecMajor;
    normTrials.infra = filtered_infra./mvc_infra;

end

