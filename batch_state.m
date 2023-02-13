function T = batch_state(datadir,Nsub,Nwin,Nstate,order,name)
% clc
% clear
% Nsub=36;
% Nwin=281;
% Nstate=4;
% datadir='F:\Myexpe\pieman_delmusic\tc_result\FunImgCF_NoGSR_Word\DMN10\z-mean\IS_DCC_1\kmeans_elbow_IS_DCC';
cd(datadir)
load IDXall.mat
SubStateNum=zeros(Nsub,Nwin);
for s=1:Nsub
    SubStateNum(s,:)=IDXall((s-1)*Nwin+1:s*Nwin)';  %每个subject 的 状态序列
end
Meanstate=mean(SubStateNum);
SubStateNumSort=zeros(Nsub,Nwin);
for i = 1 : length(order)
    SubStateNumSort(SubStateNum == i) = order(i) ;
end
tcname=fullfile(datadir, 'SubStateNumSort.txt');
save(tcname,'SubStateNumSort','-ASCII','-DOUBLE','-TABS');

figure(1);
imagesc(SubStateNumSort)
colormap jet
colorbar
set(gca,'FontSize',14,'LineWidth',2)
%set(gca,'tickdir','out')
%set(gca,'ygrid','on')  
axis([0 Nwin 1 Nsub]) ;
set(colorbar,'Ytick',1:1:Nstate) ;
set(gca,'Ytick',1:1:Nsub)
% set(gca,'Xtick',[0:100:1310])
set(gca,'Xtick',[0:100:Nwin])
%set(gca,'Xtick',[0 80 120 160 200 240 280],'XTicklabel',[1 2 3 4 5 6 7])
%set(gca,'Xtick',[40 80 120 160 200 240 280 320 360],'XTicklabel',[1 2 3 4 5 6 7 8 9])
xlabel('TR','FontSize',20)
ylabel('State ID','FontSize',20)
set(gcf,'Position',[100 100 1920*0.9 1080*0.9]);
title(['Simulation-a']);
figurename=fullfile(datadir,[name '.jpg'] );
print(1,figurename,'-dpng','-r600');  


% destate = SubStateNumSort(:,16:285);
% figure(2);
% imagesc(destate)
% colormap jet
% colorbar
% set(gca,'FontSize',14,'LineWidth',2)
% %set(gca,'tickdir','out')
% %set(gca,'ygrid','on')  
% axis([0 270 1 34])
% set(colorbar,'Ytick',1:1:5)
% set(gca,'Ytick',1:1:Nsub)
% set(gca,'Xtick',0:15:270,'XTicklabel',[15 30 45 60 75 90 105 120 135 150 165 180 195 210 225 240 255 270 285])
% xlabel('Min','FontSize',20)
% ylabel('State ID','FontSize',20)
% set(gcf,'Position',[100 100 1920*0.9 1080*0.9]);
% title(['Intact']);
% figurename=fullfile(datadir,'Time_of_4312_de30.jpg' );
% print(2,figurename,'-dpng','-r150');  
end
