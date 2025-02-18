% Length
figure('Name','Histgrams: mesurement distribution for different metrics');
subplot(2,2,1);
histogram(VoCAT_Data.branchdata.Len(:),'FaceColor','r','Normalization','probability');
xline(mean(VoCAT_Data.branchdata.Len(:)),'--r',{string(mean(VoCAT_Data.branchdata.Len(:)))});
xlim([0 150]);
title('Length');
xlabel('Length [\μm]');
ylabel('Occurrences [%]');
% Tortuosity
subplot(2,2,2);
histogram(VoCAT_Data.branchdata.Tort_new(:),'FaceColor','b','Normalization','probability');
xline(mean(VoCAT_Data.branchdata.Tort_new(:)),'--r',{string(mean(VoCAT_Data.branchdata.Tort_new(:)))});
xlim([0 1]);ylim([0 0.5]);
xlabel('Tortuosity [adim.]');
ylabel('Occurrences');
title('Tortuosity');
% Radius
subplot(2,2,3);
histogram(VoCAT_Data.branchdata.Rad(~isnan(VoCAT_Data.branchdata.Rad)),'FaceColor','g',...
    'Normalization','probability');
xline(mean(VoCAT_Data.branchdata.Rad(~isnan(VoCAT_Data.branchdata.Rad))),'--r',{string(mean(VoCAT_Data.branchdata.Rad(:)))});
xlim([0 250]);
xlabel('Radius [\μm]');
ylabel('Occurrences [%]');
title('Radius');
% Eccentricity 
subplot(2,2,4);
histogram(VoCAT_Data.branchdata.Eccent(:),'FaceColor',[234,179,10]./255,...
    'Normalization','probability');
axis tight
title('Eccentricity');
xlim([0.5 1]);ylim([0 0.2]);
xline(mean(VoCAT_Data.branchdata.Eccent(:)),'--r',{string(mean(VoCAT_Data.branchdata.Eccent(:)))});
xlabel('Eccentricity [adim.]');
ylabel('Occurrences [%]');