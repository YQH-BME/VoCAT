layers_4 = [
    image3dInputLayer(inputSize)
    
    % 编码器部分（Encoder）
    % 编码块1
    convolution3dLayer(3, 16, 'Padding', 'same', 'Name', 'encoder1_conv1')
    reluLayer('Name', 'encoder1_relu1')
    batchNormalizationLayer('Name', 'encoder1_bn1')
    maxPooling3dLayer(2, 'Stride', 2, 'Name', 'encoder1_pool')

    % 编码块2
    convolution3dLayer(3, 32, 'Padding', 'same', 'Name', 'encoder2_conv1')
    reluLayer('Name', 'encoder2_relu1')
    batchNormalizationLayer('Name', 'encoder2_bn1')
    maxPooling3dLayer(2, 'Stride', 2, 'Name', 'encoder2_pool')
    
    % 编码块3
    convolution3dLayer(3, 64, 'Padding', 'same', 'Name', 'encoder3_conv1')
    reluLayer('Name', 'encoder3_relu1')
    batchNormalizationLayer('Name', 'encoder3_bn1')
    
    % 解码器部分（Decoder）
    % 解码块1 - 对应编码块3
    transposedConv3dLayer(4, 32, 'Stride', 2, 'Cropping', 'same', 'Name', 'decoder1_upsample')
    reluLayer('Name', 'decoder1_relu1')
    
    % 跳跃连接1
    depthConcatenationLayer(2, 'Name', 'concat1') % 跳跃连接，结合编码块2的输出

    convolution3dLayer(3, 32, 'Padding', 'same', 'Name', 'decoder1_conv1')
    reluLayer('Name', 'decoder1_relu2')
    batchNormalizationLayer('Name', 'decoder1_bn1')
    
    % 解码块2 - 对应编码块2
    transposedConv3dLayer(4, 16, 'Stride', 2, 'Cropping', 'same', 'Name', 'decoder2_upsample')
    reluLayer('Name', 'decoder2_relu1')

    % 跳跃连接2
    depthConcatenationLayer(2, 'Name', 'concat2') % 跳跃连接，结合编码块1的输出

    convolution3dLayer(3, 16, 'Padding', 'same', 'Name', 'decoder2_conv1')
    reluLayer('Name', 'decoder2_relu2')
    batchNormalizationLayer('Name', 'decoder2_bn1')
    
    % 最后一层，用于生成最终的分割
    convolution3dLayer(1, numClasses, 'Name', 'final_conv')
    softmaxLayer('Name', 'softmax')
    outp
];

% 创建层图
lgraph = layerGraph(layers_4);

% 添加跳跃连接（skip connections）
lgraph = connectLayers(lgraph, 'encoder2_bn1', 'concat1/in2');
lgraph = connectLayers(lgraph, 'encoder1_bn1', 'concat2/in2');