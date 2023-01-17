# Organizing Papers/Knowledge Using Google Sheets #

**Oct. 22, 2022**

In this post I'll describe how I organize papers/knowledge for keeping track of scientific papers that I read. As I described in more detail in a [previous post](../../2020/2020_08_what_do_we_know/), there are a ton of papers on "science" and the rate of accrual of papers seems to be ever increasing. I also described how I think most people in most fields do a poor job of both 1) staying up to date on new papers as well as 2) fully understanding what has already been published. This is not necessarily due to personal failures. When nearly everyone is awful at something, it suggests the system itself might need to be changed. However this post is not about what changes we may want to make (see linked post above), this post is about how I try and stay on top of the scientific literature. I am by no means perfect, and I will highlight some ideas I have on further improvements at the end, but my system has been honed over the past ~10 years and I think it is worth sharing.

# The Main Idea #

When I first started reading papers, I found that I felt like I was learning so much. But when I was done I would try and remember what I had read and had a hard time remembering details. This was despite making notes alongside each paper and highlighting relevant sections, something made easier by the rise of alternative bibliography managers around the time I started graduate school (Mendeley, Zotero, Papers) that were more than just "reference management" tools.

So as a postdoc I started the practice of keeping "lists" of papers that I read. I write these lists on Google Sheets for synchronization and easier searching. Importantly, these lists are my way of tracking what I read, including very specific and often important details of the papers. Below I describe exactly how I do this but the main idea is that at the end of reading I have added a document to my lists, including details meant to help me retain the paper's information, as well as to understand its place relative to others papers.

# High level Overview #

## Document Naming ##

The first step in starting a list is to create a document (Google Sheet). I find choosing a suitable name to be quite difficult and will occasionally change my naming approach. This highlights one of the first important things about my overall strategy; there are few rules and I change my approach as I go. This is NOT a perfect system. In general I try to group topics in a single document and create more specific documents if need be. For example, when I first started I created, a "drugs" sheet. In reality this was not just a sheet about drugs as therapeutics, this also was about receptors and transmitters. At some point I updated the title of the document to reflect this ("drugs_chemical_receptors"). Eventually many drug/receptor/transmitter topics became hard to organize on a single sheet and I started to create additional documents that were more specific. For example, some of the sheets in this category are:

- Drugs__Acetic_Acid
- Drugs__Adenosine
- Drugs__Adrenergic
- Drugs__AlphaAgonists_And_Antagonists
- Drugs__alpha_chloralose
- Drugs__anesthesia
- Drugs__ATP_P2X

and that's just the A's

You'll also notice some small inconsistencies with the sheets, such as adrenergic and alpha agonists/antagonists, where the latter is a subset of the former. Same for anesthesia and alpha chloralose, as well as adenosine and ATP/P2X. These are OK with my system. I'll discuss how I handle this when I discuss handling multiple sheets and documents.

## Paper Identification ##

Within a document I usually start with a "main" sheet or a "human" and "animal" sheet. Humans and animals studies are often done very differently and I find it helpful to separate these in most of my "generic" sheets (more on what generic means later when I discuss non-generic sheets). For most entries, I identify a paper with the following 6 columns:

- year
- authors
- title
- journal
- PMID or DOI
- date added

Within these entries I sort by year, then by last name of the first author. Any sorting levels after that are not specified, i.e., there is no guarantee of the order of two or more papers by Doe et al. 2002 on a sheet. For authors I have the following rules:

- 1 author: list their last name -> last1
- 2 authors: last1 and last2
- 3 authors: last1, last2, last3
- 4+ authors: last1 et al. (last name of last author) - often it is helpful to be able to see who is the last author

Here is a screenshot of all this in action:

<img src="first_6_columns_wb.png">

**Figure 1**: First 6 columns of most of my documents. Notice the various ways of doing author name formatting. Often times the "PMID" column will be "PMID or DOI" and will occasionally have ISBN numbers as well for chapters. 


## Values for Y/N Columns ##

Values for many of the following columns can take on one of the following values:

- **&lt;blank&gt;** : This indicates that the cell has not had information entered into it.
- **"Y"** : Used to indicate yes.
- **"-"** : This is used to indicate no. It is visible but not visually overpowering which makes it easier to see the yes entries. For many sheets this is most prevalent answer.
- **&lt;additional detail&gt;** : Many entries could be interpreted as yes or no, but often it is helpful to add additional detail. For example, when documenting whether a paper is a review or not, valid entries include "Y" but also "systematic", "meta-analysis", etc.

## Next 5 Columns ##

After identifying the paper, the next 5 columns are typically the following:

- **review** : I often abbreviate this as "R" to save space.
- **Jim** : I often abbreviate this as "J" to save space. This indicates that I have the paper. This can be useful if I share a document with someone else, where they can also add a column to track that they have the paper. Ideally once I have read the paper I change this to a score from 1 (worse) to 5 (best).
- **Purpose** : The objective for the study.
- **Summary** : The main take-home message for the study.
- **Notes** : All other notes that don't go into a specific column. Occasionally I will bold notes of high importance.

Here is an example screenshot:

<img src="next_5_columns_wb.png">

**Figure 2**: These 5 columns tend to immediately follow the first 6 columns. Notice that in some cases I copy directly from the document, which I try to indicate with the ue of quotes. None of these papers are reviews; I use the "-" character as to indicate "no", which in general tends to make it easier to understand things.

## Other Aspects of Within Sheet Organization ##

Additional columns are much more variable, although I tend to have the following "topic areas". These include:

- **who** - For people this will often include "men","women" along with types of patients which for me includes "UUI","SUI","neuro" to represent people with urgency urinary incontinence, stress urinary incontinence, and neurogenic patients. In addition to Y/N I will try and include counts (when available). For animals I often have things like "F_rat", "M_rat", "F_mouse", and "M_mouse" where F and M stand for female and male.
- **experiment methods** - These columns focus on how the experiment was executed. This is very specific to the sheet. For example, for electrical stimulation I document how the stimulation amplitude, rate, and pulse width, as well as location of stimulation (if not clear by the sheet topic). Sometimes this can get complex as one parameter may have been used in one test and another parameter in another test. I do my best to document this in the cell. Other times I will make this multiple columns where each column indicates the presence or absence of some aspect of the test.
- **analysis** - What data were analyzed. This can often be inferred from the experiment methods but of course there are multiple ways of analyzing collected data. For electrical stimulation, this may include understanding how the response varies with rate or with amplitude ("vs_rate" or "vs_amp")

Again, it is important to note that these columns tend to be flexible. Often I will add columns as I am reading papers and realize there is something I want to track. I also like to break out these sorts of sections by color to help with my organization (see screenshots below).

<img src="group_wb.png">

**Figure 3**: An example of documenting the subjects involved in a study. Where possible I try and use more detail, in this case numbers, rather than simply "Y" or "N"

<img src="location_wb.png">

**Figure 4**: Another grouping example, this one documenting stimulation location for "pudendal" nerve stimulation. Ideally I would be more proactive with my use of the "-" character to indicate that the various locations were not stimulated.

<img src="analysis_wb.png">

**Figure 5**: Another grouping example, again where "-" should probably be used more. Note, I try not to use "-" unless I have explicitly confirmed the absence of something. A blank space by comparison means the value hasn't been explicitly logged one way or the other.

Here are some example screenshots:

**Important Note**: My sheets are far from perfect, and many have blank entries or don't follow the format above. Here is an old sheet in a bit of a different format. At some point if I am doing more work with this topic I may rearrange things a bit, and that's OK!

<img src="aa_wb.png">

**Figure 6**: One of my older sheets with a different format.


# Adding Entries #

I tend not to be very good about reading individual papers. To "stay current" on papers I get email notifications from Google Scholar about new papers. I also occasionally remember to skim through journals for new articles. In both cases however I rarely read more than the abstract and will often simply download papers of interest to read at a later date.

Instead, most of my deep reading of papers tends to come from:
- reviewing a paper or grant
- inspired from a question from ongoing research
- writing a paper
- spontaneously wondering about some topic and doing a deep dive (I do this alot ...)

The process of working with sheets can be broken down into two distinct processes, adding entries and entering additional data. I tend to do these two tasks seprately.

When I'm reviewing a paper or reading a really interesting paper, I'll often first go through the references and find ones related to the topic of interest. These are then added to my sheet.

<img src="missing_papers.png">

**Figure 7**: An example of papers that I have logged as being relevant to the topic at hand, but where I have not entered in all of the baseline information.

Note, I initially colored the entire row green to indicate a missing paper. This caused problems when I started adding colored columns to denote different sections, as undoing the row color would impact the dividers. I then switched to simply highlighting the first 3 columns. However, it is pretty easy to see which rows are incomplete and I've largely stopped highlighting these rows.

Adding the title can be a bit of work, particularly if trying to copy from PDFs. Occasionally if I'm in a hurry I will simply enter into the title something like the citing paper's author and year so that at a later point in time I can go back and find the specific paper being referenced.

Some entries are also tough to find. In those cases the "journal" entry may contain:

- name of the relevant conference and abstract page info
- name of book and page numbers for a particular chapter
- I may also enter "requested", with a date, if I couldn't find the entry and made a request to my libary
- etc.

Other approaches to adding papers include searching Pubmed or Google Scholar for topics, or occasionally I will simply search my personal library of papers (i.e., search my Zotero library). 

Depending on how I'm feeling, I will then go ahead and add the fully entry. As of right now, adding information for the full entry (adding journal, PMID, date added, as well as ensuring authors and title are correct) indicates that I have that particular paper in my library. As a reminder, I do have a column that indicates if I have the paper, which would theoretically allow me to track papers in my library even if someone else (that I shared the document with) adds the full entry.

I find this whole process to be relatively mindless and something I can and often do while watching TV. Remember, in this case the goal is not to read papers, it is simply to create a "reading list" of papers and to ensure that I have the papers in my library. This makes it easier for me to focus when I'm reading papers.

# Adding Detailed Paper Information #

This step unfortunately is generally not possible while multi-tasking.

Rather than reading papers randomly, I often read by topic, reading papers from one of my sheets. I find it most useful to start at the beginning or at some earlier point of my choosing (i.e., might start reading papers from 2000 or 2010, depending on the topic, as some older papers can be quite a slog). I find this approach useful because it recreates, to some extent, how the papers came into existence. If instead I were to read in reverse chronological order, I have less of a base of knowledge to draw upon. Reading in chronological order I am better able to understand what was done, as well as see ideas and concepts develop.

Note, if I am trying to quickly get caught up on a topic sometimes it can be helpful to read a recent review paper. There are always exceptions to the rule!

As I'm reading I will inevitably find papers I've missed. Again, depending on my mood, I may first go back and read the old paper, or I may simply add a partial entry in my list. I will rarely however add a full entry to my list (check if the paper is in my library, download it if not, add all of the first 6 columns to my list). Adding the partial entry is menat to be quick and not distract too much from the process of reading.

# Multiple Sheets #

Thus far we have largely focused on single sheets in a document, or potentially having two sheets, one for animals and one for humans, as the type of information logged is often very different between the two.

As I'm documenting a topic, I will occasionally hit upon a subset of the topic that I want to track in more detail. For example, for sacral neurmodulation, I may be interested in understanding factors that are associated with treatment success, or surgical best practices, or improvements to the way the therapy is delivered (e.g., tined lead, MRI compatibility, curved stylet, etc.). These topics are then added as additional sheets in the document. Ideally in these instances the new sheet has more than 1 column of new information, as otherwise it could simply be a column in the original sheet.

Another instance where I have multiple sheets is for a generic topic that has many specific sub-topics. We've already encountered this with drugs, where originally I had one document with multiple sheets about different drugs. Other notable examples of this include testing, where the sheets in a document are different tests related to the same overall type of testing (e.g., urethral motor testing), and anatomy, where sheets will focus on different anatomical components (e.g., urethra, bladder, puendal nerve, pelvic nerve, etc.)
 
All of these examples use roughly the same format as outlined above. However, as is hopefully clear by now, I sometimes deviate from this setup. For example, in drugs it is common for me to have a sheet with very specific drug names and descriptions of what they do. Another example is a table that documents the type of motor or sensory responses observed from stimulation of different spinal levels. Technically this could be documented in a more traditional format, but sometimes I prefer a more compact format. Again, if I want to track something, I will, without too much worry about sticking to a particular format.

One challenge with my approach is that it can be hard to find particular entries. Occasionally I will open up a document looking for a particular topic, e.g., urethral instability, and it won't be in that document. Once I find the document with the topic I go back to the original document and create ... a link! I was pretty excited about this particular "invention." One of the first sheets in many documents is a links page that describes sheets related to the current document, with links to the relevant sheets. Some of these link sheets also serve as tables of contents, describing the intentions of the other sheets in the document.

Finally, some documents have LOTS of sheets. Unfortunately Google Sheets does not support vertical tabs. I wrote a javascript add-on that will bring up a vertical list of sheets. Clicking on a sheet name will navigate to that sheet. More info on this is in a [previous blog post](../../2020/2020_04_Vertical_Tabs_Google_Sheets/). Here's what that add-on looks like for my sacral neuromodululation document:

<img src="gs_add_on.png">

**Figure 8**: Screenshot of my vertical sheets add-on. Clicking on a sheet navigates to that sheet. See referenced blog post on how to setup.

# Future Directions What's Missing #

This system is far from perfect, but I've found it helps pretty well with paper recall. The following are a few final thoughts on what could be improved further.

**Better Entry Adding:**
Adding entries, particularly for systematic searches, takes work. I've created a script that takes a Pubmed ID and send the first 6 columns to the clipboard for pasting into a document. I'm also working on creating scripts that will take a set of documents, whether from a Pubmed search or from a Zotero search and add them to a particular sheet. This is low priority for me and is not yet public.

Currently it is possible to have a paper in multiple locations, which can lead to some duplication. I try not to worry about this but it does bug me a bit. I could imagine that a program specifically designed for this type of work might support different views, where each view only showed particular papers, and in the process of filtering also added additional columns specific to that filter. For example, if one was looking at predictive models for sacral neuromodulation (the filter), additional columns could describe the modeling approaches used, what was targeted specifically with the models, etc.

**Attaching figures with markup to cells**
For a while I've wanted to support pop-up images in cells. The full vision is to have a cell that when clicked on, would bring up an image or set of images demonstrating some phenomenon. Google Sheets does support embedding drawings into cells, but my impression is that the drawings have to be made first. Below is a demonstration of the type of image that would be linked from the sheet, ideally with real editing software to track metadata. 

<img src="figure_markup.png">

**Figure 9**: Hypothetical figure markup program that ideally would be easily attached to cells in a document. The app would support easy logging of meta data that could be searched (e.g., bring up all real urodyanmics traces with EMG recording).

**


- easier to add entries
- images as thumbnails or with markup
- coverage (where is my document)
- could work better as a dedicated program - if column is true, then add another sheet with other things that are tracked.
- check papers in library from paper
- mesh
- export
