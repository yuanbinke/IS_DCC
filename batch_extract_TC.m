function F = batch_extract_TC(rootdir,atlasdir,N_roi,atlastype,datatype,TR,wsize)
% rootdir:
%     the rootfold of your fold of some kind of data
% atlasdir:
%     the fold you save your atlasmasks
% N_roi:
%     the number of ROI
% TR:
%     time repeated of your fmri data
% wisize:
%     the length of your window,the default is 1
% atlastype:
%     the atlasmask name of you will use
% datatype:
%     the fold name you save your fmri data


% rootdir='F:\T'; %dir
% atlasdir='F:\T';  %atlasmask dir
% method='L1'; 
% TR=1.5;
% wsize=1; %窗口长度
% N_time=300;
% allpair = 0; 
% Wordllel = 0;
% N_sub=36; %人数
% N_roi=[68]; 
% Nwin = N_time - wsize+1;%窗口数量
% atlastype={'BNSL_68_3mm.nii'}; %atlas.nii文件
% datatype={'T1'}
%     batch_extract_TC(rootdir,atlasdir,N_roi,atlastype,datatype,TR,wsize)



method = 'L1';
wsize = 1;
for a=1:length(N_roi) %roi数量
    Vtem = spm_vol([atlasdir filesep atlastype{a}]);   %每个区域都有一个Atmask
    [Ytem, ~] = spm_read_vols(Vtem); %mask的信息
    RoiIndex=1:N_roi(a);
    MNI_coord = cell(length(RoiIndex),1);
    for j = 1:length(RoiIndex)
        Region = RoiIndex(j);
        ind = find(Region == Ytem(:));
        
            if ~isempty(ind)
                [I,J,K] = ind2sub(size(Ytem),ind);
                XYZ = [I J K]';
                XYZ(4,:) = 1;
                MNI_coord{j,1} = XYZ;
            else
                error (['There are no voxels in ROI' blanks(1) num2str(RoiIndex(j)) ', please specify ROIs again']);
            end
    end

    for d=1:length(datatype) %不同的数据类型提取tc
        tcdir=fullfile([rootdir filesep 'tc_result' filesep datatype{d} filesep atlastype{a} filesep 'tc']);
        mkdir(tcdir)
        datapath=fullfile(rootdir,datatype{d});
        sublist=dir(datapath);
        total_z_data=[];
        for s=3:length(sublist)
            fprintf('Extracting time series for %s\n', sublist(s).name);
            File_filter='';
            cd ([datapath filesep sublist(s).name])
            File_name = spm_select('List',pwd, ['^' File_filter '.*\.img$']);
            if isempty(File_name)
                File_name = spm_select('List',pwd, ['^' File_filter '.*\.nii$']);
            end
            
            Vin = spm_vol(File_name);
            MTC = zeros(size(Vin,1),length(RoiIndex));
            
            for j = 1:length(RoiIndex)
                VY = spm_get_data(Vin,MNI_coord{j,1});
                MTC(:,j) = mean(VY,2);
            end
            MTC(isnan(MTC))=0;
            total_z_data=[total_z_data;MTC];
            
        end
        tcname=fullfile(tcdir,'total_tc_original.txt');
        save(tcname,'total_z_data','-ASCII','-DOUBLE','-TABS')
    end
end

end



