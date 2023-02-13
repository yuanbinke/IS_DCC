function F = batch_clustering(resultdir,TR,N_sub,N_roi,wsize)

% k-mean clustering applied on the data the has been processed by is_dcc
% resultdir:
%     the fold where you save your dFC_result.mat
% TR:
%     time repeated
% N_sub:
%     the number of subject
% N_roi:
%     the number of roi


method='L1'; 
%% clustering
for a=1:length(N_roi)
    for d=1%:length(datatype)
        resultdir2= fullfile([resultdir filesep 'kmeans_elbow_IS_DCC']);
        mkdir(resultdir2)
        kmeans_max_iter = 150;
        dmethod = 'city';
        kmeans_num_replicates = 5;
        num_tests_est_clusters = 10;
        cd(resultdir)
        load SP
        load dFC_result
        %% Cluster
        SPflat = cell2mat(SP);
        clear SP;
        cd(resultdir2)
        cluster_estimate_results = icatb_optimal_clusters(SPflat, min([max(size(SPflat)), 10]), 'method', 'elbow', 'cluster_opts', {'Replicates', kmeans_num_replicates, 'Distance', dmethod, ...
            'MaxIter', kmeans_max_iter}, 'num_tests', num_tests_est_clusters, 'display', 1);
        
        num_clusters = 0;
        for Ntests = 1:length(cluster_estimate_results)
            num_clusters = num_clusters + (cluster_estimate_results{Ntests}.K(1));
        end
        num_clusters = ceil(num_clusters/length(cluster_estimate_results));
        disp(['Number of estimated clusters used in dFNC standard analysis is mean of all tests: ', num2str(num_clusters)]);
        fprintf('\n');
        
        [IDXp, Cp, SUMDp, Dp] = kmeans(SPflat, num_clusters, 'distance', dmethod, 'Replicates', kmeans_num_replicates, 'MaxIter', kmeans_max_iter, 'Display', 'iter', 'empty', 'drop');%gift 4.0b
        
        [IDXall, Call, SUMDall, Dall] = kmeans(dFC_result, num_clusters, 'distance', dmethod, 'Replicates', 1, 'Display', 'iter', 'MaxIter', kmeans_max_iter, ...
            'empty', 'drop', 'Start', Cp);
        
        Tmpmin=zeros(size(Call,1),1);
        Tmpmax=zeros(size(Call,1),1);
        for i=1:size(Call,1)
            tmp_state=sf_vec2mat(N_roi(a),Call(i,:));
            tmp_state=tmp_state+tmp_state';
            Tmpmin(i)=min(min(tmp_state));
            Tmpmax(i)=max(max(tmp_state));
        end
        for i=1:size(Call,1)
            tmp_state=sf_vec2mat(N_roi(a),Call(i,:));
            tmp_state=tmp_state+tmp_state';
            figure
            imagesc(tmp_state)
            colormap jet
            colorbar
            caxis([min(Tmpmin), max(Tmpmax)]);
            title(['state0' num2str(i)])
            set(gca, 'XTick', 1:10:116)
            figurename=fullfile(resultdir2,['state0' num2str(i) '.jpg'] );
%             saveas(gcf,figurename)
            print(gcf,figurename,'-dpng','-r1200');
            close(gcf)
            figurename2=strcat('state_0', num2str(i), '.mat') ;
            cd(resultdir2)
            save(figurename2,'tmp_state')
        end
        %
        cd(resultdir2)
        save('IDXall.mat','IDXall')
        save('Call.mat','Call');
        
        % %% time Wordmeters
        % kmeansdir=fullfile(rootdir,'kmeans_elbow',datatype{1});
%         cd(resultdir2)
%         load('IDXall.mat');
        labels=IDXall;
        %% calulate time
        % TR=2;
        K=max(labels);
        T=length(labels);
        T2=T/N_sub;%number of sliding windows
        for s=1:N_sub
            label_sub=labels(((s-1)*T2+1:s*T2),:);
            dwell_time(s,:)=sf_dwell_time(label_sub,K,TR);
            average_dwell_time(s,:)=sf_ave_dwell_time(label_sub,K,TR);
            transitions_to_state(s,:)=sf_trans_to_state(label_sub,K);
            state_to_state(s,:,:)=sf_state_to_state(label_sub,K);
        end
        cd(resultdir2)
        save dwell_time.mat dwell_time
        save average_dwell_time.mat average_dwell_time
        save transitions_to_state.mat transitions_to_state
        save state_to_state.mat state_to_state
        clear state_to_state transitions_to_state average_dwell_time dwell_time
    end
end

end