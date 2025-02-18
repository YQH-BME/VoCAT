% 指定文件夹路径
folderPath = 'E:\HUST\OoC\血管芯片分析工具文章\Figure6\Spheroid_Res\SegmentRes';  % 修改为你文件夹的路径

% 获取文件夹中所有的 .tif 文件
fileList = dir(fullfile(folderPath, '*.tif'));

% 创建一个存储所有肿瘤球形态学参数的数组
tumorSpheresStats = [];

% 遍历每个文件并处理
for k = 1:length(fileList)
    % 获取文件的完整路径
    filePath = fullfile(folderPath, fileList(k).name);
    
    % 读取图像文件
    img = imread(filePath);
    
    % 图像预处理（可根据需要调整）
    % 假设图像是灰度图像，如果是彩色图像，可以先转换为灰度图
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    
    % 二值化图像
    binaryImg = imbinarize(img);  % 如果需要，可以使用其他阈值方法
    
    % 去除噪声，可以使用形态学操作
    binaryImg = bwareaopen(binaryImg,50);
    binaryImg = imclose(binaryImg, strel('disk', 15));  % 使用开运算去除小噪点
    binaryImg = imfill(binaryImg,"holes");
    
    % 进行连通区域分析
    stats = regionprops(binaryImg, 'Area', 'Centroid', 'Eccentricity', 'Solidity', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'BoundingBox', 'ConvexArea');
    
    % 如果没有检测到肿瘤球，则跳过
    if isempty(stats)
        continue;
    end
    
    % 找到面积最大的肿瘤球
    [~, idxMax] = max([stats.Area]);  % 获取最大面积对应的肿瘤球索引
    
    % 获取该肿瘤球的统计特征
    area = stats(idxMax).Area;  % 面积
    centroid = stats(idxMax).Centroid;  % 质心
    eccentricity = stats(idxMax).Eccentricity;  % 偏心率
    solidity = stats(idxMax).Solidity;  % 实心度
    perimeter = stats(idxMax).Perimeter;  % 周长
    majorAxisLength = stats(idxMax).MajorAxisLength;  % 长轴长度
    minorAxisLength = stats(idxMax).MinorAxisLength;  % 短轴长度
    boundingBox = stats(idxMax).BoundingBox;  % 边界框
    convexArea = stats(idxMax).ConvexArea;  % 凸包面积
    
    % 计算圆度（Roundness）：圆度 = 4 * π * 面积 / 周长^2
    roundness = (4 * pi * area) / (perimeter^2);
    
    % 计算突刺数量（一个简单的方式：通过周长与凸包的比较）
    spikeCount = perimeter / (2 * pi * sqrt(area / pi));  % 一个简化的指标，实际可以根据需求调整
    
    % 将最大肿瘤球的特征保存在结构体中
    tumorSpheresStats(k).Area = area;
    tumorSpheresStats(k).Centroid = centroid;
    tumorSpheresStats(k).Eccentricity = eccentricity;
    tumorSpheresStats(k).Solidity = solidity;
    tumorSpheresStats(k).Perimeter = perimeter;
    tumorSpheresStats(k).MajorAxisLength = majorAxisLength;
    tumorSpheresStats(k).MinorAxisLength = minorAxisLength;
    tumorSpheresStats(k).Roundness = roundness;
    tumorSpheresStats(k).SpikeCount = spikeCount;
    
    % 可选：显示当前图像及其最大肿瘤球的统计参数
    figure;
    imshow(binaryImg);
    %title(['Largest Tumor Sphere in Image ', num2str(k), ': ', fileList(k).name]);
    
    % 在图像上标注肿瘤球的质心
    hold on;
    plot(centroid(1), centroid(2), 'r*', 'MarkerSize', 10);  % 标注质心
    hold off;
end

% 输出统计结果
disp('肿瘤球的形态学参数：');
disp(tumorSpheresStats);
tumorSpheresStats1 = struct2table(tumorSpheresStats);
%writetable(tumorSpheresStats1,'1d_Square.xlsx');