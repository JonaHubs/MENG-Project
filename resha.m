%% Function call reshaping matrix
function [resh_feature,Lb] = resha(feature, resh_feature, Lb, num_feature, dimention, num_sensor)
%seperation of feature and label
AllFeatures = feature(:,1:num_sensor);

for i = 1:(length(AllFeatures)-1)/num_feature
   %features reshaped
   resh_feature(i,:) = reshape(AllFeatures((i-1)*num_feature+1:(i-1) ...
       *num_feature+num_feature,:),[1,dimention]);
   Lb(i) = feature((i-1)*num_feature+1,num_sensor+1); %label to be saved at yt
end
end
