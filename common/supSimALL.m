function [A] = supSimALL(indian_pines_corrected,indian_pines_gt,train,randpp,labels);

[m n p] = size(indian_pines_corrected);

DataTrain = [];DataTest=[];

data_col = reshape(indian_pines_corrected,m*n,p);
[mm nn] = ind2sub([m n],1:m*n);
data_col = [mm' nn' data_col];

for i = 1:max(indian_pines_gt(:))
    ci = length(find(indian_pines_gt==i));

    datai = data_col(find(indian_pines_gt==i),:);
    if train>1
        cTrain = round(train);
    else
        cTrain  = round(train*ci); 
    end
    cTest  = ci-cTrain;

    index = randpp{i};
    
    DataTest = [DataTest; datai(index(1:cTest),:)];
    DataTrain = [DataTrain; datai(index(cTest+1:cTest+cTrain),:)];
 
end

Normalize = max(max(DataTrain(:,3:end)));
DataTrain(:,3:end) = DataTrain(:,3:end)./Normalize;
DataTest(:,3:end) = DataTest(:,3:end)./Normalize;

A = zeros(size(DataTrain,1));
tt = sub2ind([m n],DataTrain(:,1),DataTrain(:,2));
label_train = labels(tt);


for la = min(labels(:)):max(labels(:))
    la_ind = find(la==label_train);
    if size(la_ind,1)~=0
        if size(la_ind,1)==1 %如果这个超像素只有一个像素，那么其权重是1
            A(la_ind,la_ind) = 1;
        else
            temp = DataTrain(la_ind,3:end);
            A(la_ind,la_ind) = affinitymatrix(temp,my_sigma(temp));
        end
    end
end

function S = affinitymatrix(X,sigma)
N = size(X, 1);

%================================================================
% Step 1: Affinity matrix
%================================================================
M = zeros(N, N); % norm matrix
for i = 1:N % compute the pairwise norm
    for j = (i+1):N
        M(i, j) = norm(X(i, :) - X(j, :)); 
        M(j, i) = M(i, j);
    end;
end;

% Use a Gaussian to form an affinity matrix
K = exp(-M.^2/(2*sigma^2));  

% zero diag. very very important! 
%pcolor(K),shading interp, colorbar,pause

K = K - eye(N); 

%figure,pcolor(K),shading interp, colorbar,pause
%================================================================
% Step 2: Symmetrical normalization
%================================================================
D = diag(1./sqrt(sum(K))); % the inverse of the square root of the degree matrix

S = D*K*D; %normalize the affinity matrix

function sigma_X = my_sigma(X)

N = size(X,1);
num = 0;
for i=2:N    
    for j=1:i-1
        num = num+1;
        temp(num) = sum((X(i,:)-X(j,:)).^2);
    end
end

sigma_X = 0.5*sqrt(mean(temp));


