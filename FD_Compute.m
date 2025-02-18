function FD = FD_Compute(skeleton)
box_sizes = 2:2:floor(min(size(skeleton))/2);
counts = zeros(length(box_sizes), 1);

for k = 1:length(box_sizes)
    box_size = box_sizes(k);
    counts(k) = box_count_3d(skeleton, box_size);
end

log_box_sizes = log(1 ./ box_sizes); 
log_counts = log(counts); 
p = polyfit(log_box_sizes, log_counts, 1); 
FD = p(1);  

end