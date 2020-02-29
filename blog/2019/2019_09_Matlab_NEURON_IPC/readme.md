# Matlab NEURON Inter-Process Communication #

In this post I'll discuss code I've written for Matlab to communicate with a modeling program called [NEURON](https://www.neuron.yale.edu/neuron/). Having not worked extensively with complicated scripts or commands in Unix, this was also my first exposure to [standard streams](https://en.wikipedia.org/wiki/Standard_streams) which I discuss in more detail below.

## Motivation ##

One aspect of my research involves learning how neurons, the primary cells in our nervous system, respond to electrical stimulation. This knowledge can be used to improve and develop new therapies that deliver electrical stimulation to treat human diseases. A common example I give people is that of the artificial cardiac pacemaker, an implanted device that delivers electrical stimulation to help a person's heart function properly.

This research can be done in physical experiments, but these experiments often require significant time, effort, and financial resources. An alternative approach, quantitative modeling, involves creating computer programs to understand some facet of electrical stimulation of the nervous system. This approach carries perhaps a bit more uncertainty, as most models are fairly simple compared to real life. However, the models often allow a researcher to test orders of magnitude more "experimental setups" than actual physical experiments, with the results from these tests being used to generate hypotheses or understanding of phenomena that have been observed in the physical experiments.

NEURON is a program, or according to Wikipedia - a simulation environment, that can be used to create and run computational neural models. For a long time, the main programming language that a person used to interact with NEURON was a language called [Hoc](https://en.wikipedia.org/wiki/Hoc_(programming_language)). More on NEURON and hoc can be found [here](https://neuron.yale.edu/neuron/static/docs/refman/hoc.html). Hoc itself is not the most fun scripting language in the world to use, and often times it was more desirable to write code in another language, and then pass the minimal amount of information necessary to NEURON for execution.

It should be noted that now significant effort has gone into providing Python as a front end to NEURON. I'm not entirely sure when this first occurred (perhaps around 2007 or 2008), but my impression is that solid support and documentation only became available more recently (Version 7.3 in 2013?). I have not used the Python version, although my impression is that if it had been more polished in 2007 I might not have developed this Matlab code. The other sticking point was that I used the code I will be describing to write a large portion of my PhD thesis, and I wasn't comfortable writing that in Python as, at the time, I was quite the Python novice.

## The Basic Approach ##

