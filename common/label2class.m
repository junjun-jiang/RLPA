function label_fusion = label2class(labels_map,randpp,indian_pines_gt,CTest,trainnumber); 

a = 1;
for i = 1:max(indian_pines_gt(:))
    [v]=find(indian_pines_gt==i);    
    cTest  = CTest(i);
    index = randpp{i}; 
    b = sum(CTest(1:i));
    label_fusion(a:b) = labels_map(v(index(1:cTest)));    
    a = b+1;    
end



