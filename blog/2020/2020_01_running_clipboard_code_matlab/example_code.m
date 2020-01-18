function example_code




r1 = randi([10 100],1,1);
r2 = randi([10 100],1,1);
d1 = rand(1,r1);
d2 = rand(1,r2);
d3 = rand(1,r2);
diff_values = zeros(length(d1),length(d2));
for i = 1:length(d1)
    v1 = d1(i);
    for j = 1:length(d2)
        v2 = d2(j);
        if v2(j) > 0.5
            v2 = d3(j);
        end
        diff_values(i,j) = d1(j)-d2(i);
    end
end

