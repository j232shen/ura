P_subjects = get_P_subjects();
N_subjects = get_N_subjects();

edges = -15:5:15;

%% passive-active
% plotting for each participant
figure
for i = 1:length(P_subjects)
    subplot(length(P_subjects),1,i)
    histogram(P_subjects(i).angleError, edges)
    title(strcat('Participant #', int2str(i)))
    ylim([0 45])
end

% plotting all participant errors combined
P_allError = [];
for i = 1:length(P_subjects)
    P_allError = [P_allError; P_subjects(i).angleError];
end

figure
histogram(P_allError, edges)
title('Distribution of all participant passive-active errors')
ylim([0 140])

%% active-active
% plotting for each participant
figure
for i = 1:length(N_subjects)
    subplot(length(P_subjects),1,i)
    histogram(N_subjects(i).angleError, edges)
    title(strcat('Participant #', int2str(i)))
    ylim([0 45])
end

% plotting all participant errors combined
N_allError = [];
for i = 1:length(N_subjects)
    N_allError = [N_allError; N_subjects(i).angleError];
end

figure
histogram(N_allError, edges)
title('Distribution of all participant active-active errors')
ylim([0 140])