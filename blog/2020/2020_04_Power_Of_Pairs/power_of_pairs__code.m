%1)
%----------------------------------------------------------------------
alpha = 0.05;
mean1 = 0;
mean2 = 1;
std_dev = 1;
effect_size = abs(mean1-mean2)./std_dev;
fprintf('Effect Size: %g\n',effect_size);

n_sims = 10000;
n_max = 25; %The maximum group size we'll test
n_min = 5; %The minimum group size tested

%randn is slow to call in a loop, we'll grab a lot of samples
%all at once
r1 = mean1 + std_dev*randn(n_sims*sum(n_min:n_max),1);
r2 = mean2 + std_dev*randn(n_sims*sum(n_min:n_max),1);

I2 = 0;
pct_different = NaN(1,n_max);
for group_size = n_min:n_max
    fprintf('Running group size: %d\n',group_size);
    is_different = false(1,n_sims);
    for i = 1:n_sims
        I1 = I2 + 1;
        I2 = I2 + group_size;
        s1 = r1(I1:I2);
        s2 = r2(I1:I2);
        is_different(i) = ttest2(s1,s2,'alpha',alpha);
    end
    pct_different(group_size) = sum(is_different)/n_sims;
end

figure(1)
clf
plot(pct_different,'o-')
ylabel('Power')
xlabel('Group Size')
xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
line(xlim,[0.8 0.8],'Color','k');
set(gca,'FontSize',18)



%2) Repeat, but now with both paired and unpaired testing
%-------------------------------------------------------------------------
alpha = 0.05;
mean1 = 0;
mean2 = 1;
std_dev = 1;
effect_size = abs(mean1-mean2)./std_dev;
fprintf('Effect Size: %g\n',effect_size);

n_sims = 10000;
n_max = 25; %The maximum group size we'll test
n_min = 5; %The minimum group size tested

%randn is slow to call in a loop, we'll grab a lot of samples
%all at once
r1 = mean1 + std_dev*randn(n_sims*sum(n_min:n_max),1);
r2 = mean2 + std_dev*randn(n_sims*sum(n_min:n_max),1);

I2 = 0;
pct_different = NaN(1,n_max);
pct_different2 = NaN(1,n_max);
pct_greater = NaN(1,n_max);
for group_size = n_min:n_max
    fprintf('Running group size: %d\n',group_size);
    is_different = false(1,n_sims);
    is_different2 = false(1,n_sims);
    is_greater = false(1,n_sims);
    for i = 1:n_sims
        I1 = I2 + 1;
        I2 = I2 + group_size;
        s1 = r1(I1:I2);
        s2 = r2(I1:I2);
        is_different(i) = ttest(s1,s2,'alpha',alpha);
        is_different2(i) = ttest2(s1,s2,'alpha',alpha);
    end
    pct_different(group_size) = sum(is_different)/n_sims;
    pct_different2(group_size) = sum(is_different2)/n_sims;
end

figure(2)
clf
plot(pct_different,'o-')
hold on
plot(pct_different2,'o-')
hold off
ylabel('Power')
xlabel('Group Size')
set(gca,'FontSize',18)
legend({'Paired','Unpaired'})

%3 high correlation example
%--------------------------------------------------------------------------
r1 = mean1 + 10*std_dev*randn(100,1);
r2 = r1 + mean2 + 0.2*randn(100,1);

x = -30:0.1:30;
x2 = x(end:-1:1);
x3 = -2:0.1:2;
x4 = x3(end:-1:1);
y0 = zeros(1,length(x));
y0_2 = zeros(1,length(x3));
figure(3)
clf
subplot(1,3,1)
y1 = normpdf(x,mean(r1),std(r1));
y2 = normpdf(x,mean(r2),std(r2));
p1 = patch([x x2],[y1 y0],'r');
p1.FaceAlpha = 0.5;
hold on
p2 = patch([x x2],[y2 y0],'b');
p2.FaceAlpha = 0.5;
hold off
[~,p1] = ttest2(r1,r2);
title(sprintf('p = %0.3f',p1))


subplot(1,3,2)
plot([r1 r2]','k')
set(gca,'xlim',[0.5 2.5],'xtick',[1 2])
title(sprintf('r = %g',corr(r1,r2)))
subplot(1,3,3)
y3 = normpdf(x3,mean(r2-r1),std(r2-r1));
p1 = patch([x3 x4],[y3 y0_2],'g');
p1.FaceAlpha = 0.5;
[~,p2] = ttest(r1,r2);
title(sprintf('p = %g',p2))

%4 weak correlation example
%--------------------------------------------------------------------------
r1 = mean1 + 10*std_dev*randn(100,1);
r2 = mean2 + 10*std_dev*randn(100,1) + 0.3*r1;

x = -30:0.1:30;
x2 = x(end:-1:1);
x3 = -2:0.1:2;
x4 = x3(end:-1:1);
y0 = zeros(1,length(x));
y0_2 = zeros(1,length(x3));

figure(4)
clf
subplot(1,3,1)
y1 = normpdf(x,mean(r1),std(r1));
y2 = normpdf(x,mean(r2),std(r2));
p1 = patch([x x2],[y1 y0],'r');
p1.FaceAlpha = 0.5;
hold on
p2 = patch([x x2],[y2 y0],'b');
p2.FaceAlpha = 0.5;
hold off
[~,p1] = ttest2(r1,r2);
title(sprintf('p = %0.3f',p1))

subplot(1,3,2)
plot([r1 r2]','k')
set(gca,'xlim',[0.5 2.5],'xtick',[1 2])
title(sprintf('r = %g',corr(r1,r2)))

subplot(1,3,3)
y3 = normpdf(x,mean(r2-r1),std(r2-r1));
p1 = patch([x x2],[y3 y0],'g');
p1.FaceAlpha = 0.5;
[~,p2] = ttest(r1,r2);
title(sprintf('p = %g',p2))

%% 5 Unpaired vs Difference distribution
%---------------------------------------------------
alpha = 0.05;
mean1 = 0;
mean2 = 1;
std_dev = 1;
effect_size = abs(mean1-mean2)./std_dev;
fprintf('Effect Size: %g\n',effect_size);

n_sims = 10000;
n_max = 25; %The maximum group size we'll test
n_min = 5; %The minimum group size tested

%randn is slow to call in a loop, we'll grab a lot of samples
%all at once
r1 = mean1 + std_dev*randn(n_sims*sum(n_min:n_max),1);
r2 = mean2 + std_dev*randn(n_sims*sum(n_min:n_max),1);

I2 = 0;
pct_different = NaN(1,n_max);
pct_different2 = NaN(1,n_max);
pct_greater = NaN(1,n_max);
for group_size = n_min:n_max
    fprintf('Running group size: %d\n',group_size);
    is_different = false(1,n_sims);
    is_different2 = false(1,n_sims);
    is_greater = false(1,n_sims);
    for i = 1:n_sims
        I1 = I2 + 1;
        I2 = I2 + group_size;
        s1 = r1(I1:I2);
        s2 = r2(I1:I2);
        %paired
        %testing vs 0
        is_different(i) = ttest(s2,0,'alpha',alpha);
        %unpaired
        is_different2(i) = ttest2(s1,s2,'alpha',alpha);
    end
    pct_different(group_size) = sum(is_different)/n_sims;
    pct_different2(group_size) = sum(is_different2)/n_sims;
end

figure(5)
clf
plot(pct_different,'o-')
hold on
plot(pct_different2,'o-')
hold off
ylabel('Power')
xlabel('Group Size')
set(gca,'FontSize',18)
legend({'d_z=1','d=1'})


%% 6 Demo of two distributions versus one distribution
%----------------------------------------------------------
n = 14;
mean1 = -0.2;
mean2 = 0.8;
std1 = 1;
std2 = 1;
r1 = mean1 + std1*randn(n,1);
r2 = mean2 + std2*randn(n,1);
x = -3:0.1:3;
x2 = x(end:-1:1);
x3 = -2:0.1:2;
x4 = x3(end:-1:1);
y0 = zeros(1,length(x));
y0_2 = zeros(1,length(x3));

figure(6)
clf
y1 = normpdf(x,mean1,std1);
y2 = normpdf(x,mean2,std2);
p1 = patch([x x2],[y1 y0],'r');
p1.FaceAlpha = 0.5;
hold on
p2 = patch([x x2],[y2 y0],'b');
p2.FaceAlpha = 0.5;
hold off
ylim = get(gca,'ylim');
line([0 0],ylim,'Color','k','Linewidth',2)

p1 = zeros(1,1e4);
p2 = zeros(1,1e4);
for i = 1:1e4
    r1 = mean1 + std1*randn(n,1);
    r2 = mean2 + std2*randn(n,1);
    [~,p1(i)] = ttest2(r1,r2);
    [~,p2(i)] = ttest(r2,0);
end
title(sprintf('p1 = %0.3f, p2 = %0.3f',mean(p1), mean(p2)))
set(gca,'FontSize',16)




%% 7 t-statistics
%----------------------------------------------------------
%paired, single
%t = sqrt(n)*(x-u)/(s) OR effect_size*sqrt(n)

%unpaired
%t = sqrt(n/2)*(x1-x2)/s or effect_size * sqrt(n/2)


%d_z = d/sqrt(2*(1-rho));


%% 8 Correlations
%---------------------------------------------------------
alpha = 0.05;
mean1 = 0;
mean2 = 1;
std_dev = 1;

rho = 0.5; %Corresponds to dz = 1
n_sims = 10000;
n_max = 25; %The maximum group size we'll test
n_min = 5; %The minimum group size tested

%randn is slow to call in a loop, we'll grab a lot of samples
%all at once
r1 = mean1 + std_dev*randn(n_sims*sum(n_min:n_max),1);

r0 = mean2 + std_dev*randn(n_sims*sum(n_min:n_max),1);

r2 = rho*r1 + sqrt(1-rho^2)*r0;
r2 = r2 - mean(r2) + mean2;

I2 = 0;
pct_different = NaN(1,n_max);
pct_different2 = NaN(1,n_max);
pct_different3 = NaN(1,n_max);
pct_greater = NaN(1,n_max);
for group_size = n_min:n_max
    fprintf('Running group size: %d\n',group_size);
    is_different = false(1,n_sims);
    is_different2 = false(1,n_sims);
    is_different3 = false(1,n_sims);
    is_greater = false(1,n_sims);
    for i = 1:n_sims
        I1 = I2 + 1;
        I2 = I2 + group_size;
        s1 = r1(I1:I2);
        s2 = r2(I1:I2);
        %Paired test
        is_different(i)  = ttest(s1,s2,'alpha',alpha);
        
        %Unpaired test
        is_different2(i) = ttest2(s1,s2,'alpha',alpha);
        
        %Difference relative to constant
        %What a paired test eventually becomes
        is_different3(i) = ttest(s2,0,'alpha',alpha);
    end
    pct_different(group_size) = sum(is_different)/n_sims;
    pct_different2(group_size) = sum(is_different2)/n_sims;
    pct_different3(group_size) = sum(is_different3)/n_sims;
end

figure(8)
clf
plot(pct_different,'o-')
hold on
plot(pct_different2,'o-')
plot(pct_different3,'o-')
hold off
ylabel('Power')
xlabel('Group Size')
set(gca,'FontSize',18)
legend({'Paired','Unpaired','dz'})

%% 9 - Verifying translation of correlation to effect size
%--------------------------------------------------------
%tstat1 = 1.4*tstat2 for same effect size
%
%Fix d at 1
%- calculate tstat2
%- calculate tstat1/1.4
%
%What makes these equal?

mean1 = 0;
mean2 = 1;
std_dev = 1;

rhos = [0.01 0.05:0.05:0.95 0.99];
n_sims = 10000;

group_sizes = [10 20 30 60 100 200];


n_groups = length(group_sizes);
legend_strs = cell(1,n_groups);

n_rhos = length(rhos);
dz = NaN(n_groups,n_rhos);
for k = 1:n_groups
    group_size = group_sizes(k);
    legend_strs{k} = sprintf('%d',group_size);
    fprintf('Running group size: %d\n',group_size);
    for j = 1:n_rhos
        rho = rhos(j);
        fprintf('Running rho: %g\n',rho);
        r1 = mean1 + std_dev*randn(n_sims*group_size,1);
        r0 = mean2 + std_dev*randn(n_sims*group_size,1);
        r2 = rho*r1 + sqrt(1-rho^2)*r0;
        r2 = r2 - mean(r2) + mean2;
        I2 = 0;

        temp_dz = zeros(1,n_sims);
        for i = 1:n_sims
            I1 = I2 + 1;
            I2 = I2 + group_size;
            s1 = r1(I1:I2);
            s2 = r2(I1:I2);
            s3 = s2-s1;
            temp_dz(i) = mean(s3)/std(s3);
        end
        dz(k,j) = mean(temp_dz);
    end
end

figure(9)
clf
subplot(1,2,1)
plot(rhos,-0.5./dz.^2+1,'-o')
hold on
plot([0 1],[0 1],'k')
hold off
axis square
ylabel('-0.5./dz.^2 + 1')
xlabel('correlation (rho)')
legend(legend_strs)
title('rho versus d ratio - should be equal')
set(gca,'FontSize',18)


subplot(1,2,2)
plot(rhos,-0.5./dz.^2+1,'-o')
hold on
plot([0 1],[0 1],'k')
hold off
axis square
ylabel('-0.5./dz.^2 + 1')
xlabel('correlation (rho)')
set(gca,'ylim',[0 0.3],'xlim',[0 0.3],'FontSize',18)
title('zoomed in')

% d_z = d/sqrt(2*(1-rho));
% 2-2rho = d^2/d_z^2
% -2rho = 1/dz^2 - 2
% rho = 0.5*d^2/dz^2 + 1


%% 10 - the broken correlation code
%-------------------------------------------
alpha = 0.05;
mean1 = 0;
mean2 = 1;
std_dev = 1;
effect_size = abs(mean1-mean2)./std_dev;
fprintf('Effect Size: %g\n',effect_size);

n_sims = 10000;
n_shuffles = 50000;
n_max = 7; %The maximum group size we'll test
n_min = 4; %The minimum group size tested

%randn is slow to call in a loop, we'll grab a lot of samples
%all at once
%r1 = mean1 + std_dev*randn(n_sims*sum(n_min:n_max),1);
%r2 = mean2 + std_dev*randn(n_sims*sum(n_min:n_max),1);

all_data = cell(1,5);
for k = 1:5
I2 = 0;
pct_different = zeros(100,n_max);
n_each = NaN(100,n_max);
for group_size = n_min:1:n_max
    r1 = mean1 + std_dev*randn(n_sims*group_size,1);
    r2 = mean2 + std_dev*randn(n_sims*group_size,1);
    P = perms(1:group_size);
    P = P';
    n_shuffles = size(P,2);
    %[~,P] = sort(rand(group_size,n_shuffles));
    fprintf('Running group size: %d\n',group_size);
    is_different = false(n_sims,n_shuffles);
    indices = zeros(n_sims,n_shuffles);
    I2 = 0;
    for i = 1:n_sims
        if mod(i,100) == 0
            fprintf('Running sim # %d\n',i)
        end
        I1 = I2 + 1;
        I2 = I2 + group_size;
        s1 = r1(I1:I2);
        s2 = r2(I1:I2);
        
        s3 = r2(P);
        rho = corr(s1,s3);
        %-1 to 1
        % 1 to 100
        I = round(99/2*rho +101/2);
        indices(i,:) = I;
        
        is_different(i,:) = ttest(repmat(s1,[1 n_shuffles]),s3,'alpha',alpha);
    end
    is_diff_linear = is_different(:);
    indices_linear = indices(:);
    for i = 1:100
        if mod(i,10) == 0
            fprintf('Running collect # %d\n',i)
        end
        temp = is_diff_linear(indices_linear == i);
        pct_different(i,group_size) = sum(temp)/length(temp);
        n_each(i,group_size) = length(temp);
    end
end
all_data{k} = pct_different;
end

figure(11)
clf
hold on
for i = 1:5
plot(all_data{i}(:,6))
end
hold off

figure(5)
clf
corr_values = linspace(-1,1,100);
plot(corr_values,pct_different(:,4))


figure(9)
clf
subplot(1,2,1)
corr_values = linspace(-1,1,100);
plot(corr_values,pct_different)
subplot(1,2,2)
[~,I] = min(abs(corr_values-0.7));
plot(pct_different(I,:),'o')

figure(10)
clf
subplot(1,2,1)
corr_values = linspace(-1,1,100);
plot(corr_values,pct_different)
subplot(1,2,2)
[~,I] = min(abs(corr_values-0.7));
plot(pct_different(I,:),'o')

r = [-0.99 -0.90 -0.80 -0.70 -0.60 -0.50 -0.40 -0.30 -0.20 -0.10 0      0.1  0.2  0.3   0.4  0.5 0.6   0.7  0.8]
es = [0.501 0.513 0.527 0.54 0.559 0.577 0.598 0.620 0.645 0.674 0.707  0.74 0.79 0.845 0.91 1   1.12  1.29 ]






