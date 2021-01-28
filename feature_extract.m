function feature_extract(feature,num_sensor, num_gesture)

filedir = 'C:\Users\Jona\OneDrive - University of Glasgow\EMG-Masters-JR-XP-2020\Segmented_data\';
Content = dir(filedir);
SubFold = Content([Content.isdir]);


for S = 1:20 %load in subject number
    
    
    for c = 0:40 %load in gesture
        U = 1; %placeholder to save features to matrix
        filename = sprintf('S%d_G%d',S,c); %dynamic name for segmented data
        filetoread = fullfile(filedir,SubFold(1).name,filename);
        cell_array = load(filetoread, '-mat'); %cell array is loaded in
        cell_array = cell_array.ArrayA;
        
        feature_cell = cell(length(cell_array),1); %creates cell array for number of repitions of gesture
        for i = 1:length(cell_array) %seperate each row in cell array
            
            %data is pulled out of cell array into variables
            emg_data = double(cell_array{i,1});
            acc_data = cell_array{i,2};
            gyr_data = cell_array{i,3};
            mag_data = cell_array{i,4};
            %IM data is combined
            Im_data = horzcat(acc_data,gyr_data,mag_data);
            
            %old variables removed
            clear acc_data gyr_data mag_data
            
            label_data = (cell_array{i,5}(2)); %gesture label is stored
            
            feature((U:U+15),(num_sensor+1)) = label_data; %feature matrix is generated to store features
            WL = 0; 
            
            %wavelength feature extracted from sEMG
            for z = 2:length(emg_data)
                deltaf(1:num_sensor) = abs(emg_data(z,1:num_sensor) - emg_data(z-1,1:num_sensor));
                %difference in voltage sEMG
                WL = WL + deltaf; %summnation with each step
            end
            
            %MAV feature extracted from sEMG
            emg_MAV = mean(abs(emg_data)); %Mean absolute value
            
            %LogVAR extracted from sEMG
            LogVAR = var(log(emg_data)); %Log varience
            
            %AR coefficients are extracted from sEMG
            coeff = aryule(emg_data,4); % 4th order linear Yule regression
            
            coeff = coeff.'; %transpose of coefficients
            
            %sEMG features are stored to feature matrix
            feature(U,(1:num_sensor)) = WL; %saves WL to postion one in matrix
            feature(U+1,(1:num_sensor)) = emg_MAV; %saves MAV to postion two in matrix
            feature(U+2,(1:num_sensor)) = LogVAR; %saves LogVAR to postion one in matrix
            feature(U+3,(1:num_sensor)) = coeff(2,(1:num_sensor)); %saves 2,3,4,5 coefficients from AR
            feature(U+4,(1:num_sensor)) = coeff(3,(1:num_sensor));
            feature(U+5,(1:num_sensor)) = coeff(4,(1:num_sensor));
            feature(U+6,(1:num_sensor)) = coeff(5,(1:num_sensor));
            
            %MAV feature extracted from IM data
            im_MAV = mean(abs(Im_data));
            im_MAV = im_MAV';
            p = 1;
            
            %IM features assigned to feature matrix
            for  u = 1:12
                feature(U+7:U+9,u) = im_MAV(p:p+2); %ACC features
                feature(U+10:U+12,u) = im_MAV(p+36:p+38); %Gyro features
                feature(U+13:U+15,u) = im_MAV(p+72:p+74); %MAG features
                p = p+3;
            end
            feature_cell{i} = feature; %feature matrix stored in cell array
        end
        %once all repeititons are assigned to feature cell
        %cell array are saved to new directory
        filenamed = sprintf('Fea_S%d_G%d', S, c); %dynamic feature cell naming
        pathname = fileparts('C:\Users\Jona\OneDrive - University of Glasgow\EMG-Masters-JR-XP-2020\Segmented_feature\');
        file = fullfile(pathname,filenamed);
        
        save(file, 'feature_cell');
        
    end
    
end

end

        
