%1   Basic example
%-------------------------------------------------
close all
%Setup ------------
n_secs = 200;
n_secs_plot = 50;
fs = 100000; %sampling rate
n_samples_init = fs*n_secs; %how many samples to initially allocate 
%- adjust based on how long you think you need
%- If you underestimate, the internal buffer expands
%- more options available at big_plot.streaming_data
xy = big_plot.streaming_data(1/fs,n_samples_init);
plotBig(xy)

set(gca,'ylim',[0 1])

%Plotting newly acquired data ----------
%set(gca,'xlim',[0 n_secs])
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,1/i,fs);
    new_data(1:2:end) = 0;
    xy.addData(new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
end
toc


%	Vs Animated Line
%------------------------------------------------
%MaximumNumPoints
fprintf(2,'Ex 2: running straight increase\n')
close all
xy = animatedline('MaximumNumPoints',n_samples_init);

set(gca,'ylim',[0 1])

%Plotting new data ....
%set(gca,'xlim',[0 n_secs])
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,1/i,fs);
    new_data(1:2:end) = 0;
    x = linspace(i,i+1,fs);
    %xy.addData(new_data)
    addpoints(xy,x,new_data)
    %set(gca,'xlim',[i-n_secs_plot i])
    %drawnow
end
toc

%baseline timing
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,1/i,fs);
end
toc









%-------------------------------------------------
%2   Does animated line depend on data????
%-------------------------------------------------
%- straight increase 
n_secs = 200;
n_secs_plot = 50;
fs = 100000; %sampling rate
n_samples_init = fs*n_secs; %how many samples to initially allocate 
fprintf(2,'Ex 2: running straight increase\n')
close all
xy = animatedline('MaximumNumPoints',n_samples_init);

set(gca,'ylim',[0 1])

%Plotting new data ....
%set(gca,'xlim',[0 n_secs])
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,1/i,fs);
    x = linspace(i,i+1,fs);
    %xy.addData(new_data)
    addpoints(xy,x,new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
end
toc

fprintf(2,'Ex 2: running oscillating straight\n')
close all
xy = animatedline('MaximumNumPoints',n_samples_init);

set(gca,'ylim',[0 1])

%Plotting new data ....
%set(gca,'xlim',[0 n_secs])
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,1/i,fs);
    new_data(1:2:end) = 0;
    x = linspace(i,i+1,fs);
    addpoints(xy,x,new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
end
toc

fprintf(2,'Ex 2: running straight decrease\n')
close all
xy = animatedline('MaximumNumPoints',n_samples_init);

set(gca,'ylim',[-1 0])

%This is much much slower, why?
%set(gca,'ylim',[0 1]) %s=> no data are visible

%Plotting new data ....
%set(gca,'xlim',[0 n_secs])
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,-1/i,fs);
    new_data(1:2:end) = 0;
    x = linspace(i,i+1,fs);
    addpoints(xy,x,new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
end
toc

fprintf(2,'Ex 2: running with more zero times\n')
close all
xy = animatedline('MaximumNumPoints',n_samples_init);

set(gca,'ylim',[0 1])

%This is much much slower, why?
%set(gca,'ylim',[0 1]) %s=> no data are visible

%Plotting new data ....
%set(gca,'xlim',[0 n_secs])
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,1/i,fs);
    new_data(1:4:end) = 0;
    new_data(2:4:end) = 0;
    new_data(3:4:end) = 0;
    x = linspace(i,i+1,fs);
    addpoints(xy,x,new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
end
toc


%plotBig code doesn't appear to depend on data type ...

%10.5 - 11.5 seconds prior to callback changes ...
fprintf(2,'Ex 2: running with increase, plotBig\n')
close all
xy = big_plot.streaming_data(1/fs,n_samples_init);
plotBig(xy)

set(gca,'ylim',[0 1])

%Plotting newly acquired data ----------
%set(gca,'xlim',[0 n_secs])
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,1/i,fs);
    xy.addData(new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
end
toc

fprintf(2,'Ex 2: running with zeros, plotBig\n')
close all
xy = big_plot.streaming_data(1/fs,n_samples_init);
plotBig(xy)

set(gca,'ylim',[0 1])

%Plotting newly acquired data ----------
%set(gca,'xlim',[0 n_secs])
tic
for i = 1:n_secs
    %Adding 1 second of data
    new_data = linspace(0,1/i,fs);
    new_data(1:2:end) = 0;
    xy.addData(new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
end
toc

%% 3 Plotting lots of new data
%---------------------------
