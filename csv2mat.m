csv = readmatrix("C:\Users\janex\Desktop\School\URA\SUPER SAFE ARCHIVE\EMG_Joseph\Run_number_149_Plot_and_Store_Rep_7.10.csv");
csv = csv.';

Time = csv(1:2:end,:);
Data = csv(2:2:end,:);

save('Run_number_149_Plot_and_Store_Rep_7.10.mat', 'Time', 'Data');
