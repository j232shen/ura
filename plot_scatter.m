P_subjects = get_P_subjects();
N_subjects = get_N_subjects();

% comparing conditions for every participant
for i = 1:length(P_subjects)
    figure
    hold on
    scatter(P_subjects(i).targetAngle, P_subjects(i).angleError)
    scatter(N_subjects(i).targetAngle, N_subjects(i).angleError)
    title(strcat('Participant #', int2str(i)))
    legend('Passive-active','Active-active')
    xlim([0 90])
    ylim([-15 15])
    hold off
end