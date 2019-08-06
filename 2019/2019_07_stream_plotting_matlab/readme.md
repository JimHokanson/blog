This post is currently being written.

# Plotting of Streaming Data in Matlab #

I'm closing out a project where I wanted to be able to plot data from a NI-DAQ as it was acquired. Additionally the data had to be saved to disk, along with some experiment control requirements, but those are stories for another time. For our animal work this is done with a program called [Labchart by ADInstruments](https://www.adinstruments.com/products/labchart). This latest project involved human subjects and thus my code needed to run off a USB-powered NI-DAQ, not off ADInstrument's wall powered device. National Instruments Labview programming language is designed for just this task but I've previously run into issues in managing large Labview projects. In retrospect I'm not sure that avoiding Labview was the best decision, but I managed to make something that works.

For plotting streaming data Matlab provides a function `animatedline` however it requires knowing how much data you are going to collect ahead of time. It can also be quite slow.

In the following post I describe the basics of using the streaming code, expand upon its benefits, and explain how it works behind the scenes. The code is a subset of my [plotBig library](https://github.com/JimHokanson/plotBig_Matlab). A previous article on the benefits of using the library without streaming is [available here.](../../2018/2018_01_PlotBig_Matlab)

# Basic Usage #

Below is a basic example of using the streaming functionality of the plotBig library. It consists of two steps. First, the streaming data object is created. Second, data is added to the object (as it is acquired).

```matlab
fs = 20000; %sampling rate
n_samples_init = fs*200; %how many samples to initially allocate 

%1) Initialization of the object
xy = big_plot.streaming_data(1/fs,n_samples_init);

%Needed so that the plot renders. Otherwise we are in "setup" mode.
plotBig(xy)

%2) Adding data
new_data = [1:fs 1:fs];
xy.addData(new_data);
set(gca,'xlim',[0 2])
```

This is similar to the usage of Matlab's animatedline() function.

```matlab
fs = 20000; %sampling rate
n_samples_init = fs*200; %how many samples to initially allocate 
%1) Initialization of the object
xy = animatedline('MaximumNumPoints',n_samples_init);

%2) Adding data
new_data = [1:fs 1:fs];
x = linspace(0,2,2*fs);
addpoints(xy,x,new_data)
set(gca,'xlim',[0 2])
```

Other than different names the usage is fairly similar. Some important usage differences are:

1. This implementation doesn't automatically render added data points until the object is plotted using plotBig(). See the above example.
2. This implementation doesn't automatically change the x axis limits as data points are added. The user most set it manually.

Note, this example is not typical, as generally data gets added as it is "acquired."

Here's a full example ...

```matlab
fs = 20000; %sampling rate
n_samples_init = fs*200; %how many samples to initially allocate 

%1) Initialization of the object
xy = big_plot.streaming_data(1/fs,n_samples_init);
%Needed so that the plot renders. Otherwise we are in "setup" mode.
plotBig(xy)
set(gca,'ylim',[0 1])

%2) "Adding" data
for i = 1:200
    new_data = linspace(0,1/i,fs);
	xy.addData(new_data);
	set(gca,'xlim',[i-20 i]);
	drawnow()
end
```

Note that we set the y axis limits because otherwise our scrolling (20 seconds used here) will trigger y-axis resizing.

# Benefits #

There are two main benefits to using this code instead of animatedline.

1. Expansion of underlying data arrays if more space is needed.
2. Faster plotting than animatedline.

## Data Expansion ##

Here's an example where we need to add data because the initial data allocation was insufficient.

```matlab
fs = 20000; %sampling rate
n_samples_init = fs*5; %Run for 200 seconds, but only initialize 5

xy = big_plot.streaming_data(1/fs,n_samples_init);
plotBig(xy)
set(gca,'ylim',[0 1])

%2) Adding data
for i = 1:200
    new_data = linspace(0,1/i,fs);
	xy.addData(new_data);
	set(gca,'xlim',[i-20 i]);
	drawnow()
end
```

Internally array overflows are detected and the arrays are resized.

This is the same code with animatedline. After 5 seconds of data only the last 5 seconds of data is kept for plotting.

```matlab
fs = 20000; %sampling rate
n_samples_init = fs*5; %Run for 200 seconds, but only initialize 5

xy = animatedline('MaximumNumPoints',n_samples_init);
%Note the default (below) keeps only 1 million data points then throws a warning
%xy = animatedline();
set(gca,'ylim',[0 1])

%2) Adding data
for i = 1:200
    new_data = linspace(0,1/i,fs);
    x = linspace(i,i+1,fs);
    addpoints(xy,x,new_data)
	set(gca,'xlim',[i-20 i]);
	drawnow()
end
```

## Speed ##

The main reason for implementing this code was to increase speed of plotting. animatedline handles adding data points to memory efficiently, but it is not clear that it actually has anyway of speeding up normal plotting. For example if we simply use animatedline to plot the following figure, it is the slowest out of four plot options tested.

![data for plotting](speed_example_01.svg)

In the above figure I'm plotting a sine wave sampled at 20 kHz for 20 minutes of data, a duration and sampling rate that might be reasonable for my work. 

Elapsed times are as follows:

- Matlab's plot(): 2.3 s
- Matlab's animatedline(): 14 s
- plotBig with streaming: 0.45 s
- plotBig without streaming: 0.45 s

Code available at: [speed_example_01.m]

Note, all results are from my macbook running Matlab 2019a.

Interestingly, if I specify the axis limits ahead of plotting, then the plotBig times drop to ~0.20 s (see limitations for more on this).

The main point of the above example is that animatedline isn't designed to be super fast at plotting, but rather to handle streaming data more efficiently than replotting every time new data are added.

In the next example we add on data in 1 second increments, keeping visible one minute's worth of data. This more closely replicates the streaming use case for the streaming class and animatedline. After the 1 second of data has been added and the x-limits have been adjusted a render is forced (via drawnow()) to ensure that all frames are drawn (rather than only a subset of frames getting rendered due to the code being slow). I've reduced the total amount of data being plotted from 20 minutes to 2 minutes because plotting was getting to be too slow.

This is an example with animatedline():

![streaming gif using animated line plotting](animated_line.gif)


This is an example with the plotBig library:

![streaming gif using big_plot.streaming_data](big_plot_streaming.gif)

In addition to comparing Matlab's standard approach to my code, I also tried three other options. First, I tried plotting a line  with only 2 points for each window, rather than the 1.2 million I'm plotting in the above examples. This option provides an indication of how long it takes simply to plot anything. Second, I tried initializing a vector with NaNs, then replacing NaNs with relevant data as it is "collected." Finally, I tried only copying over the data that was within range. These latter options are naive ways of implementing streaming. Relevant code for these latter two is shown below.

```matlab
    %NaN option
    %---------------------------------
    start_I = end_I + 1;
    end_I = start_I + fs - 1;
    
    %x2 and y2 don't change size, preallocated to NaN
    y2(start_I:end_I) = y(start_I:end_I);
    x2(start_I:end_I) = linspace(i-1,i,fs);
    h2.XData = x2;
    h2.YData = y2;
    
    %Subset option
    %---------------------------------------
    t1 = i-n_secs_plot;
    t2 = i;  
    I1 = find(t >= t1,1);
    I2 = find(t <= t2,1,'last');
    
    %the data to the plot function may change size
    %but it only contains relevant data, unlike the
    %NaN option above
    h2.XData = t(I1:I2);
    h2.YData = y(I1:I2);
```

The following are the average execution times (5 runs) for each option:

- animatedline(): 11.9s
- plotBig streaming: 5.871s
- 2-point plots: 5.847s
- NaN plot: 27.4s
- Subset plot: 19.1

There are at least two takeaways from this result. First, plotBig doesn't take much longer to run than simply plotting 2 points for each view. Second, animatedline is pretty competitive, beating my one-off attempts at doing something simple.

Code for the above is available at: [speed_example_02.m]

The time difference between animatedline and plotBig depends on how points are being plotted. Plotting more data will make the difference in execution times larger. Interestingly, execution time for animatedline grows at a non-linear rate as more data are added to the object, even if the same amount of data is plotted in any given plot render. This is shown below. This is not true for plotBig, where execution time (as we saw in the previous example), is largely driven by time to render a plot.

![execution time as a function of # of data points added](speed_example_03.svg)

My guess is that the non-linear increase in time with animatedline comes from it supporting a non-monotonic, non-evenly spaced time vector. More specifically, plotBig is able to determine relevant samples to be plotted from a simple calculation (based on start time and sampling rate), whereas I am assuming that animatedline needs to do a search over all the data points in its memory to determine which ones are valid for plotting. This makes animatedline more versatile than plotBig, at the cost of being slower. The above example also illustrates that the relative speedup between plotBig and animatedline depends on a variety of factors, including # of data points in memory (shown here), as well as # of data points plotted. This latter point is not tested in this post but comes from: 1) the point above that animatedline isn't designed to be fast at plotting, rather to not be super slow with streaming, and 2) details on how fast plotBig is at plotting relative to Matlab ([see previous blog post for more details]((../../2018/2018_01_PlotBig_Matlab)).

One other point from the above example, one solution to counteract this slow down with animatedline is to set a maximum on the # of data points that it stores, where the # of data points is sufficient to cover the window being plotted, but less than storing every point. This would almost certainly reduce the impact of having too many points in memory, but would cause problems if the window width were ever increased. In my use case I wanted the ability to plot a specified width (time duration) by default, as well as the ability to increase or decrease that width, and to scroll backwards to see previous data. Increasing the width and scrolling backwards would not be supported by animatedline if only a limited # of data points were stored.

Code for the above is available at: [speed_example_03.m]

**Speed Summary:** Matlab's animatedline function is designed to efficiently plot data as new points are added. From what I can tell it is not designed to plot data fast. The streaming functionality of plotBig in contrast is designed to plot data fast AND to support plotting new data as it is added. The relative speedup between the two is dependent on how many points have been added to the plot objects, as well as how many points are plotted.

# Implementation Details #

# Limitations & Future Extensions #

At this point no further development is planned. 

1. Memory limits
2. Evenly spaced numbers
3. Support of min/max on subset of data.
4. How to speed up plot rendering for a standard line
