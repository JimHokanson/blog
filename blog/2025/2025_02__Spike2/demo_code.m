% This function opens a file and reads the data from a waveform channel as 32-bit floats. Then applies a MATLAB filter to the data and saves it to a new file. It does not alter the orignal data.
% clear workspace
clear;
% add path to CED code
if isempty(getenv('CEDS64ML'))
    setenv('CEDS64ML', 'E:\repos\matlab_git\matlab_spike2\ced_provided_code\CEDS64ML');
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);
% load ceds64int.dll
CEDS64LoadLib( cedpath );
% Open a file
fhand1 = CEDS64Open('Demo.smr');
if (fhand1 <= 0); unloadlibrary ceds64int; return; end

[ iOk, TimeDate ] = CEDS64TimeDate( fhand1 );

% get waveform data from channel 1
[ fRead, fVals, fTime ] = CEDS64ReadWaveF( fhand1, 1, 100000, 0 );

CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;


f = ced.file('Demo.smr');
w = f.waveforms(1);
data = w.getData();

plot(fVals)
hold on
plot(data.data)
hold off

markers = f.markers.getData();