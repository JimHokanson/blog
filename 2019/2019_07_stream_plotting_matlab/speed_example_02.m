%%s

n_reps = 5;
MAKE_GIFS = false;
n_secs = 60*2; %Shortened to 2 minutes
n_secs_plot = 60;
fs = 20000;
t = (0:1/fs:n_secs)';
r = 0.1*rand(size(t));
y = r+sin(2*pi*0.01.*t);

all_times = zeros(5,n_reps);

for k = 1:n_reps

%animated line - 264s
%-----------------------------------------------
fprintf('animatedline()\n');
close all
xy = animatedline('MaximumNumPoints',length(y));

set(gca,'ylim',[-2 2])
title('animatedline()')

elapsed_times0 = zeros(1,n_secs);
elapsed_times = zeros(1,n_secs);
%Plotting new data ....
%set(gca,'xlim',[0 n_secs])
h = tic;
end_I = 0;
for i = 1:n_secs
    elapsed_times0(i) = toc(h);
    start_I = end_I + 1;
    end_I = start_I + fs - 1;
    %Adding 1 second of data
    new_data = y(start_I:end_I);
    x = linspace(i-1,i,fs);
    %xy.addData(new_data)
    addpoints(xy,x,new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
    elapsed_times(i) = toc(h);
    if MAKE_GIFS
        if i == 1
            gif('animated_line.gif','frame',gcf)
        else
            gif('DelayTime',elapsed_times(i)-elapsed_times0(i));
        end
    end
end
all_times(1,k) = toc(h);
fprintf('Elapsed time is %0.1f\n',all_times(1,k));

%plotBig - 57s 
%---------------------------------------------
fprintf('plotBig - streaming\n');
close all
xy = big_plot.streaming_data(1/fs,length(y));
plotBig(xy)

set(gca,'ylim',[-2 2])
title('big_plot.streaming')

elapsed_times2 = zeros(1,n_secs);
h = tic;
end_I = 0;
for i = 1:n_secs
    elapsed_times0(i) = toc(h);
    start_I = end_I + 1;
    end_I = start_I + fs - 1;
    new_data = y(start_I:end_I);

    %Adding 1 second of data
    xy.addData(new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
    elapsed_times2(i) = toc(h);
    if MAKE_GIFS
        if i == 1
            gif('big_plot_streaming.gif','frame',gcf)
        else
            gif('DelayTime',elapsed_times2(i)-elapsed_times0(i));
        end
    end
end
all_times(2,k) = toc(h);
fprintf('Elapsed time is %0.1f\n',all_times(2,k));

%Basic 2 point line plot
%55s
%---------------------------------------------
fprintf('plotting only 2 points\n');
close all
h2 = plot(1:2);
set(gca,'ylim',[-2 2])

elapsed_times3 = zeros(1,n_secs);
h = tic;
end_I = 0;
for i = 1:n_secs
    start_I = end_I + 1;
    end_I = start_I + fs - 1;
    h2.XData = [i-n_secs_plot i];
    h2.YData = y(i:i+1);
    %new_data = y(start_I:end_I);

    %Adding 1 second of data
    %xy.addData(new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
    elapsed_times3(i) = toc(h);
end
all_times(3,k) = toc(h);
fprintf('Elapsed time is %0.1f\n',all_times(3,k));

%NaN - adding on data ... - very slow
%18s for running 1/100 of the time
%---------------------------------------------------
fprintf('lots of NaNs - adding new data\n');
close all
h2 = plot(1:2);
set(gca,'ylim',[-2 2])

y2 = NaN(size(y));
x2 = NaN(size(y));

elapsed_times4 = zeros(1,n_secs);
h = tic;
end_I = 0;
XX=5;
for i = 1:n_secs/XX
    start_I = end_I + 1;
    end_I = start_I + fs - 1;
    y2(start_I:end_I) = y(start_I:end_I);
    x2(start_I:end_I) = linspace(i-1,i,fs);
    h2.XData = x2;
    h2.YData = y2;
    %new_data = y(start_I:end_I);

    %Adding 1 second of data
    %xy.addData(new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
    elapsed_times4(i) = toc(h);
end
all_times(4,k) = XX*toc(h);
fprintf('Elapsed time is %0.1f\n',all_times(4,k));

%289 seconds - plot only relevant data
%-------------------------------------------
fprintf('plotting only data within range\n');
close all
h2 = plot(1:2);
set(gca,'ylim',[-2 2])

elapsed_times5 = zeros(1,n_secs);
h = tic;
end_I = 0;
for i = 1:n_secs
    
    t1 = i-n_secs_plot;
    t2 = i;  
    I1 = find(t >= t1,1);
    I2 = find(t <= t2,1,'last');
    h2.XData = t(I1:I2);
    h2.YData = y(I1:I2);
    %new_data = y(start_I:end_I);

    %Adding 1 second of data
    %xy.addData(new_data)
    set(gca,'xlim',[i-n_secs_plot i])
    drawnow
    elapsed_times5(i) = toc(h);
end
all_times(5,k) = toc(h);
fprintf('Elapsed time is %0.1f\n',all_times(5,k));

end

