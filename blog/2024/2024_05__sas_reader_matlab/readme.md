# Writing a SAS Data Parser in MATLAB #

In the following blog post I will describe my thoughts related to writing MATLAB code that can load SAS binary data files -- those with the .sas7bdat extension.

Part of this is self-documentation of my endeavors. However I also found the whole experience quite interesting as unlike many other file formats I work with, the SAS format is quite popular and is "supported" by some quite popular packages (Pandas for Python, Haven for R). It was interesting to see the chaotic mess that is supporting a non-documented file format. Thoughts on partaking in this "experience" are shared below.

# Introduction #

I'm currently working on a project that involves something called a data coordinating center or DCC. The DCC is a group of people that help aggregate data from multiple testing sites and, at least in our case, provides statistical assistance on projects. 

As part of a project I'm working on I asked to see some of the files the DCC was working with. Being (good?, true?) statisticians they sent me some data as SAS binary data files in the .sas7bdat format. They asked me whether I would prefer it if they exported the data as CSV files instead. Trying to get the data quickly, and figuring I could get any code to work ;) I declined their offer to export the files. One relatively quick "data use agreement" later I was logging onto a SharePoint server to download my data.

I was hoping that the [Mathworks File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/) would have a solution for loading these files into MATLAB. Unfortunately that was not the case. The only thing I could find was [this code](https://www.mathworks.com/matlabcentral/fileexchange/15835-import-data-from-sas) which uses ActiveX to load the SAS file into Excel, saves the resulting Excel file, and then uses standard MATLAB functionality to load the Excel file; not ideal. A similar search of GitHub, which I often search in addition to the file exchange, failed to find any results.

Recently MATLAB has been strengthening its ability to interface with Python. I figured perhaps I would try loading my file in Python. If that worked I would then write a wrapper to load the file in MATLAB, by calling Python. Note that unlike the Excel approach above MATLAB has built a way of sharing memory between Python, as opposed to writing and reading a file from disk. 

A quick Google search suggested that Pandas, the "default" table loader in Python supported reading SAS files. I pointed Pandas at my file (maybe 1 GB in size?) and ... waited. After maybe 30 seconds I quite the process. After looking at the Pandas SAS code that looked functional but not exactly designed for performance, I decided that maybe I wanted to spend some of my free time shaving yet another Yak, or in this case, writing yet another MATLAB parser. 

Keep in mind, the CSV exporting from the DCC was still an option, but how hard code this be ....

# The Unlikely (?) Hero #

At this point I Googled "sas7bdat file format", hoping (praying really) that the file format was documented. To my disappointment it quickly became clear that SAS had not released any documentation on the file format. Fortunately after a bit more searching I found a R "Vignette" by one Matthew S. Shotwell, PhD, documenting the format.

It is impossible to describe adequately the excitement, surprise, and awe reading through his document. I've reverse engineered a decent number of file formats and with the exception of one a [long time ago](https://github.com/NeuralDataFormats/matlab_xltek_epworks_parser) (possibly my first) , I've refrained from posting details online. Yet here was this document with extremely useful details for creating a parser just shared online like it was no big deal.

Here's the opening text. 

```
The SAS7BDAT file is a binary database storage file. At the time of this writing, no description of the SAS7BDAT file format was publicly available. Hence, users who wish to read and manipulate these files were required to obtain a license for the SAS software, or third party software with support for SAS7BDAT files. The purpose of this document is to promote interoperability between SAS and other popular statistical software packages,
especially R (http://www.r-project.org/).

The information below was deduced by examining the contents of many SAS7BDAT databases downloaded freely from internet resources (see data/sas7bdat.sources.RData). No guarantee is made regarding its accuracy. No SAS software, nor any other software requiring the purchase of a license was used.
```

Beautiful!!!!

I emailed Matt to see if his code had any new updates that he hadn't shared yet, as the majority of [his code](https://github.com/BioStatMatt/sas7bdat) was posted 10+ years ago. He responded fairly quickly indicating that he did not, and that efforts to improve the parser had largely moved elsewhere. I'll be describing some of these efforts below, but it is important to make clear that most, if not all, of the other parsers are based on, and presumably benefited tremendously from, Matt's work. Thank you Matt!!!

# Scattered Ecosystem #

As I indicated above, this is the first project I've ever worked on where people were publicly posting their efforts to reverse engineer a well known file format.

What was surprising, and also frustrating, was that despite the numerous SAS parsers that now exist, most of which were based on Matt's work, none seemed to have invested effort in creating and updating a centralized repository documenting the file format. For me this meant reading through the code for multiple parsers, rather than being able to go to one central location for all the necessary information.

Another issue I found frustrating was simply software discovery. In 2024 it remains challenging to find "the right" software. For example, Pandas is NOT the right way to load SAS files in Python. Instead, you would be better off in many cases (but maybe not all?), using [pyreadstat](https://github.com/Roche/pyreadstat) or perhaps [sas7bdat](https://github.com/jonashaag/sas7bdat); I don't know! The pyreadstat code is distributed by [Roche](https://www.roche.com/), a major multinational company in the healthcare space. It is wild to me to see a company posting this type of code.

For what it is worth I think the most "correct" parser is called [Parso](https://github.com/epam/parso). Unfortunately the code is written in Java, and many languages (Python, MATLAB, R, etc.) have a pretty significant performance penalty when calling, or in particular sharing data with, Java based code. I'll note I may be missing better parsers since again, software discovery is still quite difficult.

# Differences in functionality #

The following is my attempt to briefly document major differences in functionality. It is important to note that these SAS files are basically data tables, i.e., a big spreadsheet with column names and rows of values.

A lot of differences in functionality between programs involve parsing quality. In particular there are many differences in terms of support for:

- binary compressed data
- different date, time, and datetime formats
- different string encodings
- hiding entries that have been "deleted" but are still in the file

Most of these issues arise because they were not covered in Matt's documentation and no one bothered to pass that information back to him when they figured it out. The middle two are a bit more complicated because of the large variety of options available. As an example, one column I loaded had the datetime format of "MINGUO" which is a Taiwanese datetime format. I hadn't added support for that format yet. It took only a few minutes to add support but without a comprehensive list often you add new entries as they come up in new files. Other than perhaps the Parso SAS parser I haven't seen any systematic effort to generate different test files that support all of the possible column formats. Even Parso may be incomplete; it is tough to tell as they don't exactly discuss how they made their parser and what the test files are doing.

The second big issue, besides parser accuracy, is the interface. Big issues here include support, or lack there of, for:

- accessing column labels (descriptions)
- filtering for specific values (e.g., all rows where name=="Jim")
- reading only certain rows (e.g., rows 100 to 200)
- including or excluding specific columns

Most parsers appeared to be pretty bad in this area. That being said, I'm sure many of the people writing the parsers felt like they were doing a good job just loading the file and figured at least now the user could do most of these things in post processing. I know I would generally feel that way. Unfortunately now I had GB files so all of a sudden I found myself a bit more interested in supporting being able to load only a part of the file. 

# Performance #

Earlier I mentioned that part of the impetus for creating a MATLAB parser was the extremely slow performance of the Pandas parser. Unlike previous work I've done with JSON

# File Structure #


# Shared files #


# Debugging code #




Remaining topics
- shared files - starting this
- performance thoughts
- Eclipse and IntelliJ and debugging
- weird format things
- conclusions



