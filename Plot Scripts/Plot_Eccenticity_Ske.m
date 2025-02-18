% The skeleton has been redrawn, but this time the color of each branch depends on its eccenticity
tot_branches = size(VoCAT_Data.branchdata,1);
figure('Name','Eccenticity branch-wise');
cool = colormap(jet);
for b = 1:tot_branches
    currcolor_idx = ceil(VoCAT_Data.branchdata.Eccent(b)/max(VoCAT_Data.branchdata.Eccent(:))*256);
    plot3(VoCAT_Data.branchdata.xPath{b}, VoCAT_Data.branchdata.yPath{b}, VoCAT_Data.branchdata.zPath{b},...
        'Color', cool(currcolor_idx,:),'LineWidth',3);
    hold on
    scatter3(VoCAT_Data.branchdata.From(b,1), VoCAT_Data.branchdata.From(b,2), VoCAT_Data.branchdata.From(b,3),'o',...
        'filled','MarkerFaceColor', [1 1 1]);
    scatter3(VoCAT_Data.branchdata.To(b,1), VoCAT_Data.branchdata.To(b,2), VoCAT_Data.branchdata.To(b,3),'o',...
        'filled','MarkerFaceColor', [1 1 1]);
end
hold off
set(gca,'CLim',[min(VoCAT_Data.branchdata.Eccent(:)) max(VoCAT_Data.branchdata.Eccent(:))]);
set(gca,'Color',[0.2 0.2 0.2]);
colorbar;
title('Eccentricity');
daspect([1 1 1]);
view(3);