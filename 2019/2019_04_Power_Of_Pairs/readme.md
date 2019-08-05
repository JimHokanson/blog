# The (Statistical) Power of Pairs #

Anyone that has been in research long enough, or paid close attention in statistics class, knows that in addition to worrying about Type I error (claiming statistical significance when none exists, p < 0.05, etc.) you also need to worry about having done enough "experimentation" to avoid saying there is no statistical significance, when one is actually there (Type II error).

This is known as Power Analysis.

In this post I introduce the need for power analysis for a grant I'm working on in predictive modeling (machine learning) and discuss my experiences learning what it means to simulate a statistical test that takes pairing of samples into account.

# Statistical Comparison of Classification Models #

I took my first and only machine learning class at Carnegie Mellon University back in 2009. It was a fun experience and I learned a lot. However one thing we never discussed (I think) was the statistical comparison of different classification models. 

In talking with a machine learning mentor of mine, Professor David Carlson, he made it clear that the notion of statistical testing is often an afterthought in the literature. However, he noted, when it comes to the introduction of predictive models into a medical environment, then it becomes ... slightly less of an afterthought.

His sentiments matched my research experience. Prior to talking to David about my grant, I had tried to write a section of my grant detailing how I would compare the models I was proposing to develop. The literature was a mess of contradictions, particularly for small datasets. Many comparison methods seemed to be overly optimistic in terms of the expected performance variance due to data reuse. Additionally, one needs to specify what better means (AUC, accuracy, Brier score, etc.).

At some point I would love to write a review article about this, because I find it extremely interesting that what seems like a simple problem is something that the field has yet to definitively answer. But that's a story for another time.

In talking to David he mentioned two things that can increase statistical power when comparing models. First, when advising patients of the probability of an outcome given their personal data, they are typically told a probability, not a binary value. For example if they wish to know the likelihood of responding to treatment, they may wish to know that they have, for example, a 60% chance of responding to the treatment, rather than that they are more likely to respond than not (a binary yes or no answer). If another model is 90% sure the patient will respond to treatment, and the patient actually will respond to the treatment, then the second model is considered (by our metric), and improvement over the first model (since 90% is higher than 60%). If however, the second model is wrong, then it get's penalized more since it was overly confident in the wrong answer. 

A brief aside on chance .... When viewing numbers like 60% or 90%, which can be stated more formally as probabilities, one might get the impression that these numbers represent chance. Put another way, the patient hearing that they have a 60% chance of responding to treatment, is right to interpret that this means that out of people like them, 6 out of 10 of them will likely respond to the treatment (if the model is well calibrated). However, this does not mean that if the patient were to undergo the same treatment 10 times, that 6 out of 10 times they would respond, and 4 times they would not. Rather, we assume that for the most part, the outcome is well defined, and that the reason the model suggests a 60% chance rather than a 90% chance is that the model doesn't know enough about the person to be more definitive. In other words, improvements in model performance come from better use of the data, not from somehow making patients more lucky.

The second method to improve statistical power is to acknowledge that every sample (patient) is being judged twice. 



- comparing two classifiers
- need to be well calibrated
- mention the state of the field in this area is a big mess (for smaller data)
- GPower - 