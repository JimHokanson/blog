function addBorder()

[file_names, file_root] = uigetfile({'*.png'},'Pick some images', 'MultiSelect', 'on');

for i = 1:length(file_names)
    [~,file_name_no_ext,ext] = fileparts(file_names{i});
    file_path = fullfile(file_root,file_names{i});
    new_name = [file_name_no_ext '_wb' ext];
    file_path2 = fullfile(file_root,new_name);
    
    imdata = imread(file_path);
    %x,y,3
    %
    %
    sz = size(imdata);
    sz(1) = sz(1) + 4;
    sz(2) = sz(2) + 4;
    im2 = zeros(sz,'uint8');
    im2(3:end-2,3:end-2,:) = imdata;
    imwrite(im2,file_path2)
end


end