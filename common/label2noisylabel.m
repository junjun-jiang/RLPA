function paviaU_gt_nl = label2noisylabel(paviaU_gt,ratio);

rand('seed',0);

[m n] = size(paviaU_gt);
classNum = max(paviaU_gt(:));

R = rand(m,n);
R9 = ceil(classNum*rand(m,n));
paviaU_gt_nl = paviaU_gt;
for i=1:m
    for j=1:n
        if paviaU_gt(i,j)~=0
            if R(i,j)<=ratio
%                 paviaU_gt_nl(i,j) = R9(i,j);  %noisy label includes itself
                
                temp = randperm(classNum);
                ind = find(temp==paviaU_gt(i,j));
                temp(ind)=[];
                paviaU_gt_nl(i,j) = temp(end);
                
                
            end
        end
    end
end