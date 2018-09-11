function indian_pines_map = class2label(predict_label,trainlabel_nl,randpp,indian_pines_gt,CTest,CTrain);
indian_pines_map = indian_pines_gt;
a = 1;
at = 1;
for i = 1:max(indian_pines_gt(:))
    [v]=find(indian_pines_gt==i);    
    cTest  = CTest(i);
    index = randpp{i}; 
    b = sum(CTest(1:i));
    indian_pines_map(v(index(1:cTest))) = predict_label(a:b);   
    
    
    bt = sum(CTrain(1:i));
    indian_pines_map(v(index(cTest+1:end))) = trainlabel_nl(at:bt);  
    at = bt+1;
    
    
    a = b+1;    
end

