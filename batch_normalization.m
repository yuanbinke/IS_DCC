function f = batch_normalization(rootdir,N_time,N_sub)
%rootdir:the file you save your timeseries

cd([rootdir filesep 'tc']);
load total_tc_original.txt;
total_z_data = [];
%z-mean
for i = 1:N_sub
    grot=total_tc_original((i-1)*N_time+1:i*N_time,:);
    grot=grot-repmat(mean(grot),size(grot,1),1); % demean
    total_z_data  = [total_z_data;grot];
end

newdir = [rootdir filesep 'z-mean'];
mkdir(newdir);
tcname=fullfile(newdir ,'total_tc.txt');
save(tcname,'total_z_data','-ASCII','-DOUBLE','-TABS');

cd([rootdir filesep 'tc']);
load total_tc_original.txt;
total_z_data = [];
%z-score Standardized
for i = 1:N_sub
    grot=total_tc_original((i-1)*N_time+1:i*N_time,:);
    grot=zscore(grot);
    total_z_data  = [total_z_data;grot];
end

newdir = [rootdir filesep 'zscore1'];
mkdir(newdir)
tcname=fullfile(newdir ,'total_tc.txt');
save(tcname,'total_z_data','-ASCII','-DOUBLE','-TABS');


cd([rootdir filesep 'tc']);
load total_tc_original.txt;
total_z_data = [];
%z-score 
for i = 1:N_sub
    grot=total_tc_original((i-1)*N_time+1:i*N_time,:);
    grot=grot-repmat(mean(grot),size(grot,1),1); % demean
    grot=grot/std(grot(:)); % normalise whole subject stddev
    total_z_data  = [total_z_data;grot];
end

newdir = [rootdir filesep 'zscore2'];
mkdir(newdir);
tcname=fullfile(newdir ,'total_tc.txt');
save(tcname,'total_z_data','-ASCII','-DOUBLE','-TABS');


end
