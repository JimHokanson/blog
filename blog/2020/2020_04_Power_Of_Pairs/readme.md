# The (Statistical) Power of Pairs #

WORK IN PROGRESS

In this post I describe how I stumbled upon a "hidden" parameter involved in doing a power analysis with paired data.

## Problem Setup ##

So the most useful thing out of this entire post might be the following; for straightforward power analyses, I use a program called [G*Power](http://www.psychologie.hhu.de/arbeitsgruppen/allgemeine-psychologie-und-arbeitspsychologie/gpower.html).

Let's use G\*Power to compute the # of samples we need with an effect size of 1 and standard error parameters ($\alpha=0.05$ and $ \text{power}=(1-\beta)=0.8$). Note, I like using the effect size when doing power analyses, since I think it is a nice straightforward way of specifying how strong an effect I expect to see. This is where some people get all worked up about power analyses, "power analyses are a bunch of baloney since you're making things up." It is true that when you don't have much data on which to base your power analysis, there is a bit more freedom to choose your parameters. However, I think that the real point of power analysis is to tell you what sample sizes are reasonable for your study. If you fudge the numbers at the beginning, you're really lying to yourself about how big a task you're taking on. Anyway, onto the results.

If we start with an unpaired analysis, this is what we get:

<figure>
<img src="unpaired.png">
<figcaption>Results of power analysis for unpaired t-test - G*Power. 
</figcaption>
</figure>

If we split our samples evenly, G*Power tells us that we need 34 samples, 17 from each group, to get our desired parameters. In some cases 34 may not be a lot, but for me 34 is often a lot. We can reduce this number if we design our experiments such that we have paired samples. For example with my work this means getting both measurements from the same animal. For example, we might ask how giving a drug compares to not giving a drug, where we first collect data without the drug in an animal, and then we give the drug to the animal to see what happens. This is then repeated for multiple animals. Each animal has its own variability, its own starting point, but by looking at the changes within an animal, we remove some of this variability. The alternative is to not give the drug to one group of animals and to give the drug to another group of animals. This latter "unpaired" approach tends to require more samples/subjects/animals because we don't get to remove variability in the same way that we do when we calculate changes within sample (as will be shown in a figure below).

Anyway, if we switch to a paired analysis, then we get:

<figure>
<img src="paired.png">
<figcaption>Results of power analysis for paired t-test. 
</figcaption>
</figure>

Switching to a paired test gets us a large reduction in the sample size, from 34 to 10 samples! If you don't think about it for too long, it seems almost magical. But in retrospect it is a bit surprising that the parameters are "exactly the same" and there is such a large reduction in the sample number. But if you think about it a bit longer, or if you try to simulate this, then you might begin to wonder where exactly that reduction comes from. This wasn't obvious to me and I explore this question below.


## Simulations - Part 1 - Unpaired Testing ##

A project I was working on required something a bit more complicated than what G\*Power provided, so I decided to run numerical simulations to calculate the required sample size. Numerical simulations are useful when it is difficult to work out the analytical solutions. I personally like simulations because they tend to be more intuitively obvious to me.

Before getting started on the complicated analysis, I wanted to practice by making sure I could replicate some simple examples. In this case, I was going to replicate the G\*Power results from above.

If you're comfortable running simulations for power analyses, feel free to skip down to the next section.

In this example we'll use an effect size $d$ of 1. There are lots of different effect sizes, but we'll be using "Cohen's d", which is:

$$d=\frac{\bar{x}_1 - \bar{x}_2}{s}$$

where $\bar{x}_1$ and $\bar{x}_1$ are sample means for two different groups and $s$ is the pooled standard deviation. More on the effect size can be found [here](https://en.wikipedia.org/wiki/Effect_size#Cohen's_d). An effect size of 1 means that the difference in means is equal to the pooled standard deviation. If we assume the standard deviations of the groups to be equal, then the pooled standard deviation is simply the standard deviation of the groups.

Thus the numbers I've chosen are:
- $\bar{x}_1=0$
- $\bar{x}_2=1$
- $s = 1$

**The Intuition:** For power, the question is, if we sampled from our true distributions, in this case normal distributions with the above parameters, we wish to know how often we would expect to get a statistically significant result. If we sampled infinitely many samples, we would always get a significant result. Similarly, if we use only a few samples, it is unlikely that we will have a significant result due to random chance.

So basically we draw a set number of samples and run our test. We repeat this process a lot (thousands of times), and keep track of the percentage of times we got a statistically significant test given the number of samples per group that we chose to use. That percentage of statistically significant results is our power.

Here's the code:

```matlab
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
```


<figure>
<img src="power1.svg" width="600px">
<figcaption>Power as a function of group size for an unpaired test.
</figcaption>
</figure>

So if we look at where this plot crosses our target power of 0.80, we see this occurs at 17 samples per group (so n=34 total) with an achieved power of 0.807. Thus far everything is matching up with G\*Power.

## Simulations - Part 2 - "Paired Testing" ##

So now that the unpaired testing is matching up, let's try paired testing.

So my first thought was, this should be easy ...

Let's take this:

```matlab
%ttest2() <= unpaired t-test
is_different(i) = ttest2(s1,s2,'alpha',alpha);
```

to this:

```matlab
%ttest() <= paired t-test
is_different(i) = ttest(s1,s2,'alpha',alpha);
```

Note, internally, for `ttest()`:

```matlab
is_different(i) = ttest(s1,s2,'alpha',alpha);
```

is equivalent to:

```matlab
%Comparing the differences of the paired values to 0
is_different(i) = ttest(s1-s2,0,'alpha',alpha);
```


<figure>
<img src="power2.svg" width="600px">
<figcaption>Power as a function of group size for both paired and unpaired tests. Note, as currently simulated we don't get a boost in power from simply switching to a paired test. This lack of an effect will be explored below.
</figcaption>
</figure>


Well, that didn't work! And in retrospect, there was really no reason that it should have.

## What's Missing ##

A paired test can increase your power relative to an unpaired test if the values are correlated. For some reason this has always made sense to me with the following set of data. Consider the following distribution (left panel) where the effect size looks to be relatively small.

<p align="center">
<img src="fig3.svg" width="400">
</p>

However, if you look at the changes of individual samples, every sample is going up. These changes are summarized in the distribution on the right. The values at the top represent the unpaired p-value (left), the correlation (middle), and paired p-value (right). Obviously, in this case, given the high correlation value, the paired testing was quite helpful.

Below is another example where the correlation has been reduced, and the resulting paired test is not as effective. 

<p align="center">
<img src="fig4.svg" width="400">
</p>

## Two Different Effect Sizes ##

I had initially planned on providing code that demonstrated how to simulate results that took correlation into account. However, I ran into a lot of difficulty which I'll discuss below. So instead I went back to G\*Power and started poking around more closely. Eventually I had a hunch that they must be calculating sample size based on a **single** distribution of the differences, rather than on the two original distributions. Most likely this was a normal distribution, because well, why not.  In other words, our statistical test was now going to be whether the distribution created by calculating differences within each pair was different than 0 (where being equal to 0 means there is no difference in values between the two groups). 

Thus the question became, how do we calculate an effect size when we're comparing a single distribution to a fixed value. After a bit of googling I found this [page](http://jakewestfall.org/blog/index.php/2016/03/25/five-different-cohens-d-statistics-for-within-subject-designs/) detailing 5 different versions "Cohen's d" (the effect size we've been using here) for within-subject designs (which I took to mean paired testing). One of the options is described in that blog post as follows:

> A third way to compute a d-like effect size is to reduce each subject’s data to a single difference score—the mean difference between their responses in each condition—and then use the standard deviation of these difference scores as the denominator of d. Cohen actually discusses this statistic in his power analysis textbook (Cohen, 1988, p. 48), where he carefully distinguishes it from the classical Cohen’s d by calling it dz.

Basically d<sub>z</sub> is simply the mean of the difference distribution divided by it's standard deviation. In Matlab, if we compare our second distribution, which has had both a mean and standard deviation of 1, to 0, we're essentially using an effect size (d<sub>z</sub>) of 1. Also of note, when I go back and look at G\*Power it clearly indicates it is using d<sub>z</sub> instead of d (obviously, no one besides me would ignore that little subscript!)

In Matlab our test goes from:

```matlab
is_different(i) = ttest2(s1,s2,'alpha',alpha);
```

to this:

```matlab
%Comparing to 0, i.e. is there a change?
is_different(i) = ttest(s2,0,'alpha',alpha);
``` 

As a reminder, is_different is tracking whether random samplings of our distributions result in a positive test outcome when we know there should be a positive outcome because we've specified the true distributions. How often this happens is our statistical power.

The figure below shows our increase in power from using an effect size that is based on the original distributions (d=1) versus one that is based on the distribution resulting from the differences (d<sub>z</sub>=1).

<p align="center">
<img src="fig5.svg" width="400">
</p>

## Translating effect sizes via correlation ##

The observation that I was using different effect sizes  doesn't explain how we go from an effect size that's based on our original groups to one that is based on the distribution of differences. It turns out there is a formula you can use. An article (DOI:10.1037/1082-989X.7.1.105) by Morris and DeShon (2002) suggest you can translate between d and d<sub>z</sub> by using the equation (#12):

```matlab
d_z = d/sqrt(2*(1-rho));
%rho => correlation
```

Note the authors use different notation where d<sub>z</sub> is referred to as d<sub>RM</sub> for repeated measures and d becomes d<sub>IG</sub> for independent groups.

It is a bit surprising that no derivation is given of this equation. Perhaps this, or more specifically, the change in standard deviations due to correlation (see equation 7 in that same paper) is something that is well known from elsewhere?

Note, as the correlation increases the denominator of the equation gets larger, increasing the resulting effect size. A correlation value of 0.5 results in equal effect sizes. Big picture, the more correlated that pre and post test samples are, the more subtracting them will remove variance and thus increase the effect size.

## Equal effect sizes, different t-statistics ##

One thing to be careful of is that equal effect sizes does not mean equal test statistics. Indeed, at the beginning of this post I specified equal effect sizes (values of 1), but got very different sample sizes needed to get my desired power. This can also be seen in one of the figures above where we compare power as a function of group size for the two effect sizes. Thus, it is important to remember that for different types of effect sizes, equal values does not mean equal statistical results (i.e. equal t-statistics).

I think this comes from comparing a single distribution to a fixed value, which we might think of as being more robust than comparing that same distribution not to a fixed value, but to a distribution with its own standard deviation. Here's something I ran into recently.

<p align="center">
<img src="fig6.svg" width="400px">
</p>

In the above figure, we have two distributions. If we compare the blue distribution to the red, or the line (a constant), we might expect that it is more likely we'll get a low p-value when comparing to the red distribution (p1). However, even though the effect size is larger in the red case, on average the p-value is lower when comparing to the line (p2). This example highlights that you can't directly compare different effect sizes, when the type of the effect size is different.

The t-statistic equations from Wikipedia for [unpaired](https://en.wikipedia.org/wiki/Student%27s_t-test#Independent_two-sample_t-test) and [paired](https://en.wikipedia.org/wiki/Student%27s_t-test#Dependent_t-test_for_paired_samples) indicates the following equations:

```
t_unpaired = effect_size_d * sqrt(n/2);
t_paired = effect_size_dz * sqrt(n);
```

From these equations you should note that d<sub>z</sub> will result in a t-statistic that is ~40% higher (square root of 2) than a similarly valued d value. Although a t-statistic needs to be translated to a p-value, the big picture here is that you get an advantage for "equal" effect sizes if you are comparing to a constant than if you are comparing to a second distribution.

## Simulating Correlations ##

So at the beginning of this post my intention was simply to simulate correlations and show the improvement in power as a function of the underlying correlation. Then I ran into some problems that I don't think are super important to discuss. Perhaps the lesson to learn there is that if you run into a road block sometimes it helps to take a step back.

The setup for creating correlated normal distributions is as follows:

1. Create standard normal distributions $X_1 $ and $X_2$
2. Create $X_3$ where $X_3 = \rho X_1 + \sqrt{1-\rho^2}\,X_2$
3. Compute $Y_1$ and $Y_2$ where $$ Y_1 = \mu_1  + \sigma_1 X_1, \quad Y_2 = \mu_2 + \sigma_2 X_3$$

$Y_1$ and $Y_2$ will now have correlation $\rho$.

Above we had determined that simply switching from a unpaired to a paired t-test in Matlab doesn't do anything because we haven't changed the correlation. Below we set $\rho$ to 0.5, which is the point at which the effect size $d_z$ is equivalent to our original effect size, d. This means that if our correlation code is correct, running a paired test with $\rho=0.5$ on a data set where $d=1$ will result in the same statistical outcome as if we were comparing to a constant using $d_z=1$. It turns out that this is exactly what we see.

<p align="center">
<img src="fig8.svg" width="600px">
</p>

## Conclusions ##

