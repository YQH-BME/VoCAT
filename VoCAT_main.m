function VoCAT_main(path,Parameters)
req = {'Image Processing Toolbox', 'Curve Fitting Toolbox', ...
    'Computer Vision Toolbox','Deep Learning Toolbox'};
if ~check_req(req)
    disp('Requirements:');
    disp(string(req'));
    error('ERROR: You are missing some toolboxes that are required for the script');
end
pxdens = Parameters{1};
downfactor = Parameters{2};
smoothing_repeat = Parameters{3};
rad_precision = Parameters{4};
pts_per_branch = Parameters{5};
length_thr = Parameters{6};
append_to_path = Parameters{7};
% loading file
try
    img_3d = bfOpen3DVolume(char(path));
    vol = img_3d{1,1}{1,1};
    splpath = strsplit(img_3d{1}{2},".");
    pathtoimg = splpath(1);
    extension = strcat(".",splpath(2));
    disp(strcat("> Processing: ",string(pathtoimg),extension));
catch
    error('Invalid path or unreadable file');
    
end
VoCAT_Data.raw = vol;
clear img_3d splpath path

% 2D projection
disp("> Creating 2D projection ");
flattened = max(vol, [],3);
VoCAT_Data.flat = flattened;

%truec = cat(3, flattened,flattened,flattened);
%imwrite(mat2gray(truec),[pathtoimg '.bmp']);
clear flattened

% resize to segmentation
[x, y, z] = size(vol);
xT = findClosestMultiple(x);
yT = findClosestMultiple(y);
zT = round(z/8)*8;
DataR = imresize3(vol,[xT yT zT]);
try
    temp = load('./Trained Network/LUnet.mat');
    DP_net = temp.DP_net;
    disp("> Performing Deep Learning segmentation...  ");
    Segmentres = zeros(size(DataR));
    % 预测分割部份
    rescfact = size(DataR);
    vres = DataR;
    % Segmenting quadrants of dimension 128x128x8. The final segmentation
    % is the re-alignment of all these quadrants
    Segmentres = zeros(rescfact);
    tic;
    for i=0:128:(rescfact(1)-128)
        for j=0:128:(rescfact(2)-128)
            for k=0:8:(rescfact(3)-8)
                Segmentres((i+1):(i+128), (j+1):(j+128), (k+1):(k+8)) = ...
                    semanticseg(vres((i+1):(i+128), (j+1):(j+128), (k+1):(k+8)),DP_net);
            end
        end
    end
    disp("> DP Segment finished, time consuming:");
    toc;
    Segmentres(Segmentres == 1) = 0;
    Segmentres(Segmentres == 2) = 255;
    bw = logical(Segmentres);

catch
    disp("> loading Deep learning network failed");
    disp("> Performing segmentation - ActiveContour ");
    mask = zeros(size(vol));

    for i=1:smoothing_repeat
        vol = smooth3(vol);
    end
    tic;
    for seedLevel = 1:size(vol,3)
        seed = vol(:,:,seedLevel) > mean(vol,'all');
        seed_thick = bwmorph(seed, 'thicken', 10);
        N = 3;
        kernel = ones(N, N) / N^2;
        seed_thick = conv2(double(seed_thick), kernel, 'same');
        seed_thick = seed_thick > N/10;
        mask(:,:,seedLevel) = seed_thick;
    end
    bw = activecontour(vol,mask,100,'edge');
    disp("> AC Segment finished, time consuming:");
    toc;
    clear mask kernel N seedLevel seed_thick
end

% Smoothing edges
for i=1:smoothing_repeat
    bw = smooth3(bw);
end
se = strel('disk', 5);  % Size changeable
closedImg = imclose(bw, se);
bw = logical(closedImg);

[h,w,l] = size(vol);
bw = imresize3(bw,[h,w,l]);
clear temp Fnet929 rescfact Segmentres vres i j k se
% Downsampling operation and correct voxel demensions
disp("> Downsampling and adjusting the voxel dimensions... ");
bw = bw(1:downfactor:end, 1:downfactor:end, 1:downfactor:end);
[h,w,l] = size(bw);
% Creating the meshgrid
[x,y,z] = meshgrid(1:w,1:h,1:l);
if pxdens(3)~=pxdens(1)
    newvol = [];
    for slh = linspace(1,l,(l-1)*pxdens(3)/pxdens(1))
        fig = figure('Visible','off');
        s = slice(x,y,z,double(bw),[],[],slh,'linear');
        newvol = cat(3,newvol,(s.CData)');
    end
    bw = smooth3(newvol,'gaussian');
end
bw = logical(bw);
VoCAT_Data.Correctbw = bw; 
volshow(bw);
clear newvol h w l slh s fig
% Skeleton (For some reason Skeleton3D swaps the X and Y dimensions)
disp("> Computing the skeleton... ");
sk = Skeleton3D(bw);
sk = permute(sk, [2 1 3]);
VoCAT_Data.skel.sk = sk;
% Finding branchpoints
disp("> Finding branchpoints... ");
bpoints = bwmorph3(sk,'branchpoints');
epoints = bwmorph3(sk,'endpoints');
VoCAT_Data.skel.bp = bpoints;
VoCAT_Data.skel.ep = epoints;
VoCAT_Data.NumBranchpoints = size(regionprops3(bpoints,'Volume'),1);
VoCAT_Data.NumEndpoints = size(regionprops3(epoints,'Volume'),1);
VoCAT_Data.Connectivity_Ratio = VoCAT_Data.NumBranchpoints/VoCAT_Data.NumEndpoints;
clear bpoints epoints
% classify branchpoints
[adj, node, link] = Skel2Graph3D(sk,length_thr);
[h,w,l] = size(bw);

branchdata = table(0,{0},{0},{0},[0,0,0],[0,0,0],{0},...
    'VariableNames', {'Num','xPath','yPath','zPath','From','To',...
    'Interp'});

tot_branches = numel(link);
for b=1:tot_branches
    path_idx = link(b).point;
    [path_x, path_y, path_z] = ind2sub([h,w,l],path_idx);
    interp = cscvn([path_x; path_y; path_z]);
    x_from = node(link(b).n1).comx;
    y_from = node(link(b).n1).comy;
    z_from = node(link(b).n1).comz;
    x_to = node(link(b).n2).comx;
    y_to = node(link(b).n2).comy;
    z_to = node(link(b).n2).comz;
    from = [x_from,y_from,z_from];
    to = [x_to,y_to,z_to];
    toAdd = {b, path_x, path_y, path_z, from, to,interp};
    branchdata = cat(1, branchdata, toAdd);
end
branchdata(1,:) = [];

G = graph(adj);
for n = 1:numel(node)
    G.Nodes.x(n) = node(n).comx;
    G.Nodes.y(n) = node(n).comy;
    G.Nodes.z(n) = node(n).comz;
    G.Nodes.subN(n) = 0;
end

numsn = 1;
while any(G.Nodes.subN == 0)
    non_lab = find(G.Nodes.subN==0);
    G = floodgraph(G,non_lab(1),numsn);
    numsn=numsn+1;
end
VoCAT_Data.skel.graph = G;

% Updating the discrete skeleton to the one maintained with the graph conversion. Short vessels have been eliminated
sk = zeros(h,w,l);
for i=1:tot_branches
    for j=1:numel(branchdata.xPath{i})
        sk(branchdata.xPath{i}(j),branchdata.yPath{i}(j),branchdata.zPath{i}(j)) = 1;
    end
end

clear adj b cond e from G i ...
    interp j link node path_idx path_x path_y path_z ...
    to toAdd non_lab x_from x_to y_from y_to z_from z_to
% Morphological measurements
disp("> Morphological measurements... ");
displine = 0;
errors = 0;
f = waitbar(0,'Processing','Name','Vessel data processing',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(f,'canceling',0);
steps = tot_branches;
for b=1:tot_branches
    if getappdata(f,'canceling')
        break
    end
    % LENGTH
    xyzpath = [branchdata.xPath{b};branchdata.yPath{b};branchdata.zPath{b}];
    branchdata.Len(b) = sum(sqrt(sum(diff(xyzpath,1,2).^2)));

    % TORTUOSITY [as T = Dist/L] 
    d = sqrt(sum((branchdata.From(b,:)-branchdata.To(b,:)).^2));
    branchdata.Tort(b) = constrain(branchdata.Len(b)/d,[1 Inf]);

    % TORTUOSITY [new approach as variance of the mean angle]
    xyzdir = diff(xyzpath,1,2);
    theta = zeros(1,length(xyzdir));
    for i=1:length(xyzdir)-2
        theta(i) = angle3(xyzdir(:,i), xyzdir(:,i+1));
    end
    thetanorm = theta-mean(theta);
    branchdata.Tort_new(b) = std(thetanorm);

    J = linspace(0,1,rad_precision+2);
    J = J(2:end-1);
    r = NaN*ones(rad_precision,1);
    a = r;
    e = r;
    o = r;
    k = 1;
    for j=J
        % RADIUS
        intp = branchdata.Interp{b};
        tmax = intp.breaks(end);
        basep = ppval(intp,tmax*j);
        nextp = ppval(intp,tmax*j+tmax/pts_per_branch);
        normal = basep-nextp;
        normal = normal/norm(normal);
        % Slicing along the normal direction of the vessel 沿着血管的法线方向切片
        try
            [sl,xs,ys,zs] = obliqueslice(double(bw),round(basep)',normal',...
                'Method','nearest');
            % Looking for the point of the skeleton on the slice 在切片上查找骨架点
            skp = abs(xs-basep(1))<1 & abs(ys-basep(2))<1 & abs(zs-basep(3))<1;
            % NEW APPROACH WITH RECURSION 采用递归的新方法
            [x_skp, y_skp] = ind2sub(size(skp),find(skp));
            truesec = floodimg(sl,[round(mean(x_skp)),round(mean(y_skp))])==2;
            area = nnz(truesec);
            r(k) = sqrt(area/pi);
            if r(k)==0
                r(k) = 1;
            end
        catch
            errors = errors+1;
            %continue;
        end
        % LATERAL SURFACE AREA 横截面积
        a(k)= 2*pi*r(k)*branchdata.Len(b)/numel(J);
        % ECCENTRICITY and ORIENTATION 离心率和方向
        currecc = regionprops(truesec,'MajorAxisLength','MinorAxisLength','Orientation');
        if ~isempty(currecc)
            e(k) = sqrt(1-currecc.MinorAxisLength^2/currecc.MajorAxisLength^2);
            o(k) = currecc.Orientation;
        end
        k = k+1;
    end
    branchdata.Rad(b) = mean(r,'omitnan');
    branchdata.Alat(b) = mean(a,'omitnan');
    branchdata.Eccent(b) = mean(e,'omitnan');
    branchdata.Orientat(b) = mean(o,'omitnan');
    % Goodness condition of the vessel: Length > Radius*3 (arbitrary) 血管的良好条件：长度 > 半径*3（任意）
    branchdata.isGood(b) = branchdata.Len(b) > branchdata.Rad(b)*3;
    waitbar(b/steps,f,strcat(string(b),"/",string(tot_branches)," branches analyzed"))
end
delete(f)
if errors>0
    disp(strcat(string(errors),...
        " vessels had to be sliced with less precision than specified in current 'radius_precision'"));
end

% Scaling the metrics based on the downsampling and conversion to micrometers
branchdata.Rad = branchdata.Rad*pxdens(1)*downfactor;
branchdata.Len = branchdata.Len*pxdens(1)*downfactor;
branchdata.Alat = branchdata.Alat*(pxdens(1)^2)*(downfactor^2);

% CALCULATING THE REAL LATERAL AREA 计算实际横向面积
realAlat = nnz(bwmorph3(bw,'remove'));

% save results
VoCAT_Data.branchdata = branchdata;
VoCAT_Data.mRad = mean(branchdata.Rad(:),'omitnan');
bwd = bwdist(~bw);
bwdsk = bwd; bwdsk(sk==0) = 0;
VoCAT_Data.mRad_REAVER = mean(bwdsk(bwdsk>0),'all')*pxdens(1);
VoCAT_Data.mLen = mean(branchdata.Len(:),'omitnan');
VoCAT_Data.mTort = mean(branchdata.Tort(:),'omitnan');
VoCAT_Data.mEcc = mean(branchdata.Eccent(:),'omitnan');
VoCAT_Data.volFrac = nnz(bw)/(numel(bw));
VoCAT_Data.approxAlat = sum(branchdata.Alat(:),'omitnan'); % omitnan 自动忽略 NaN
VoCAT_Data.realAlat = realAlat*pxdens(1)^2*downfactor^2;
VoCAT_Data.S_over_V = VoCAT_Data.approxAlat/(nnz(bw)*pxdens(1)^3*downfactor^3);
VoCAT_Data.numSubN = numsn;
for i = 1:numsn
    if nnz(VoCAT_Data.skel.graph.Nodes.subN == i) == 1
        VoCAT_Data.numSubN = VoCAT_Data.numSubN - 1;
    end
end

% Completing the struct 'info'
VoCAT_Data.info.name = pathtoimg;
VoCAT_Data.info.pxdensity = pxdens;
VoCAT_Data.info.downfactor = downfactor;
VoCAT_Data.info.pts_per_branch = pts_per_branch;
VoCAT_Data.info.ragPrecision = rad_precision;
VoCAT_Data.info.length_thr = length_thr;
resultsave_path = strcat(string(pathtoimg),append_to_path,".mat");
save(resultsave_path,'VoCAT_Data');

disp(strcat("> Results saved at: ",resultsave_path));
clear a area b basep currecc d e intp J k len nextp normal r skp...
    sl theta thetanorm truesec xyzpath xyzdir xs ys zs x_skp y_skp i...
    tmax displine
end