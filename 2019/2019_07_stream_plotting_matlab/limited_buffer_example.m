MAKE_GIFS = true;
fs = 20000; %sampling rate
n_samples_init = fs*5; %Run for 200 seconds, but only initialize 5

n_seconds_run = 50;
close all
xy = big_plot.streaming_data(1/fs,n_samples_init);
plotBig(xy)
set(gca,'ylim',[0 1])
title('plotBig streaming')


%2) Adding data
for i = 1:n_seconds_run
    h = tic;
    new_data = linspace(0,1/i,fs);
	xy.addData(new_data);
	set(gca,'xlim',[i-20 i]);
	drawnow()
    t = toc(h);
    if MAKE_GIFS
        if i == 1
            gif('big_plot_streaming_limited.gif','frame',gcf)
        else
            gif('DelayTime',0.05);
        end
    end
end


fs = 20000; %sampling rate
n_samples_init = fs*5; %Run for 200 seconds, but only initialize 5

close all
xy = animatedline('MaximumNumPoints',n_samples_init);
%Note the default (below) keeps only 1 million data points then throws a warning
%xy = animatedline();
set(gca,'ylim',[0 1])
title('animatedline')

%2) Adding data
for i = 1:n_seconds_run
    new_data = linspace(0,1/i,fs);
    x = linspace(i,i+1,fs);
    addpoints(xy,x,new_data)
	set(gca,'xlim',[i-20 i]);
	drawnow()
    if MAKE_GIFS
        if i == 1
            gif('animated_line_limited.gif','frame',gcf)
        else
            gif('DelayTime',0.05);
        end
    end
end