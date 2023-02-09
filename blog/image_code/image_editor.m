classdef image_editor < handle
    %
    %   Class:
    %   image_editor
    
    %{
                        UIFigure: [1×1 Figure]
          load_folder_button: [1×1 Button]
    FileSelectorListBoxLabel: [1×1 Label]
                   file_list: [1×1 ListBox]
                  add_border: [1×1 Button]
        FolderEditFieldLabel: [1×1 Label]
             folder_edit: [1×1 EditField]
            BorderWidthLabel: [1×1 Label]
                border_width: [1×1 NumericEditField]
               resize_button: [1×1 Button]
       WidthpxEditFieldLabel: [1×1 Label]
                resize_width: [1×1 NumericEditField]
    %}
    
    properties (Constant)
        NULL_FILE = '--- null ---';
    end
    
    properties
        h
        root
        file_paths
        h_fig_image
        img_data
        img_file_path
    end
    
    methods
        function obj = image_editor()
            obj.h = img_app();
            
            obj.h.file_list.Multiselect = 'on';
            
            %Callbacks
            %----------------------
            obj.h.load_folder_button.ButtonPushedFcn = @(~,~)obj.loadDirectory();
            obj.h.file_list.ValueChangedFcn = @(~,~)obj.selectImage();
            obj.h.resize_button.ButtonPushedFcn = @(~,~)obj.resizeImage();
            obj.h.add_border.ButtonPushedFcn = @(~,~)obj.addBorder();
            obj.h.save_image_button.ButtonPushedFcn = @(~,~)obj.saveImage();
            
            %Startup
            %-------------------------
            %obj.loadDirectory();
            obj.setSaveButtonVisibility(false);
        end
        function saveImage(obj)
            
            file_name = obj.h.file_list.Value{1};
            
            if strcmp(file_name,obj.NULL_FILE)
                return
            end
            
            obj.img_file_path = fullfile(obj.root,file_name);
            
            imwrite(obj.img_data,obj.img_file_path);
            
        end
        function resizeImage(obj)
            
            new_width = obj.h.resize_width.Value;
            current_width = size(obj.img_data,2);
            
            scale = new_width/current_width;
            
            new_img_data = imresize(obj.img_data,scale);
            
            obj.img_data = new_img_data;
            
            obj.displayImage();
            
            %
            obj.setSaveButtonVisibility(true);
        end
        function setSaveButtonVisibility(obj,set_on)
            if set_on
                flag = 'on';
            else
                flag = 'off';
            end
            obj.h.save_image_button.Visible = flag;
        end
        function addBorder(obj)
            border_width = obj.h.border_width.Value;
            data = obj.img_data;
            
            %TODO: Don't add if already present
            
            sz = size(data);
            
            sz1 = sz(1)+2*border_width;
            sz2 = sz(2)+2*border_width;
            new_data = zeros(sz1,sz2,sz(3),'like',data);
            
            new_data(border_width+1:end-border_width,border_width+1:end-border_width,:) = data;
            
            obj.img_data = new_data;
            
            obj.displayImage();
            
            obj.setSaveButtonVisibility(true);
        end
        function selectImage(obj)
            %
            %   Close figure if it exists
            if isvalid(obj.h_fig_image)
                clf(obj.h_fig_image);
            end
            
            file_name = obj.h.file_list.Value{1};
            
            if strcmp(file_name,obj.NULL_FILE)
                return
            end
            
            obj.img_file_path = fullfile(obj.root,file_name);
            
            obj.img_data = imread(obj.img_file_path);
            
            obj.displayImage();
        end
        function displayImage(obj)
            
            obj.h_fig_image = figure(12345);
            
            imshow(obj.img_data);
            
            img_width = size(obj.img_data,2);
            
            obj.h.current_width.Value = img_width;
            
            obj.setSaveButtonVisibility(false);
        end
        function loadDirectory(obj)
            %
            %
            %   Populates:
            %   .file_list with file names
            
            root2 = uigetdir('','Pick blog root');
            if isnumeric(root2)
                return
            end
            obj.root = root2;
            
            obj.h.folder_edit.Value = root2;
            
            d = dir(fullfile(root2,'*.png'));
            file_names = cell(1,length(d)+1);
            file_names{1} = obj.NULL_FILE;
            file_names(2:end) = {d.name};
            obj.file_paths = file_names;
            obj.h.file_list.Items = file_names;
            obj.h.file_list.Value = obj.NULL_FILE;
            obj.setSaveButtonVisibility(false);
        end
    end
end

