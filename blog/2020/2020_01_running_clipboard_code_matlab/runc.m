function runc(varargin)
%x Run a commented example that is in the clipboard
%
%   runc()
%
%   I wrote this function to facilitate running multi-line examples from
%   files. I would normally need to uncomment the lines, evaluating the
%   selection (being careful not to save the file), and then undo the
%   changes so that the file wasn't changed.
%
%   Flags
%   -----
%   last - use last command
%   disp - display the command in the command window
%   raw  - don't uncomment (NOTE: This is largely obsolete with smart
%           processing of the copied string
%
%   To Run:
%   -------
%   1) Find some example text to run
%   2) Run this command
%
%   Example:
%   --------
%   1)
%   %Copy the lines below into the clipboard:
%
%   disp('Select this line')
%   disp('And select this one!')
%
%   %Then type "runc()" into the command window
%
%   2) Error in code
%   %Copy below into clipboard then enter 'runc' in command window
%   a = 1:5
%   b = 2*a
%   c = a(6)
%
%
%   Improvments:
%   ------------
%   1) runc last - ???? I'm not sure what I had in mind
%       since normally we change things ... - I think this in cases
%       where we are editing deeper code, not the top level code
%       and we might have copy pasted things
%      - we would need to register/save the last command - techincally
%       it is already saved in the file
%
%
%   See Also
%   --------
%   z_runc_exec_file


%{
%This is test code for runc('raw')
x = 1;
b = 2;
%This should throw an error
c = x(b);
%}

%%Testing file writing
%   %first run (copy line below then run this function)
%   a = 1
%   %2nd run   (copy lines below then run this function)
%   b = 1:5
%   b(10)  %Should cause an error in the file

persistent last_input_string

in.use_last = false; %flag - last
in.show_code = false; %flag - disp
in.is_raw = false;
%TODO: Write a formal function that handles this ...
if any(strcmp(varargin,'last'))
    in.use_last = true;
end
if any(strcmp(varargin,'disp'))
    in.use_last = true;
end
if any(strcmp(varargin,'raw'))
    in.is_raw = true;
end


%TODO: I don't think this is needed anymore
%This is also unfortunately in sl.initialize due to Matlab not allowing
%dynamically created functions
TEST_FILE_NAME = 'z_runc_exec_file.m';

script_name = TEST_FILE_NAME(1:end-2);

if in.use_last
    if isempty(last_input_string)
        fprintf(2,'Last execution string was cleared or never initialized\n');
    end
    str = last_input_string;
else
    str = clipboard('paste');
end

if in.is_raw
    uncommented_str = str;
else
    %     n_newlines = length(strfind(str,sprintf('\n'))); %#ok<SPRINTFN>
    %     lines_with_comments = length(regexp(str,'^\s*%','lineanchors'));
    n_lines_without_comments = length(regexp(str,'^\s*[^%\s]+','lineanchors'));
    
    %Tests - copy below and type runc
    %-----------------
    
    %   Test 1 => n_lines_without_comments = 0
    %   this line has a comment
    
    % Test 2 - include next (empty) line => n_lines_without_comments = 0
    
    %{
        Test 3 - This will fail, we don't support block comments
        => n_lines_without_comments = 2
    %}
    
    if n_lines_without_comments == 0
        %   %%uncommented_str = regexprep(str,'^\s*%\s*','','lineanchors');%
        %Above fails when we strip multiple lines
        %   e.g.:
        %
        %     %  %Good Comment
        %     %
        %     %  n = 1
        %     %  x = 2
        %
        %   The n = 1 doesn't get uncommented because we consume the leading
        %   whitespace since the previous line doesn't have any text
        
        %Better approach:
        %https://stackoverflow.com/questions/3469080/match-whitespace-but-not-newlines
        uncommented_str = regexprep(str,'^\s*%[^\S\n]*','','lineanchors');
    else
        uncommented_str = str;
    end
end


if in.show_code
    disp(uncommented_str)
end


%sl.stack.getMyBasePath()
stack = dbstack('-completenames');
%NOTE:
%   - 1 refers to this function
%   - 2 refers to the calling function
if length(stack) == 1
    function_dir = cd;
else
    function_dir = fileparts(stack(2 + 0).file);
end
file_path = fullfile(function_dir,TEST_FILE_NAME);

if exist(file_path,'file')
    clear(script_name)
end

try
    %sl.io.fileWrite(file_path,uncommented_str);
    h__fileWrite(file_path,uncommented_str);
    %pause(1); %Adding to test race condition
    %Doesn't seem to be a race condition
    run_file = exist(script_name,'file');
catch ME
    run_file = false;
end


%NOTE: If this fails here see the file:
%
%   z_runc_exec_file.m
%
%   Or click on the link in the command window
if run_file
    evalin('caller',script_name);
else
    evalin('caller',uncommented_str);
end

%JAH Note:
%- compile errors get thrown here :/
%- runtime errors get thrown from file as desired

end

function h__fileWrite(file_path,data)

in.mode = 'w';
in.endian = 'n';
in.encoding = '';

mode = in.mode;
in = rmfield(in,'mode');

fid = h__fopenWithErrorHandling(file_path,mode,in);

try
    % read file
    fwrite(fid,data);
catch exception
    % close file
    fclose(fid);
    throw(exception);
end

% close file
fclose(fid);

end

function fid = h__fopenWithErrorHandling(file_path,mode,varargin)
%x Call fopen but with better error handling support
%
%   fid = sl.io.fopenWithErrorHandling(file_path,mode,varargin)
%
%   This function is basically just fopen() but it also
%   provides more information in case the function does not
%   work.
%
%   Possible Errors:
%   ----------------
%   1) Missing file
%   2) Permissions error - e.g. file open by another program
%
%   Examples:
%   ---------
%   1) Open a file for reading
%
%   fid = sl.io.fopenWithErrorHandling(file_path,'r')
%
%   See Also:
%   ---------
%   sl.io.fileRead

in.endian = 'n';
in.encoding = '';
[fid, msg] = fopen(file_path,mode,in.endian,in.encoding);

if fid == (-1)
    %NOTE: I've run into problems with unicode ...
    %http://www.mathworks.com/matlabcentral/answers/86186-working-with-unicode-paths
    if ~exist(file_path,'file')
        error('Missing file : %s',file_path);
        %error_msg = sl.error.getMissingFileErrorMsg(file_path);
        %error(error_msg)
    else
        %Can we get any more detailed as to why????
        %   perhaps via some fopen('all')
        %
        %TODO: This is also called from fileWrite
        error('sl:io:fileRead:cannotOpenFile','Unable to open the specified file:\n%s\nreason: %s',file_path, msg);
    end
end
end