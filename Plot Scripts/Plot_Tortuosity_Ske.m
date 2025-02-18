% The skeleton has been redrawn, but this time the color of each branch depends on its tortuosity
tot_branches = size(VoCAT_Data.branchdata,1);
figure('Name','Tortuosity branch-wise')
cm = colormap(jet);
for b = 1:tot_branches
    currcolor_idx = 1+round((VoCAT_Data.branchdata.Tort_new(b)-min(VoCAT_Data.branchdata.Tort_new(:)))...
        /max(VoCAT_Data.branchdata.Tort(:))*255);
    plot3(VoCAT_Data.branchdata.xPath{b}, VoCAT_Data.branchdata.yPath{b}, VoCAT_Data.branchdata.zPath{b},...
        'Color', cm(currcolor_idx,:),'LineWidth',3);
    hold on
    scatter3(VoCAT_Data.branchdata.From(b,1), VoCAT_Data.branchdata.From(b,2), VoCAT_Data.branchdata.From(b,3),'o',...
        'filled','MarkerFaceColor', [1 1 1]);
    scatter3(VoCAT_Data.branchdata.To(b,1), VoCAT_Data.branchdata.To(b,2), VoCAT_Data.branchdata.To(b,3),'o',...
        'filled','MarkerFaceColor', [1 1 1]);
end
hold off
set(gca,'CLim',[min(VoCAT_Data.branchdata.Tort_new(:)) max(VoCAT_Data.branchdata.Tort_new(:))]);
set(gca,'Color',[0.2 0.2 0.2]);
colorbar
title('Tortuosity');
daspect([1 1 1]);
view(3);