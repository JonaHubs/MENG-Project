%% Function call normalising data
function [feature_norm] = normalise(resh_feature, dimention)
for i = 1:dimention
   
    %normalise for each column of reshape matrix
    Col_median = median(resh_feature(:,i)); %median calculated
    Col_norm = (resh_feature(:,i)-Col_median); %normalised by median
    feature_norm(:,i) = Col_norm; %features to be saved
    
end
end
