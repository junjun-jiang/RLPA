clear all; close all; clc;warning('off'),
addpath(genpath(cd));

window = 3;
datasets = {'Indian','PaviaU','Salinas'};
datasets = {'Indian'};


for idataset = 1:length(datasets)
    dataset = datasets{idataset};
    Predict_labels = [];
    
if strcmp(dataset,'Indian')==1
    load Indian_pines_corrected;load Indian_pines_gt;load Indian_pines_randp %s=2 10^1 0.01
    paviaU = indian_pines_corrected;
    paviaU_gt = indian_pines_gt;
    trainnumber = 0.1; Ratio = 0.0812;% the value of Ratio can be obtained by the function of "Edge_ratio3" in the function of "cubseg"
    
elseif strcmp(dataset,'PaviaU')==1
    load PaviaU;load PaviaU_gt;load PaviaU_randp % s=8 10^6 0.01
    trainnumber = 50; Ratio = 0.0664;

elseif strcmp(dataset,'Salinas')==1
    load Salinas_corrected;load Salinas_gt;load Salinas_randp %  s=2 10^1 0.01
    paviaU = salinas_corrected;
    paviaU_gt = salinas_gt;
    trainnumber = 50; Ratio = 0.0513;
end

% smoothing
for i=1:size(paviaU,3);
    paviaU(:,:,i) = imfilter(paviaU(:,:,i),fspecial('average',window));
end

SegPara = 2000;
% superpixel segmentation
labels = cubseg(paviaU,SegPara*Ratio);

gammaa   =[0:0.1:0.5];   %[0.01 0.02 0.03 0.05 0.07 0.1:0.05:0.5]
gammaa   =[0.1];   %[0.01 0.02 0.03 0.05 0.07 0.1:0.05:0.5]

method = {'NN','SVM','RF','ELM'};%method = {'ELM','NN','SVM','NRS','CRT','RF'};
method = {'ELM'};

for imethod = 1:length(method)
    
    switch method{imethod}
        case 'NN'
            lambdaa   = [1]; % NN
        case 'SVM'
            lambdaa   = [0.01 0.1 1 10]; % SVM
        case 'RF'
            lambdaa   = [100];
        case 'ELM'                        
            lambdaa   = 2.^[8 10 12 14]; % elm
    end

    for iter = 1:10
        
        randpp=randp{iter};  
        % randomly divide the dataset to training and test samples    
        [DataTest, DataTrain, CTest, CTrain, Loc_test] = samplesdivide(paviaU,paviaU_gt,trainnumber,randpp);

        for igamma = 1:size(gammaa,2)             

            % generate the transformation matrix
            [A] = supSimALL(paviaU,paviaU_gt,trainnumber,randpp,labels);  
            
            fprintf('\nDataset:%7s, Method: %2s, Round: %2d, Noise: %.4f\n', dataset, method{imethod}, iter, gammaa(igamma));
            % Get label from the class num
            trainlabel = getlabel(CTrain);  
            testlabel  = getlabel(CTest);  
            trainlabel_nl = label2noisylabel(trainlabel,gammaa(igamma));       
            fprintf('Noisy pixel number = %3d ',length(find(trainlabel_nl-trainlabel~=0)));
      
            % RLPA
            [trainlabel_nl] = randlabelpropagation(trainlabel_nl, A, gammaa(igamma));                 
            fprintf('and Noisy pixel number after RLPA = %3d\n',length(find(trainlabel_nl-trainlabel~=0)));
            DataTrain_nl = DataTrain;

            tempaccy = 0;
            Predict_label_best = [];
            for ilambda = 1:size(lambdaa,2)
                lambda = lambdaa(ilambda); % need to find the optimal
                switch method{imethod}
                    case 'NN'
                        Predict_label = knnclassify(DataTest,DataTrain_nl,trainlabel_nl,lambda,'euclidean');
                    case 'ELM'                        
                        [TTrain,TTest,TrainAC,accur_ELM,TY,Predict_label] = elm_kernel([trainlabel_nl' DataTrain_nl],[testlabel' DataTest],1,lambda,'RBF_kernel',1);
                    case 'SVM'
                        [Predict_label, ~,~] = svmpredict(testlabel', DataTest, svmtrain(trainlabel_nl', DataTrain_nl, ['-q -c 100000 -g ' num2str(lambda) ' -b 1']), '-b 1');    Predict_label =Predict_label';   
                    case 'RF'                       
                        Factor = TreeBagger(lambda, DataTrain, trainlabel_nl);
                        [Predict_label_temp,Scores] = predict(Factor, DataTest);                        
                        for ij=1:length(Predict_label_temp); Predict_label(ij) = str2num(Predict_label_temp{ij}); end;   
                end       
                [confusion, accur_NRS, TPR, FPR] = confusion_matrix_wei(Predict_label, CTest);                
                accy(idataset,imethod,iter,igamma,ilambda) = accur_NRS; 
            end   
       end
    end     
end    
end

save(['.\Resuts Label_propagation=',num2str(1),'_',dataset,'_Layer_1_SP',num2str(SegPara),'_2000_Accy.mat'],'accy')


