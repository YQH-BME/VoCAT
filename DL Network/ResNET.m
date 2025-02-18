% 创建一个标准的 ResNet 风格的分割网络
inputSize = [128 128 8 1];
numClasses = 2; % 假设分割为二类：背景和目标

layers = [
    image3dInputLayer(inputSize, 'Name', 'input')
    
    % 第一个残差块
    convolution3dLayer(3, 16, 'Padding', 'same', 'Name', 'conv1')
    batchNormalizationLayer('Name', 'bn1')
    reluLayer('Name', 'relu1')
    
    % 残差连接
    convolution3dLayer(3, 16, 'Padding', 'same', 'Name', 'conv2')
    batchNormalizationLayer('Name', 'bn2')
    additionLayer(2, 'Name', 'add1')
    reluLayer('Name', 'relu2')
    
    % 下采样块
    maxPooling3dLayer(2, 'Stride', 2, 'Name', 'maxpool1')
    
    % 第二个残差块
    convolution3dLayer(3, 32, 'Padding', 'same', 'Name', 'conv3')
    batchNormalizationLayer('Name', 'bn3')
    reluLayer('Name', 'relu3')
    
    % 残差连接
    convolution3dLayer(3, 32, 'Padding', 'same', 'Name', 'conv4')
    batchNormalizationLayer('Name', 'bn4')
    additionLayer(2, 'Name', 'add2')
    reluLayer('Name', 'relu4')
    
    % 下采样块
    maxPooling3dLayer(2, 'Stride', 2, 'Name', 'maxpool2')
    
    % 第三个残差块
    convolution3dLayer(3, 64, 'Padding', 'same', 'Name', 'conv5')
    batchNormalizationLayer('Name', 'bn5')
    reluLayer('Name', 'relu5')
    
    % 残差连接
    convolution3dLayer(3, 64, 'Padding', 'same', 'Name', 'conv6')
    batchNormalizationLayer('Name', 'bn6')
    additionLayer(2, 'Name', 'add3')
    reluLayer('Name', 'relu6')
    
    % 上采样块
    transposedConv3dLayer(4, 64, 'Stride', 2, 'Cropping', 'same', 'Name', 'upsample1')
    reluLayer('Name', 'relu7')
    
    % 上采样块 2
    transposedConv3dLayer(4, 32, 'Stride', 2, 'Cropping', 'same', 'Name', 'upsample2')
    reluLayer('Name', 'relu8')
    
    % 最后一层卷积，用于分割
    convolution3dLayer(1, numClasses, 'Name', 'final_conv')
    softmaxLayer('Name', 'softmax')
    pixelClassificationLayer('Name', 'pixel_classification')
];

lgraph = layerGraph(layers);

% 添加残差连接
lgraph = connectLayers(lgraph, 'relu1', 'add1/in2');
lgraph = connectLayers(lgraph, 'relu3', 'add2/in2');
lgraph = connectLayers(lgraph, 'relu5', 'add3/in2');

% 显示网络结构
plot(lgraph);