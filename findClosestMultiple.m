function closestMultiple = findClosestMultiple(num)
% 基数设置为128
base = 128;

% 计算距离下一个较大的128倍数和较小的128倍数的差
remainder = mod(num, base);

if remainder > base / 2
    % 如果余数大于64，向上取整
    closestMultiple = num + (base - remainder);
else
    % 否则向下取整
    closestMultiple = num - remainder;
end
end