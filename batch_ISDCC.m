function F = batch_isdcc(tcdir,N_time,N_sub,N_roi,wsize)
%A improved aprroach for computing the intersubject correlation of the correlation of the timeseries based on
%DCC approach and 

%Para:
% rootdir:
%      the file you will save the answer
% atlasdir:
%      the file you save the atlasmask
% wsize:
%     the length of your windows,default = 1
% N_time:
%     the length TR of your timeseries of your data
% N_sub:
%     the number of subjects
% N_roi:
%     the number of ROIs
% atlastype:
%     the name of your atlasmask
% datatype:
%     the file your save your original datas

%Yuanbinke,upadted July,2022,South China Normal University,Guangzhou


Nwin = N_time - wsize+1;

%% dynamic FC
for a=1:length(N_roi)
    for d=1%:length(datatype)
        %tcdir=fullfile(['F:\Myexpe\tc\ANDMN']);
        cd(tcdir) ;
        resultdir=fullfile([tcdir filesep 'IS_DCC_1']);
        mkdir(resultdir);
        tcfn=fullfile(tcdir,'total_tc.txt');
        load(tcfn);
        data=eval('total_tc');
        clear total_tc ;
        data=reshape(data,[N_time,N_sub,N_roi(a)]);
        dFC_result=[];
        for s=1:N_sub
            %is_dcc of improved
            subtc=squeeze(data(:,s,:));%time * ROI
            subR=data;
            subR(:,s,:)=[];  %leave one out
            subtc1=squeeze(mean(subR,2));

            %[tmp_dFC]=pp_ReHo_dALFF_dFC_gift(subtc,method,TR,wsize);%trme * ROI paris, 2D. r*(r-1)/2

            %[~,Ct2,~,~] = DCC_X(subtc2,allpair,Wordllel);
%             ISCt2 = zeros(N_roi(1),N_roi(1),N_time);
%             for i = 1 : N_roi(1)
%                 for j = 1 : N_roi(1)
%                 subtc2 = [subtc(:,i),subtc1(:,j)];
%                 Ct2 = DCC(subtc2);
%                 ISCt2(i,j,:) = Ct2(1,2,:);
%                 ISCt2(j,i,:) = Ct2(1,2,:);
%                 end
%             end
            
             for i = 1 : N_roi(1)
                for j = i+1 : N_roi(1)
                subtc2 = [subtc(:,i),subtc1(:,j)];
                Ct2 = DCC(subtc2);
                ISCt2(i,j,:) = Ct2(1,2,:);
                ISCt2(j,i,:) = Ct2(1,2,:);
                end
            end

            %extract the upper right ISDCC value
%             ISCt2 = zeros(N_roi(a),N_roi(a),N_time);
%             for i = 1:N_roi(a)
%                 for j = N_roi(a)+1:N_roi(a)*2
%                     ISCt2(i,j-N_roi,:) = Ct2(i,j,:);
%                 end
%             end

            % moving average DCC with window length
            atmp=zeros(size(ISCt2,1),size(ISCt2,1)); 
            tmp_dFC_DCCX=zeros(Nwin,length(mat2vec(atmp)));
            for iw=1:Nwin %300TRs
                tmpr=ISCt2(:,:,iw);     %the correlation of every point-to-point in every timepoint 
                tmp_dFC_DCCX(iw,:)=mat2vec(squeeze(tmpr));
            end
            tmp_dFC=tmp_dFC_DCCX;
            DEV = std(tmp_dFC, [], 2);%STD OF NODE
            [xmax, imax, xmin, imin] = icatb_extrema(DEV);%local maxima in FC variance
            pIND = sort(imax);%?
            k1_peaks(s) = length(pIND);%?
            SP{s,1} = tmp_dFC(pIND, :);%Subsampling ,where time is the jizhidian
            dFC_result=[dFC_result;tmp_dFC];
            %save sp and tmp_dfc for every subject
            if(s<10)
                newdir = [resultdir filesep 'sub00' num2str(s)];
            else
                newdir = [resultdir filesep 'sub0' num2str(s)];
            end
            mkdir(newdir);
            cd(newdir);
            %save tmp_dFC.mat tmp_dFC ;
            save('tmp_dFC.mat','tmp_dFC','-v7.3');
            
          
        end%s
        cd(resultdir);
        save('SP.mat','SP','-v7.3');
        save('dFC_result.mat','dFC_result','-v7.3');
    end%d
end
            

end
