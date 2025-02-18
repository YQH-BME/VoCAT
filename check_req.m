function req_ok = check_req(req)
v = ver;
req_ok = zeros(1,length(req));
for j = 1:length(req)
    for i = 1:length(v)
        req_ok(j) = strcmp(v(i).Name,req(j)) || req_ok(j);
    end
end
req_ok = all(req_ok);
end