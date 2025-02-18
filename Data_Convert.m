clear all;
folderPath = '';% Specify the path of the analysis folder
savePath = folderPath;
% Retrieve all. mat files in the folder
fileList = dir(fullfile(folderPath, '*.mat'));

columnNames = {'Name','NNZ(BW)', 'NUMEL(BW)','mRad','Branchpoints','Endpoints','Connectivity ratio','mRad_REAVER', 'mlen', 'mTort','mTort_New', 'mEcc', 'volFrac', 'approxAlat', 'realAlat', 'S_over_V', 'numSubN','GoodValue','Fratal Dimension'};
varTypes = {'string','double','double','double','single','double','double','double','double','double','double','double','double','double','double','double','double','double','double'};
dataTable = table('Size', [length(fileList) 19], 'VariableTypes',varTypes,'VariableNames', columnNames);

for i = 1:length(fileList)
    fileName = fullfile(folderPath, fileList(i).name);
    data = load(fileName);
    mTort_New = mean(data.VoCAT_Data.branchdata.Tort_new,'omitnan');
    isGOOD = data.VoCAT_Data.branchdata.isGood;
    logicalArray = isGOOD > 0;
    count = sum(logicalArray);
    GoodValue = count/length(isGOOD);
    bp = data.VoCAT_Data.skel.bp;
    ep = data.VoCAT_Data.skel.ep;
    Num_bp = size(regionprops3(bp,'Volume'),1);
    Num_ep = size(regionprops3(ep,'Volume'),1);
    FD = FD_Compute(data.VoCAT_Data.skel.sk);
    dataTable{i,1} = string(fileList(i).name);
    dataTable{i,2} = nnz(data.VoCAT_Data.Correctbw);
    dataTable{i,3} = numel(data.VoCAT_Data.Correctbw);
    dataTable{i,4} = data.VoCAT_Data.mRad;
    dataTable{i,5} = Num_bp;
    dataTable{i,6} = Num_ep;
    dataTable{i,7} = Num_bp/Num_ep;
    dataTable{i,8} = data.VoCAT_Data.mRad_REAVER;
    dataTable{i,9} = data.VoCAT_Data.mLen;
    dataTable{i,10} = data.VoCAT_Data.mTort;
    dataTable{i,11} = mTort_New;
    dataTable{i,12} = data.VoCAT_Data.mEcc;
    dataTable{i,13} = data.VoCAT_Data.volFrac;
    dataTable{i,14} = data.VoCAT_Data.approxAlat;
    dataTable{i,15} = data.VoCAT_Data.realAlat;
    dataTable{i,16} = data.VoCAT_Data.S_over_V;
    dataTable{i,17} = data.VoCAT_Data.numSubN;
    dataTable{i,18} = GoodValue;
    dataTable{i,19} = FD;
    disp(i);
end

writetable(dataTable,[savePath,'\Res.xlsx']);