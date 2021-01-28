function data_extract(num_gesture)

%Directory where raw data is stored
filedir = 'C:\Users\Jona\OneDrive - University of Glasgow\EMG-Masters-JR-XP-2020\Data';
Content = dir(filedir);
SubFold = Content([Content.isdir]);

G = num_gesture -1 ; %Gesture cap, -1 as rest is 0

%data loaded in by parfor loop and segmented
parfor k = 1:20
    filename = sprintf('S%d_E1_A1', k); %dynamic filename generated
    filetoread = fullfile(filedir,SubFold(1).name,filename); %filename to read
    
    
    label_data = load(filetoread, '-mat','restimulus'); %loads in data label

    label_data = label_data.restimulus; %Makes data useable format
    
    %data 1 split for gestures 0 to 17
    for c = 0:17
        
        label_index = find(label_data==c)';  %index label checked for gesture number
        
        X = cumsum([true,diff(label_index)~=1]); %label indexes are saved
        xt = accumarray(X(:),label_index(:),[],@(m){m}); % length of data stored
        
        ArrayA = cell(numel(xt),5); %cell array generated to store segmented data + label
        
        %loop for all index values for gesture number
        for i = 1: numel(xt)  
            
            XT = xt{i}; % XT saves index position of label to use for data
          
            emg_data = load(filetoread, '-mat','emg');
            emg = emg_data.emg(XT,(1:12)); %Data from emg for gesture is loaded
            
            acc_data = load(filetoread, '-mat','acc');
            acc = acc_data.acc(XT,(1:36)); %Data from acc for gesture is loaded
            
            gyr_data = load(filetoread, '-mat','gyro');
            gyr = gyr_data.gyro(XT,(1:36)); %Data from gyro for gesture is loaded
            
            mag_data = load(filetoread, '-mat','mag');
            mag = mag_data.mag(XT,(1:36)); %Data from mag for gesture is loaded
            
            %data and label are assigned to cell array rows
            ArrayA{i,1} = emg;
            ArrayA{i,2} = acc;
            ArrayA{i,3} = gyr;
            ArrayA{i,4} = mag;
            ArrayA{i,5} = label_data(XT);
            
        end

        parsave(ArrayA, k, c); %cell array is saved to storage
                
    end
    
end

%data loaded in by parfor loop and segmented
parfor k = 1:20
    filename = sprintf('S%d_E2_A1', k); %dynamic filename generated
    filetoread = fullfile(filedir,SubFold(1).name,filename); %filename to read
    
    
    label_data = load(filetoread, '-mat','restimulus'); %loads in data label

    label_data = label_data.restimulus; %Makes data useable format
    
    %set 2 is gesture 18 to 40
    for c = 18:num_gesture
        
        label_index = find(label_data==c)';  %index label checked for gesture number
        
        X = cumsum([true,diff(label_index)~=1]); %label indexes are saved
        xt = accumarray(X(:),label_index(:),[],@(m){m}); % length of data stored
        
        ArrayA = cell(numel(xt),5); %cell array generated to store segmented data + label
        
        %loop for all index values for gesture number
        for i = 1: numel(xt)  
            
            XT = xt{i}; % XT saves index position of label to use for data
          
            emg_data = load(filetoread, '-mat','emg');
            emg = emg_data.emg(XT,(1:12)); %Data from emg for gesture is loaded
            
            acc_data = load(filetoread, '-mat','acc');
            acc = acc_data.acc(XT,(1:36)); %Data from acc for gesture is loaded
            
            gyr_data = load(filetoread, '-mat','gyro');
            gyr = gyr_data.gyro(XT,(1:36)); %Data from gyro for gesture is loaded
            
            mag_data = load(filetoread, '-mat','mag');
            mag = mag_data.mag(XT,(1:36)); %Data from mag for gesture is loaded
            
            %data and label are assigned to cell array
            ArrayA{i,1} = emg;
            ArrayA{i,2} = acc;
            ArrayA{i,3} = gyr;
            ArrayA{i,4} = mag;
            ArrayA{i,5} = label_data(XT);
            
        end

        parsave(ArrayA, k, c); %cell array is saved to storage
                
    end
    
end


end

