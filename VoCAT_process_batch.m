%%
clear all
%% Setting Parameters
xds = 0.83; yds = 0.83; zds = 2.65;% pixel size (μm)
pxdens = [xds yds zds];
downfactor = 1;
smoothing_repeat = 3;
rad_precision = 5;
pts_per_branch = 12;
length_thr = 15;
append_to_path = '';
Parameters = {pxdens,downfactor,smoothing_repeat,rad_precision,pts_per_branch,length_thr,append_to_path};
%% Laoding files
folderpath = uigetdir;
files = dir(folderpath);
try
    if ismac
        for k=3:length(files)
            pathtoimg=strcat(files(k).folder,"/",files(k).name);
            try
                VoCAT_main(pathtoimg,Parameters);
                splitpath = split(pathtoimg,".");
                load(strcat(splitpath(1),".mat"));
                writetable(VoCAT_Data.branchdata(:,[1 5 7 14 16 17 18 19]),...
                    strcat(folderpath,"/batch.xlsx"),'Sheet',string(k-2));
            catch ex
            end
        end
    else
        for k=5:length(files)
            pathtoimg=strcat(files(k).folder,"\",files(k).name);
            VoCAT_main(pathtoimg,Parameters);%更改运行函数的位置
        end
    end
catch
    error("Error determining your OS");
end