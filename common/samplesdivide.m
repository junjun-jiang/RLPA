function [DataTest, DataTrain, CTest2, CTrain, Loc_test] = samplesdivide(indian_pines_corrected,indian_pines_gt,train,randpp);
CTest2 = [];
percent = 0.20;
[m n p] = size(indian_pines_corrected);
CTrain = [];CTest = [];
DataTest  = [];
DataTrain = [];
indian_pines_map = uint8(zeros(m,n));
data_col = reshape(indian_pines_corrected,m*n,p);
[mm nn] = ind2sub([m n],1:m*n);

Loc_test = [];
for i = 1:max(indian_pines_gt(:))
    ci = length(find(indian_pines_gt==i));
    
    [v]=find(indian_pines_gt==i);
    
    datai = data_col(find(indian_pines_gt==i),:);
    if train>1
        cTrain = round(train);
    else
        cTrain  = round(train*ci); 
    end
    cTest  = ci-cTrain;
%     cTest = round(0.2*ci);
    CTrain = [CTrain cTrain];
    CTest = [CTest cTest];
%     index = randperm(ci);
    index = randpp{i};
    step = 1;
    DataTest = [DataTest; datai(index(1:step:cTest),:)];
    CTest2 = [CTest2 size(datai(index(1:step:cTest),:),1)];
    DataTrain = [DataTrain; datai(index(cTest+1:cTest+cTrain),:)];
    Loc_test = [Loc_test; v(index(1:step:cTest))];    
end
% indian_pines_map = reshape(indian_pines_map,m,n);

Normalize = max(max(DataTrain));
DataTrain = DataTrain./Normalize;
DataTest = DataTest./Normalize;