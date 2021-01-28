function parsave(ArrayA, k, c)
%dynamic file name generated
filenamed = sprintf('S%d_G%d', k, c);
%directory to save segemneted data is created
pathname = fileparts('C:\Users\Jona\OneDrive - University of Glasgow\EMG-Masters-JR-XP-2020\Segmented_data');
file = fullfile(pathname,filenamed);
%file is saved
save(file, 'ArrayA')
end
