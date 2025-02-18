% The skeleton has been redrawn, but this time the color of each branch
% depends on its radius
tot_branches = size(VoCAT_Data.branchdata,1);
figure('Name','Radius branch-wise')
cool = colormap(jet);
for b = 1:tot_branches
    currcolor_idx = ceil((VoCAT_Data.branchdata.Rad(b)/max(VoCAT_Data.branchdata.Rad(:)))^0.5 *256);
    %currcolor_idx = ceil((VoCAT_Data.branchdata.Rad(b)/500)^0.5 *256);
    plot3(VoCAT_Data.branchdata.xPath{b}, VoCAT_Data.branchdata.yPath{b}, VoCAT_Data.branchdata.zPath{b},...
        'Color', cool(currcolor_idx,:),'LineWidth',3);
    hold on
    scatter3(VoCAT_Data.branchdata.From(b,1), VoCAT_Data.branchdata.From(b,2), VoCAT_Data.branchdata.From(b,3),'o',...
        'filled','MarkerFaceColor', [1 1 1]);
    scatter3(VoCAT_Data.branchdata.To(b,1), VoCAT_Data.branchdata.To(b,2), VoCAT_Data.branchdata.To(b,3),'o',...
        'filled','MarkerFaceColor', [1 1 1]);
end
hold off
set(gca,'CLim',[min(VoCAT_Data.branchdata.Rad(:)) max(VoCAT_Data.branchdata.Rad(:))]);
%set(gca,'CLim',[0 500]);
set(gca,'Color',[0.2 0.2 0.2]);
colorbar;
title('Radius');
daspect([1 1 1]);
%view(3);
view(2);
xlim([0 512]);
ylim([0 512]);