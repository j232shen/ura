P_subjects = get_P_subjects();
N_subjects = get_N_subjects();

mid_bins = 15:10:55; % midpoints of bins

% comparing conditions for every participant
for i = 1:length(P_subjects)
    figure
    hold on
    errorbar(mid_bins, P_subjects(i).meanErr, P_subjects(i).stdev)
    errorbar(mid_bins, N_subjects(i).meanErr, N_subjects(i).stdev)
    title(strcat('Participant #', int2str(i)))
    legend('Passive-active','Active-active')
    xticks(mid_bins)
    xlim([10 60])
    ylim([-5 10])
    hold off
end