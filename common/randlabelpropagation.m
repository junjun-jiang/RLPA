function [label_pre] = randlabelpropagation(trainlabel_nl, A, gamma)

T = zeros(size(trainlabel_nl,2),max(trainlabel_nl));
for iCTrain=1:max(trainlabel_nl) 
    ind = find(trainlabel_nl==iCTrain);
    T(ind,iCTrain)=1;
end

S = round(0.3*size(trainlabel_nl,2));
AA = inv(eye(size(A,1)) - 0.90 * A);

for iter = 1:100
    Tr = T;
    temprand = randperm(size(Tr,1));
    Tr(temprand(1:S),:)=0;    
    Tr = [Tr;zeros(size(AA,1)-size(trainlabel_nl,2),size(Tr,2))];
    F = AA * Tr; % classification function F = (I - \alpha S)^{-1}Y
    [~, label_temp] = max(F, [], 2); %simply checking which of elements is largest in each row
    label(iter,:) = label_temp(1:size(trainlabel_nl,2));
end
[label_pre] = label_fusion(label');
label_pre = label_pre';






