tot_branches = size(VoCAT_Data.branchdata,1);
vol = VoCAT_Data.raw;
[h,w,l] = size(VoCAT_Data.Correctbw);
[x_sk,y_sk,z_sk]=ind2sub([h,w,l],find(VoCAT_Data.skel.sk));
[x_ep,y_ep,z_ep]=ind2sub([h,w,l],find(VoCAT_Data.skel.bp));
[x_bp,y_bp,z_bp]=ind2sub([h,w,l],find(VoCAT_Data.skel.ep));

figure('Name','3D Discrete skeleton');
plot3(x_sk,y_sk,z_sk,'square','Markersize',2,'MarkerFaceColor',[1 1 1],...
'Color',[0 0 1]);
hold on
scatter3(x_ep,y_ep,z_ep,'filled','CData',[87 192 255]./255);
scatter3(x_bp,y_bp,z_bp,'filled','CData',[255 0 0]./255);
hold off
%set(gca,'Color',[0.2 0.2 0.2]);
set(gca,'Color','none'); 
ca = gca;
%ca.Title.String = 'Skeleton';
ca.XAxis.Visible = 'off';
ca.YAxis.Visible = 'off';
ca.ZAxis.Visible = 'off';
daspect([1 1 1]);
view(2);
xlim([0 size(VoCAT_Data.raw,1)]);
ylim([0 size(VoCAT_Data.raw,2)]);