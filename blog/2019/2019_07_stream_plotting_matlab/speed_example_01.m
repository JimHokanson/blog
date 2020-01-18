N_LOOPS = 2;
SET_GCA = false;

%sl.plot.uimenu.addExportSVGOption


fs = 20000;
t = (0:1/fs:60*20)';
r = 0.1*rand(size(t));
y = r+sin(2*pi*0.01.*t);


fprintf('------- new run with set_gca: %d\n',SET_GCA);
for i = 1:N_LOOPS
close all
if SET_GCA
set(gca,'xlim',[0 1400],'ylim',[-1 1.5]);
end
fprintf('Regular plotting\n')
tic; plot(t,y); drawnow; toc;
xlabel('time (s)')
set(gca,'FontSize',16,'FontName','Arial')
sl.plot.uimenu.addExportSVGOption

fprintf('plotBig with streaming\n')
close all
if SET_GCA
set(gca,'xlim',[0 1400],'ylim',[-1 1.5]);
end

h = tic;
xy = big_plot.streaming_data(1/fs,length(y),'initial_data',y);
t1 = toc(h);
h2 = plotBig(xy,'obj',true);
t2 = toc(h);
drawnow;
t3 = toc(h);
fprintf('Elapsed time is %g seconds\n',t3);
fprintf('t1: %g, t2: %g, t3: %g, all: %g\n',t1,t2-t1,t3-t2,t3)

fprintf('plotBig without streaming\n')
close all
if SET_GCA
set(gca,'xlim',[0 1400],'ylim',[-1 1.5]);
end
tic;
plotBig(y,'dt',1/fs);
drawnow;
toc;

fprintf('animated line\n')
close all
if SET_GCA
set(gca,'xlim',[0 1400],'ylim',[-1 1.5]);
end
h = tic;
xy = animatedline('MaximumNumPoints',length(y));
new_data = y;
x = t;
addpoints(xy,x,new_data)
drawnow;
toc
end

