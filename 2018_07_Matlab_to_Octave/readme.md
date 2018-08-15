# "Porting" a Simple Matlab Program for Octave #

** Started July 11, 2018 **
** Finalized ... **

For someone who has continuously had a Matlab license for over 15 years now I had given relatively little thought to using GNU Octave, a programming language and environment that has spent considerable effort to be mostly compatible with Matlab code.

As part of a project that I'm working on I wanted the ability to run my Matlab code as a standalone program on another computer without the need to install any software. Matlab advertises the ability to generate a standalone program. I had not tried this before and  I knew that it required the inclusion of a runtime environment. Unfortunately deploying Matlab code required either:

1. A small executable (a few kB or maybe even a few MB) that could download and install the much larger runtime.
2. A large executable (roughly 1 gigabyte!) that still required install permissions on the remote computer - in other words, you couldn't just execute the file directly.

Alternatively Matlab offers a "Matlab Coder" product which can generate C code, but it doesn't have GUI support (which I needed). I tried deploying a simple Python test GUI, which ran well and was extremely small, but that would require translating all of my code into Python.

As an alternative Octave can be downloaded and run as a standalone program. It is a large download (400 MB) and is roughly 1 GB (2GB?) unzipped, but it can be run without intall privileges.

**The following documents my experience in getting a Matlab program to run in Octave.  Overall the process was relatively straightforward although not trivial.**

# Excel Support 

The biggest concern was finding some missing functionality that would be nearly insurmountable to work around, requiring rewriting the code from scratch. My first concern was for reading Excel files. 

Fortunately Octave supports reading from Excel files. To do this requires downloading and installing the 'io' package. Figuring out how to download the package was a bit confusing but not too terribly difficult. The package also needs to be loaded on startup to use. In general the interface worked well. The Matlab Excel interface is really terrible with the way it handles data types and the Octave version was actually a relative improvement (slightly).

# GUI and Graphics

One of the first issues I ran into was that Octave doesn't support loading of figures from ".fig" files. I tend to do most of my GUI design using GUIDE to layout the GUI how I want it and then a set of classes to implement the logic behind the GUI, rather than utilize the auto-code generation features. This means that the GUI layout is saved in a binary '.fig' file. 

As a workaround I found the function [fig2m.m](https://www.mathworks.com/matlabcentral/fileexchange/14340-convert-fig-to-matlab-code). Unfortunately the code had a few bugs in it so I modified it slightly for my needs. The resulting code ([exportToScript.m](https://github.com/JimHokanson/matlab_standard_library/blob/master/%2Bsl/%2Bhg/%2Bfigure/exportToScript.m)) is not a complete replacement for 'fig2m.m' but it does generate bug-free code that recreates the figures.

Octave also doesn't support GUI tables (uitable). Fortunately it supports listboxes. As a workaround I create strings which are concatenations of all columns in a row spaced out so that it looks like columns are present. This approach looks pretty good and works in the case where only row selection is necessary. The one sort of ugly thing about this approach is that headers are not well supported. Either a separate listbox is needed for the headers - which doesn't do horizontal scrolling with the table - or the headers can be placed in the main listbox - and then the headers disappear on vertical scrolling.

TODO: Show diagram and link to code

Finally, Octave doesn't support graphics handles as objects. Instead graphics handles are returned as numeric values, similar to Matlab behavior prior to 2014b. Prior to 2014b, working with properties of graphics handles required the use of set() and get() functions, rather than the new behavior of dot access notation. 

```matlab

h_fig = figure();

%Matlab >= 2014b
c = h_fig.Color;

%Matlab <= 2014a and Octave
%Also works with newer versions of Matlab as well
c = get(h_fig,'Color')

```


# Package and class support #

I also use packages and classes in Matlab very frequently and was worried that something in this space might not translate into Octave. I ran into a few issues but nothing too huge. These issues are briefly summarized below:

1. **No functions in classes** - In Matlab you can define a local function outside of the class but in the same file. I tend to use these to break up big functions into smaller pieces that are only called internally to the class. I submitted a bug about this to Octave and in the mean time I moved all my functions back into the class definition (as class methods).

2. **package and class conflict** - When you see something like `io.my_caller()` in Matlab, this can either be a io class with a static method or an io package with a function inside of it. Matlab allows you to have both the class and package, with a mix of functions in either (e.g. supports io.my_method and io.my_function - different names, one in a class and one in the package - simultaneously). Octave is unable to support this behavior which meant a bit of refactoring.

3. **which() for package function** - which() doesn't work properly for functions inside packages, so mfilename needs to be used instead.

4. **package functions shadowing builtins** - Similar to #3, package functions are detected by Octave as shadowing builtins and warnings are thrown when these functions are loaded into memory. The package functions can still be called - and I think the builtins can be too - so I just placed a warning silencer for this warning. This is a known issue with Octave.


# Other Differences #

Other differences include:

1. The default matfile save behavior for Octave is ASCII/plaintext! Additional inputs are needed to save in Matlab's binary format.

2. Octave does not yet support tables (not uitables, but something like dataframes in other languages).

3. Missing join() function

4. fopen() call is different, no encoding option

5. no Java!!! - I needed to replace java.util.TimeZone.getDefault with localtime and gmtime calls

6. I found a bug when rendering my GUI the first time it was run; a white text box was not showing properly. Calling a plotting routine then closing the plot figure, then plotting my GUI fixed the problem.

7. Octave has the concept of an object array. You can't do something like `a.b.c.d` if `b` is an object array, even if it contains only 1 object. The object array needs to be converted to an object first.

8. The program would often hang when quitting debugging.

9. Function handles can't be constructed with any dots `fh = @my_package.my_function` is invalid

10. `sortrowsc` doesn't exist in Octave. I've used this mex function that ships with Matlab to speedup processing.

11. Octave also seemed to be more up to date with some warnings. I was using `isequalwithequalnans` in Matlab but apparently this hasn't been the recommended function for a while now (use `isequaln` instead). Using the old function in Matlab is fine but throws a warning (error?) in Octave.

# Conclusions #

There were a lot of subtle differences between Matlab and Octave but nothing major.

Unfortunately Octave is noticeably slower than Matlab. My estimate would be something on the order of 5x for my use case. But hey, Octave does offer a truly "standalone application" with no installation required.

Even though I developed a lot of code on my slower Mac laptop, I tried the code in the clinic where I was running on a laptop circa 2009 running 32 bit Windows. Since I want this to be as user friendly as possible, I'm worried about forcing someone to download a 400 MB zipped file and having them wait for 30+ minutes for it to unzip so that it can run for an hour in what should really only take 1 minute to run. Thus I'm now rewriting my code using Visual C# with the bulk of the processing being done inside custom functions written in C (linked back to C# with as a DLL). 
