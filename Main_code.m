%Jonathan Roarty 2254735
clear all
%Main code which calls functions in the following operations:
%Code loads in sEMG and IM data
%Data is segmented
%Features are extracted
%Features are randomly assigned to training, validating and testing sets
%Features are reshaped
%Reshaped features are normalised
%Normalised features are used as input to ESN to validate
%Output of ESN is used to determine guessed gesture and validate model
%Training & validating are combined, then ESN run final time
%Guessed gestures are compared against testing label
%Accuracy calculated


%Below is notes about the data
%sampling rate 2000Hz. 
%MAV, WL, AR (4 coefficents), LogVAR are the 7 sEMG features
%MAV is the 1 Im feature (3 in total for each sensor x,y,z)


%number of features to be extracted in each window
num_feature = 16;
  
%number of combined sensors used
num_sensor = 12;

%dimention of data used for input to ESN
dimention = num_feature*num_sensor;

%number of gestures (output dimention for ESN)
num_gesture = (40+1); %+1 for rest

%% Function call to load in data
% 
% Function for loading in data
data_extract(num_gesture);
% 

%% Function call to process feature extraction
% 
% %pre-allocating training data feature matrix
feature = zeros((num_feature),(num_sensor+1));
% 
% %function call to extract features from training data
feature_extract(feature, num_sensor, num_gesture);

%% Random allocation of features for training and testing
%outputs are 3 matrices used as training and testing feature sets
[training_set, validating_set, testing_set] = seperate(num_gesture, num_sensor);


%% Function call to reshape matrix for ESN input
%Pre-allocating reshaped training features and traing label
resh_feature_train = zeros(length(training_set)/num_feature-1, dimention);
Lb_train = zeros(length(resh_feature_train),1);

%Function call to reshape training features and the training label
[reshape_train, label_train] = resha(training_set, resh_feature_train, Lb_train, ...
    num_feature, dimention, num_sensor);

%Removing preallocated matrix and previous uneeded feature matrix
clear resh_feature_train training_set Lb_train


%Pre-allocating reshaped validating features and label
resh_feature_valid = zeros(length(validating_set)/num_feature-1, dimention);
Lb_train = zeros(length(resh_feature_valid),1);

%Function call to reshape validating features and label
[reshape_valid, label_valid] = resha(validating_set, resh_feature_valid, Lb_train, ...
    num_feature, dimention, num_sensor);

%Removing preallocated matrix and previous uneeded feature matrix
clear resh_feature_valid validating_set Lb_train


%Pre-allocating reshaped testing features and traing label
resh_feature_test = zeros(length(testing_set)/num_feature-1, dimention);
Lb_test = zeros(length(resh_feature_test),1);

%Function call to reshape testing features and the testing label
[reshape_test, label_test] = resha(testing_set, resh_feature_test, Lb_test, ...
    num_feature, dimention, num_sensor);

%Removing preallocated matrix and previous uneeded feature matrix
clear resh_feature_test testing_set Lb_test


%% Function call to normalise reshaped matrix

%Function call to normalise reshaped training feature matrix
feature_norm_train = normalise(reshape_train, dimention);
%Transpose of nomralised training matrix
norm_train_set = feature_norm_train';

%Removing unneded matrix
clear  feature_norm_train reshape_train


%Function call to normalise reshaped training feature matrix
feature_norm_valid = normalise(reshape_valid, dimention);
%Transpose of nomralised training matrix
norm_valid_set = feature_norm_valid';

%Removing unneded matrix
clear  feature_norm_valid reshape_valid

%Function call to normalise reshaped testing feature matrix
feature_norm_test = normalise(reshape_test, dimention);
%Transpose of nomralised testing matrix
norm_test_set = feature_norm_test';

%Removing unneded matrix
clear feature_norm_test reshape_test

%% Re-arrange testing label to plot against ESN_output_Y

%Remapped label is pre-allocated
label_remap = zeros(num_gesture,length(label_valid));

%For loop to re-arrange label. 
%Each row is each gesture. 1 in row 1 means rest
for j = 1:41
label_remap(j,find(label_valid==(j-1))) =1;
end

label_changed = label_valid;

%% Function call to run ESN and validate parameter

%Inputs both training and validation feature matrices, and training label
%Outputs Y, Wout
C_acc = 0; %Keeps track of best accuracy
reg = 1e-8; %reg coefficient pre-assigned prior to validation
i = 1; %Keeps a record of classifcation accuracies
for a = 0.1:0.1:0.9
    [ESN_output_Y, Wout] = ESN(label_train, norm_train_set, norm_valid_set, dimention, num_gesture, a, reg);
    %Output Y is used to determine gesture guessed from testing features
    
    
    
    for p = 1:41
        %Finds index values where label matches p
        Gesture_index = find(label_remap(p,:) == 1);
        %ESN output at index values are saved 
        ESN_Values = ESN_output_Y(:,Gesture_index); %%%%ERRROR HERE???
        %Finds index values for the maximum ESN output at gesture p
        [High_Y , Gesture_Guesses] = max(ESN_Values);
        %Gesture remapped to correct numbers
        %I.e rest is now 0
        Gesture_Guesses = (Gesture_Guesses - 1);
        
        %Correct label is generated from transpose of corrected label
        Correct_label = label_changed(Gesture_index)';
        
        %Correct guessed gesture is where the guess equals the label
        Correct_Gesture = sum(Correct_label == Gesture_Guesses);
        
        %Accuracy of each gesture is saved individually
        %Accuracy calculated as a percentage
        Class_acc(p) = (Correct_Gesture/length(Gesture_index))*100;
    end
    
    %Finally mean of each gesture accuracy is calculated to avoid impact of any
    %heavily biased gestures
    Classification_acc(i) = mean(Class_acc);
    
    if Classification_acc(i) >%checks if new classifcation accuracy is best
        C_acc = Classification_acc; %saves new accuracy
        save_a = a; %saves new leaking rate coefficent
    end
    i = i+1;
end

a = save_a; %saves leaking rate coefficient for later

C_acc = 0;

clear Classification_acc
i = 1;
for reg = -1.1:0.2:1.1
   [ESN_output_Y, Wout] = ESN(label_train, norm_train_set, norm_valid_set, dimention, num_gesture, a, reg);
    %Output Y is used to determine gesture guessed from testing features
    
    
    for p = 1:41
        %Finds index values where label matches p
        Gesture_index = find(label_remap(p,:) == 1);
        %ESN output at index values are saved 
        ESN_Values = ESN_output_Y(:,Gesture_index); %%%%ERRROR HERE???
        %Finds index values for the maximum ESN output at gesture p
        [High_Y , Gesture_Guesses] = max(ESN_Values);
        %Gesture remapped to correct numbers
        %I.e rest is now 0
        Gesture_Guesses = (Gesture_Guesses - 1);
        
        %Correct label is generated from transpose of corrected label
        Correct_label = label_changed(Gesture_index)';
        
        %Correct guessed gesture is where the guess equals the label
        Correct_Gesture = sum(Correct_label == Gesture_Guesses);
        
        %Accuracy of each gesture is saved individually
        %Accuracy calculated as a percentage
        Class_acc(p) = (Correct_Gesture/length(Gesture_index))*100;
    end
    
    %Finally mean of each gesture accuracy is calculated to avoid impact of any
    %heavily biased gestures
    Classification_acc(i) = mean(Class_acc);
    
    if Classification_acc(i) > C_acc %checks if new classifcation accuracy is best
        C_acc = Classification_acc; %saves new accuracy
        save_reg = reg; %saves new reg coefficent 
    end
    i = i+1;
    
end

reg = save_reg; %Saves best regularization coefficient


%% Recombine training and validation sets

%Training set and validation set combined
norm_train_set = horzcat(norm_train_set,norm_valid_set);
%Training set label and validation set label combined
label_train = vertcat(label_train,label_valid);

%Old training and validation sets are removed
clear norm_valid_set label_valid save_reg C_acc save_a

%% Function call to run ESN and use test features

%Inputs both training and testing feature matrices, and training label
%Outputs Y, Wout
[ESN_output_Y, Wout] = ESN(label_train, norm_train_set, norm_test_set, dimention, num_gesture, a, reg);
%Output Y is used to determine gesture guessed from testing features



%%
%Figure 2 through 5 are plots of the ESN output against testing label

%Remapped label is pre-allocated
label_remap = zeros(num_gesture,length(label_test));

%For loop to re-arrange label. 
%Each row is each gesture. (1 in row 1 means rest)
for j = 1:41
label_remap(j,find(label_test==(j-1))) =1;
end

label_changed = label_test;


figure(2)
t = tiledlayout(10,1);
for iii = 1:10
    nexttile
    plot(ESN_output_Y(iii,:))
    hold on
    plot(label_remap(iii,:))
    xlim([0 1100])
    hold off
end
title(t, 'ESN output Y(n) Gestures 0 to 9', 'FontSize', 20)
xlabel(t, 'U(n) sample number','FontSize', 20)
ylabel(t, 'Strength of Y(n) output','FontSize', 20)


figure(3)
t = tiledlayout(10,1);
for iii = 11:20
    nexttile
    plot(ESN_output_Y(iii,:))
    hold on
    plot(label_remap(iii,:))
    xlim([1039 1460])
    hold off
end
title(t, 'ESN output Y(n) Gestures 10 to 19', 'FontSize', 20)
xlabel(t, 'U(n) sample number','FontSize', 20)
ylabel(t, 'Strength of Y(n) output','FontSize', 20)

figure(4)
t = tiledlayout(10,1);
for iii = 21:30
    nexttile
    plot(ESN_output_Y(iii,:))
    hold on
    plot(label_remap(iii,:))
    xlim([1440 1850])
    hold off
end
title(t, 'ESN output Y(n) Gestures 20 to 29', 'FontSize', 20)
xlabel(t, 'U(n) sample number','FontSize', 20)
ylabel(t, 'Strength of Y(n) output','FontSize', 20)

figure(5)
t = tiledlayout(11,1);
for iii = 31:41
    nexttile
    plot(ESN_output_Y(iii,:))
    hold on
    plot(label_remap(iii,:))
    xlim([1835 2279])
    hold off
end
title(t, 'ESN output Y(n) Gestures 30 to 40', 'FontSize', 20)
xlabel(t, 'U(n) sample number','FontSize', 20)
ylabel(t, 'Strength of Y(n) output','FontSize', 20)


%% Predicted gesture accuracy calculation

%This is done to match against ESN output.
label_changed = label_test;

for p = 1:41
    %Finds index values where label matches p
    Gesture_index = find(label_remap(p,:) == 1);
    %ESN output at index values are saved
    ESN_Values = ESN_output_Y(:,Gesture_index);
    %Finds index values for the maximum ESN output at gesture p
    [High_Y , Gesture_Guesses] = max(ESN_Values);
    %Gesture remapped to correct numbers
    %I.e rest is now 0
    Gesture_Guesses = (Gesture_Guesses - 1);
    
    %Correct label is generated from transpose of corrected label
    Correct_label = label_changed(Gesture_index)';
    
    %Correct guessed gesture is where the guess equals the label
    Correct_Gesture = sum(Correct_label == Gesture_Guesses);
    
    %Accuracy of each gesture is saved individually
    %Accuracy calculated as a percentage
    Class_acc(p) = (Correct_Gesture/length(Gesture_index))*100;
end

%Finally mean of each gesture accuracy is calculated to avoid impact of any
%heavily biased gestures
Classification_acc = mean(Class_acc);


%% Confusion matrix

%C is a placeholder to save values to high_Y and Gesture
C = 1; 

%For loop used to find each output of the ESN and find what gesture is
%guessed

for p = 1:length(ESN_output_Y)
    %Each output column is windowed (shows strength of each gesture)
    Window_Y = ESN_output_Y(:,p); 
    %Takes mean across row
    %Useful if averaging across multiple points of ESN output
    Average_Y = mean(Window_Y,2);
    %Max value taken as guessed gesture from ESN output
    [High_Y(C) , Gesture(C)] = max(Average_Y); 
    C=C+1; %moves position for above matrices along
end

%Reformat to compare against testing label
Gesture = Gesture'; 

%Gesture has to be remapped to match remapped testing label
Gesture_remap = zeros(num_gesture,length(label_test));

for j = 1:41
Gesture_remap(j,find(Gesture==(j))) =1;
end

%Figure 6 is the plot of the confusion matrix
figure(6)

Gesture_full = Gesture -1;
class_labels = linspace(0,40,41);
[m,order] = confusionmat(label_test, Gesture_full);
cm = confusionchart(m,class_labels);
cm.Title = 'Confusion Chart of Gesture Classifcation';
cm.DiagonalColor = 'b';
cm.FontSize = 16;
cm.GridVisible = 'off';
cm.XLabel = 'Gesture Guesses';
cm.YLabel = 'Testing Label / Correct Gestures';
cm.ColumnSummary = 'column-normalized';





