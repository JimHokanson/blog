## February 2, 2021 - A New Type of Review "Paper" ##

[article link](2020/2020_08_what_do_we_know/)

How we manage scientific knowledge is a mess, at least when it comes to anatomy and physiology (in my humble opinion). I've finally taken some time to jot down some of my thoughts on the matter. I'm not optimistic about the future in this area but I figure perhaps the first step in moving forward is to describe the problem. I'm not sure what the second step is.


## July 3, 2020 - Vertical Sheet Navigation in Google Sheets ##

[article link](2020/2020_04_Vertical_Tabs_Google_Sheets/)

I often use Google Sheets to organize information (something I hope to blog about in another post). Navigating between sheets can be difficult if a document has numerous sheets. In this post I document my efforts at creating a vertical sheet navigation system to make it easier to navigate between sheets in a document.

## April 6, 2020 - The (Statistical) Power of Pairs ##

[article link](2020/2020_04_Power_Of_Pairs/)

Nearly a year ago I began working on some simulations for a power analysis I was doing for a grant. My first attempt at simulating paired testing was a complete failure. This article describes my attempt to better understand what exactly it means to do paired testing and how to go about simulating paired testing.

## January 19, 2020 - Better Debugging in Matlab ##

[article link](2020/2020_01_running_clipboard_code_matlab/)

The other day I was helping someone with some Matlab code. They had highlighted 30ish lines and evaluated the selection. Matlab told him there was an error, but where? **runc()** to the rescue! 

## August 6, 2019 - Plotting of Streaming Data in Matlab ##

[article link](2019/2019_07_stream_plotting_matlab/readme.md)

This article describes a class I wrote for my plotBig library which allows the user to plot data as it is collected. This code has similar functionality to Matlab's animatedline function but is often much faster.

## February 17, 2019 - MCS Stimulator Library ##

[article link](2019/2019_01_MCS_Matlab/readme.md)

This article discusses the development of a Matlab wrapper for use with MultiChannel System's electrical stimulators. I've also created code that can be used to design stimulus patterns for the MCS stimulator as well as other stimulators (e.g. something driven by a NI-DAQ). 

## October 25, 2018 - Turtle JSON Benchmarking ##

[article link](2018/2018_08_Turtle_JSON_speed/readme.md)

Which parser is up to 10x faster than other fast Matlab JSON parsers? This one! Benchmark data are provided for comparisons to other Matlab parsers as well as a comparison to JSON parsers in other languages.

## August 18, 2018 - Blog version 3 ##

[article link](2018/2018_08_Blog_Version3/readme.md)

Bye bye GitHub Pages, hello GitHub.

## July 2018 - "Porting" a Simple Matlab Program for Octave ##

[article link](2018/2018_07_Matlab_to_Octave/readme.md)

This post briefly describes my experience porting a Matlab program to Octave. There were many changes that needed to be made but nothing that was so onerous as to warrant rewriting using a different language.

## January 2018 - Speeding up Matlab Line Plotting ##

[article link](2018/2018_01_PlotBig_Matlab/readme.md)

Ever try plotting 20 minutes of data sampled at 20 kHz in Matlab? It's not a lot of fun. I wrote a bit of code to make plotting of line plots in Matlab much faster. Working out the SIMD intrinsics for this project was a challenge but was fun to get working.

## January 2018 - Writing a performant JSON parser in Matlab to facilitate scientific data exchange ##

[article link](2018/2018_01_Turtle_JSON_Intro/readme.md)

This post introduces a JSON parser I wrote for speeding up parsing of JSON in Matlab. This post focuses on the C code I wrote to do the majority of the parsing work. It focuses on techniques I used to make the parsing fast.
