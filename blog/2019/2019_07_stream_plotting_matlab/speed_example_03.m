%%s

n_reps = 5;
sec_options = [100 300 1000 3000];

all_times = zeros(2,n_reps,length(sec_options));

for k = 1:n_reps
    fprintf(2,'rep %d\n',k);

for j = 1:length(sec_options)
    
fprintf(2,'sec options %d\n',j);

n_secs = sec_options(j);
n_secs_plot = 60;
fs = 20000;
t = (0:1/fs:n_secs)';
r = 0.1*rand(size(t));
y = r+sin(2*pi*0.01.*t);




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
end
all_times(1,k,j) = toc(h);
fprintf('Elapsed time is %0.1f\n',all_times(1,k,j));

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
end
all_times(2,k,j) = toc(h);
fprintf('Elapsed time is %0.1f\n',all_times(2,k,j));

end

end

m1 = mean(squeeze(all_times(1,:,:)),1);
m2 = mean(squeeze(all_times(2,:,:)),1);
clf
plot(sec_options,m1,'-o')
hold on
plot(sec_options,m2,'-o')
legend({'animatedline','plotBig'})
xlabel('# secs to plot')
ylabel('Elapsed time (s)')
set(gca,'FontSize',16,'FontName','Arial')

%sl.plot.uimenu.addExportSVGOption
