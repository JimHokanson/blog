function enforceMaxWidth()

    root = uigetdir('','Pick blog root');
    if isnumeric(root)
        return
    end
    
    d = dir(fullfile(root,'*.png'));
    for i = 1:length(d)
        file_path = fullfile(d(i).folder,d(i).name);
        imdata = imread(file_path);
        sz = size(imdata);
        keyboard
        
    end  

end

