function internals_demo

MAKE_GIFS = false;

t_all = zeros(1,5);

for j = 1:5

fs = 1e5; %sampling rate
n_samples_init = 1e6; %how many samples to initially allocate 
data_type = 'int16';

%1) Initialization of the object
xy = big_plot.streaming_data(1/fs,n_samples_init,'data_type',data_type);
m = 10/double(intmax('int16')); %10 V == intmax
b = 0;
xy.setCalibration(m,b);



close all
plotBig(xy)
set(gca,'ylim',[-3 3])

elapsed_times = zeros(1,100);

h = tic;
%2) "Adding" data
for i = 1:100
    t1 = toc(h);
    if i == 50
        %a "recalibration example
        m = -2*m;
        xy.setCalibration(m,b);
    end
    
    x = (i-1):1/fs:(i-1/fs);
    r = 0.1*rand(1,length(x));
    if mod(i,3) == 0
        %I add an artifact that should always be plotted
        r(1) = 0.5;
    end
    new_data = int16(3277*(sin(x)+r));
	xy.addData(new_data);
	set(gca,'xlim',[i-20 i]);
	drawnow()
    t2 = toc(h);
    elapsed_times(i) = t2-t1;
    if MAKE_GIFS
        if i == 1
            gif('internals_demo.gif','frame',gcf)
        else
            gif('DelayTime',t2-t1);
        end
    end
end
t = toc(h);
t_all(j) = t;
fprintf('Elapsed time %0.1f\n',t);
end
