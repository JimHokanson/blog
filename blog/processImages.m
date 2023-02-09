function processImages(root_or_file_path)

%For this let's actually just make a quick GUI that
%1) resizes image
%2) adds border

if nargin == 0
    root_or_file_path = uigetdir('','Pick blog root');
    if isnumeric(root_or_file_path)
        return
    end
end

if exist(root_or_file_path,'dir')
    root = root_or_file_path;
    d = dir(fullfile(root,'*.png'));
    file_paths = cell(1,length(d));
    for i = 1:length(d)
        file_paths = fullfile(d(i).folder,d(i).name);
    end  
end

end