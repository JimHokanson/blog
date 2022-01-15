# Efficient Mex Performance Logging - Intro #

A few years ago I was working on creating a fast JSON parser for MATLAB. One feature that I wanted was the ability to log what was happening during parsing. The following is a short overview of my original logging approach and the new logging approach that I used.

# Original Approach - A MATLAB structure #

The original logging approach was to create a MATLAB structure for logging. For example, in MATLAB the code would have been something like:

```
s = struct('time1',[],'time2',[]); %etc.
%run some code
s.time1 = time1;
%run some code
s.time2 = time2;
%etc.
```

In C, this approach is quite a bit more verbose.
```

```


# Intermediate Approach - An Array #


# Final Approach - A C Structure #


# Conclusion #