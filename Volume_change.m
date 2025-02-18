clear all;
folderPath = '';
savePath = folderPath;
fileList = dir(fullfile(folderPath, '*.mat'));

Volume_change_1 = {};

for i = 1:length(fileList)
    fileName = fullfile(folderPath, fileList(i).name);
    
    data = load(fileName);
    bw = data.VoCAT_Data.Correctbw;
    True_volume = nnz(bw);
    Temp = [];
    for j = 1:size(bw,3)
        VC = nnz(bw(:,:,j))/True_volume;
        Temp = [Temp VC];
    end
    Volume_change_1{i,1} = fileList(i).name;
    Volume_change_1{i,2} = Temp';
    disp(i);
end