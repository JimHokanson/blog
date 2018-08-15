This post documents my experience writing a [JSON](https://en.wikipedia.org/wiki/JSON) parser in Matlab. The goal was to write a parser that made reading files of moderate size (10s to 100s of MB) not painful. Along the way I got my first exposure to within and between processor parallelization (using SIMD and openMP respectively). In particular this post was written to document some of the approaches I used to try and make parsing JSON relatively fast (using C mex).

Code for this post is located at:
[https://github.com/JimHokanson/turtle_json](https://github.com/JimHokanson/turtle_json)

# Introduction #

I am part of the [OpenWorm](http://openworm.org/) organization where our goal is to model a worm, the C. Elegans, as accurately as possible on a computer. Along the way we hope to learn general approaches for creating highly accurate models of even more complex organisms.

My role in the project has consisted of setting up a test framework for the analysis of worm movement. The goal is to be able to compare our modeled worms to real worms to guide model development.

At some point, some real worm scientists started discussing creation of a data format to facilitate sharing of data between worm labs. My interest in working on this project was pretty minimal, as I was (and still am), more interested in working on comparing the modeled worms behavior to real worms. After some prodding, I was finally convinced to help out, mainly because I was someone who was proficient in Matlab, a language that a sizable portion of worm scientists use.

The decision was made to specify the data format as deriving from JSON, a really simple text format that takes just a [handful of pictures and words to describe](http://json.org/). This is an example JSON document.

<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;">{
         <span style="color: #062873; font-weight: bold;">"age"</span>: <span style="color: #40a070;">34</span>,
        <span style="color: #062873; font-weight: bold;">"name"</span>: <span style="color: #4070a0;">"Jim"</span>,
    <span style="color: #062873; font-weight: bold;">"computer"</span>: {
                  <span style="color: #062873; font-weight: bold;">"name"</span>: <span style="color: #4070a0;">"Turtle"</span>,
                    <span style="color: #062873; font-weight: bold;">"os"</span>: <span style="color: #4070a0;">"Windows 7"</span>
                },
     <span style="color: #062873; font-weight: bold;">"my_bool"</span>: [<span style="color: #007020; font-weight: bold;">true</span>, <span style="color: #007020; font-weight: bold;">false</span>]
}</pre>
</div>

## Exploring My Options ##

Before getting started on writing worm specific code I needed to find a JSON parser for Matlab. Looking at the file exchange I found many options. Here's a brief (and most likely not comprehensive) list (compiled in late 2016?).

1. [JSONLab](https://github.com/fangq/jsonlab) (Qianqian Fang) - written using Matlab code, probably the most popular option available
2. [matlab-json](https://github.com/christianpanton/matlab-json) (Christian Panton) - mex wrapper for [json-c](https://github.com/json-c/json-c)
3. [Core_jsonparser](http://www.mathworks.com/matlabcentral/fileexchange/53698-core-jsonparser--import-and-export-json-files-using-matlab) (Kyle) - Makes calls to Python using some relatively new Matlab functionality (2015?)
4. [JSON encode/decode](http://www.mathworks.com/matlabcentral/fileexchange/56214-json-encode-decode) (Léa Strobino) - mex wrapper for [JSMN](https://github.com/zserge/jsmn) tokenizer
5. [JSON Parser](http://www.mathworks.com/matlabcentral/fileexchange/20565-json-parser) (Joel Feenstra) - Matlab code
6. [Highly portable JSON-input parser](http://www.mathworks.com/matlabcentral/fileexchange/25713-highly-portable-json-input-parser) (Nedialko) - Matlab code
7. [(another) JSON Parser](http://www.mathworks.com/matlabcentral/fileexchange/23393--another--json-parser) (François Glineur) - Matlab code
8. [Parse JSON text](http://www.mathworks.com/matlabcentral/fileexchange/42236-parse-json-text) (Joe Hicklin) - Matlab code
9. [v8 native JSON parser](http://www.mathworks.com/matlabcentral/fileexchange/48867-v8-native-json-parser) (Eydrian) - wrapper for a V8 c++ parser
10. [matlab-json](https://github.com/kyamagu/matlab-json) (Kota Yamaguchi) - wrapper for a Java library

In the end, I decided to write my own JSON parser. My test case was a 75 MB file. Using Matlab's native loading, i.e. loading the contents when they had been saved as a .mat file, the file took about 0.55 seconds to load (on my desktop using the '-v6' mat-file version). JSONLab, arguably the most popular library for reading JSON files in Matlab took 30 seconds, 18 seconds if you were using 2015b or newer due to [efforts to speedup Matlab processing](http://blogs.mathworks.com/loren/2016/02/12/run-code-faster-with-the-new-matlab-execution-engine/). Faster options such as Christian Panton's C-based parser lacked flexibility and returned everything as cell arrays that needed to be concatenated in Matlab, a massive waste of time (decreasing speed significantly).

Thus, at the time, the available JSON parsers lacked two things, speed and flexibility. To better understand why flexibility might be needed for something like a file parser, it is first useful to understand the difficulty of mapping JSON to Matlab data types.

## JSON format specificity ##

Consider the following JSON, which you might parse as a 2D array (matrix):

<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;">[
    [<span style="color: #40a070;">1</span>, <span style="color: #40a070;">2</span>, <span style="color: #40a070;">3</span>],
    [<span style="color: #40a070;">4</span>, <span style="color: #40a070;">5</span>, <span style="color: #40a070;">6</span>]
]
</pre>
</div>

Now consider that the next time you read this data you see:

<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;">[
    [<span style="color: #40a070;">1</span>, <span style="color: #40a070;">2</span>, <span style="color: #40a070;">3</span>],
    [<span style="color: #40a070;">0</span>],
    [<span style="color: #40a070;">4</span>, <span style="color: #40a070;">8</span>, <span style="color: #40a070;">9</span>]
]
</pre>
</div>

In this case the data cannot be combined into a matrix, since one of the sub-arrays has only 1 element, whereas the others have 3 elements. Instead this data must be returned as a cell array of arrays. Some JSON parsers might return a matrix in one case, and a cell array in others. This means the user has to do additional checks on what is returned from the parser. Other parsers might be more conservative and always return cell arrays, even if you always expect a matrix. This approach can be slow, as cell arrays are not memory efficient (compared to a matrix), and as indicated above, concatenating them post-hoc, rather than at creation, wastes time.

Ideally the user would be able to acknowledge that variability is possible, and thus to always return a cell array. Alternatively, they may expect a matrix, and thus ask for a matrix to be returned, returning an error when the data are not in matrix form.

Additionally, it is unclear whether or not the data are to be interpreted as row major or column major. JSON doesn't specify since the data are thought of as an array that holds arrays (similar to the cell array of arrays in Matlab). I don't think I saw a single Matlab JSON parser that allowed specifying whether to interpret the arrays using row-major or column-major ordering.

A similar problem exists with objects that may or may not have different properties. For example:

<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;">[{
    <span style="color: #062873; font-weight: bold;">"a"</span>: <span style="color: #40a070;">1</span>,
    <span style="color: #062873; font-weight: bold;">"b"</span>: <span style="color: #40a070;">2</span>
}, {
    <span style="color: #062873; font-weight: bold;">"a"</span>: <span style="color: #40a070;">3</span>,
    <span style="color: #062873; font-weight: bold;">"c"</span>: <span style="color: #40a070;">5</span>
}]
</pre>
</div>

In the above example, the two objects have different properties ("b" vs "c"), and thus, at least in Matlab, they can't share a single concise definition. Thus again the user may be forced to deal with an array of objects (structure array) sometimes and a cell array of structures at other times. Again, ideally the user could specify how they would like the data returned to avoid variability in the output that they are working with.

##  Moving Forward by Tokenizing ##

After looking through the parsers I decided none had the desired combination of speed and flexibility. The first solution that came to mind was to find a fast JSON tokenizer that I could wrap with Matlab code. The specifics of what a tokenizer performs can vary, but it may, for example, identify the starts and stops of all strings (and objects, arrays, etc.) in the JSON file. The idea is that a tokenizer does the heavy lifting, and that some additional code is wrapped around the tokenizer to retrieve the actual data. The tokenizer provides the speed, and the wrapper provides the flexibility.


After a bit of searching, I found a JSON tokenizer called JSMN written in C ([https://github.com/zserge/jsmn](https://github.com/zserge/jsmn)). I wrapped the code with a mex wrapper so that it was accessible from Matlab. Looking more closely at the code I saw one thing that I didn't like and wanted to change. Then I found another. Before I knew it I had thrown out the original code and had something completely different.

## Optimizing a JSON parser ##

In the end I ended up writing a very fast JSON parser that I think still provides good flexibility. This flexibility comes from a two step approach: 1) tokenizing  the JSON string and 2) converting this information into Matlab data structures.

The rest of this post will discuss approaches I used to make the code run fast. Although I would like to eventually quantify the importance of these design decisions, no effort was made to quantify how important these were to code execution time.

Finally before I get started, it is important to qualify the fastness of this parser. When looking at JSON parsers, I saw a lot of references to "fast" JSON parsers. Everything was the fastest. Turtle JSON, my JSON parser, is a pretty fast JSON parser, and is the fastest Matlab parser available (as of January 2018).  I may have gotten carried away with some of the optimizations but in the end it was an enjoyable learning opportunity.

Onto the details!

# Optimization #

## Step 1: State Machines and Jumps ##

It took me a while to realize that the task of parsing JSON can be represented as a state machine. If you see an opening object character '{', then after whitespace you expect either an attribute key - or more specifically the opening quote of the key '"' - or otherwise a closing object character '}'. This line of thinking simplified my mental processing of the parsing dramatically.

In practical terms, this means I started using GOTO statements in my C code. Normally GOTO statements are frowned upon but in this case I think they worked well. The alternative approach is to populate a variable with the next instruction to process and to run an infinite loop with a switch on the next instruction. Put another way, you have a while(1) loop with a switch statement on some character or digit as the instruction to run next. This works, but it is definitely slower. The compiler should, in some cases, optimize this overhead away, but I found that it didn't appear to (although I'm certainly not a compiler expert). This was one of the few things I think I timed at some point and I seem to remember a roughly 15% speed increase.

In some cases there are relatively few states that can occur from a given state. For example, there are only three things to do after opening an object: 1) open a key; 2) close the object; or 3) throw an error. For arrays and keys there are a few more. Here I decided to index into an array of "labels" using the character to parse. This eliminates delays caused by processing logic. No matter what the character, I always do two things: 1) index into the array using the character; and 2) GOTO the address stored at that index. Note this is unfortunately only supported by certain compilers, so at this point I switched from Visual Studio to using TDM-GCC. The setup code looks like this:


<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;">   <span style="color: #007020; font-weight: bold;">const</span> <span style="color: #902000;">void</span> <span style="color: #666666;">*</span>array_jump[<span style="color: #40a070;">256</span>] <span style="color: #666666;">=</span> {
        [<span style="color: #40a070;">0</span> ... <span style="color: #40a070;">33</span>]  <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY,
        [<span style="color: #40a070;">34</span>]        <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_PARSE_STRING_IN_ARRAY,            <span style="color: #60a0b0; font-style: italic;">// "</span>
        [<span style="color: #40a070;">35</span> ... <span style="color: #40a070;">44</span>] <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY,
        [<span style="color: #40a070;">45</span>]        <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_PARSE_NUMBER_IN_ARRAY,            <span style="color: #60a0b0; font-style: italic;">// -</span>
        [<span style="color: #40a070;">46</span> ... <span style="color: #40a070;">47</span>] <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY,
        [<span style="color: #40a070;">48</span> ... <span style="color: #40a070;">57</span>] <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_PARSE_NUMBER_IN_ARRAY,            <span style="color: #60a0b0; font-style: italic;">// #</span>
        [<span style="color: #40a070;">58</span> ... <span style="color: #40a070;">90</span>] <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY,
        [<span style="color: #40a070;">91</span>]        <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_OPEN_ARRAY_IN_ARRAY,              <span style="color: #60a0b0; font-style: italic;">// [</span>
        [<span style="color: #40a070;">92</span> ... <span style="color: #40a070;">101</span>]  <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY,
        [<span style="color: #40a070;">102</span>]         <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_PARSE_FALSE_IN_ARRAY,           <span style="color: #60a0b0; font-style: italic;">// false</span>
        [<span style="color: #40a070;">103</span> ... <span style="color: #40a070;">109</span>] <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY,
        [<span style="color: #40a070;">110</span>]         <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_PARSE_NULL_IN_ARRAY,            <span style="color: #60a0b0; font-style: italic;">// null</span>
        [<span style="color: #40a070;">111</span> ... <span style="color: #40a070;">115</span>] <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY,
        [<span style="color: #40a070;">116</span>]         <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_PARSE_TRUE_IN_ARRAY,            <span style="color: #60a0b0; font-style: italic;">// true</span>
        [<span style="color: #40a070;">117</span> ... <span style="color: #40a070;">122</span>] <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY,
        [<span style="color: #40a070;">123</span>]         <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_OPEN_OBJECT_IN_ARRAY,           <span style="color: #60a0b0; font-style: italic;">// {</span>
        [<span style="color: #40a070;">124</span> ... <span style="color: #40a070;">255</span>] <span style="color: #666666;">=</span> <span style="color: #666666;">&amp;&amp;</span>S_ERROR_TOKEN_AFTER_COMMA_IN_ARRAY};
</pre>
</div>

Here && is used to get the address of the label. The '...' is a nice feature for filling in lots of array values. In my labels the leading 'S' represents "State". You'll note that most of the character options jump into an error state indicating that these characters are invalid given the current processing state of the parser.

The code that uses this table looks like this:

<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;"><span style="color: #007020;">#define DO_ARRAY_JUMP goto *array_jump[CURRENT_CHAR]</span></pre>
</div>

I did not time the impact of this decision and I think this is probably the one design decision that may have had little impact. In particular this "optimization" gets into memory and caching issues which are beyond my grasp. Timing would be ideal, although I really like the way the resulting code looks.

## Step 2: Array or Object? ##

Parsing a primitive value, such as a number or string, does not depend on whether that value is in an array or in an object. However, there is some bookkeeping that needs to be done depending on what is holding the primitive. As a simple example, consider the following invalid JSON:

<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;">[<span style="color: #40a070;">1.2345</span><span style="border: 1px solid #FF0000;">}</span>
</pre>
</div>

I am currently using hilite.me ([http://hilite.me/](http://hilite.me/)) to highlight the code. Even it knows that the closing object character '}' is invalid.

At some point I decided to keep track of whether or not I was parsing something in an array or object. This knowledge let's us know if these closing tags are valid or invalid without checking some other temporary variable. In other words, if my state is parsing a number in an array, then I don't need to check some variable like 'is_object' or 'is_array' to tell me that the '}' character is invalid.

I was worried about doing this at first. Was I over-optimizing? In the end I think it made the code even cleaner and easier to follow. Here's an example of this type of code, for a string:

```
//=============================================================
S_PARSE_STRING_IN_ARRAY:
	INCREMENT_PARENT_SIZE;
    PROCESS_STRING
	PROCESS_END_OF_ARRAY_VALUE;

//=============================================================
S_PARSE_STRING_IN_KEY:
    STORE_NEXT_SIBLING_KEY_SIMPLE;
    PROCESS_STRING;
	PROCESS_END_OF_KEY_VALUE_SIMPLE

```

## Step 3: Parent updates only for complex values ##

This was actually one of the last changes I made. I was trying to improve my speed for a benchmark ([https://github.com/kostya/benchmarks#json](https://github.com/kostya/benchmarks#json)). The benchmark file uses structures/objects to store values. Here is a sample of the test file:

<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;">{
  <span style="color: #062873; font-weight: bold;">"coordinates"</span>: [
    {
      <span style="color: #062873; font-weight: bold;">"x"</span>: <span style="color: #40a070;">0.5405492533441327</span>,
      <span style="color: #062873; font-weight: bold;">"y"</span>: <span style="color: #40a070;">0.1606088575740785</span>,
      <span style="color: #062873; font-weight: bold;">"z"</span>: <span style="color: #40a070;">0.28996148804190514</span>,
      <span style="color: #062873; font-weight: bold;">"name"</span>: <span style="color: #4070a0;">"khfmzc 6328"</span>,
      <span style="color: #062873; font-weight: bold;">"opts"</span>: {
        <span style="color: #062873; font-weight: bold;">"1"</span>: [
          <span style="color: #40a070;">1</span>,
          <span style="color: #007020; font-weight: bold;">true</span>
        ]
      }
    },
    {
      <span style="color: #062873; font-weight: bold;">"x"</span>: <span style="color: #40a070;">0.2032080968709824</span>,
      <span style="color: #062873; font-weight: bold;">"y"</span>: <span style="color: #40a070;">0.46900080253088805</span>,
      <span style="color: #062873; font-weight: bold;">"z"</span>: <span style="color: #40a070;">0.8568254531796844</span>,
      <span style="color: #062873; font-weight: bold;">"name"</span>: <span style="color: #4070a0;">"buxtgk 4779"</span>,
      <span style="color: #062873; font-weight: bold;">"opts"</span>: {
        <span style="color: #062873; font-weight: bold;">"1"</span>: [
          <span style="color: #40a070;">1</span>,
          <span style="color: #007020; font-weight: bold;">true</span>
        ]
      }
    },
</pre>
</div>

When parsing objects or arrays I used a concept of parsing depth. In other words, in this example there is an *object* at depth 1, which holds a "coordinates" *attribute* at depth 2, which holds an *array* at depth 3, which holds an *object* at depth 4, which holds an *attribute* "x" at depth 5. Once I've parsed the object at depth 4, I need to go back to the array at depth 3, so you constantly need to keep track of an objects parents (i.e. the parent of the object at 4 is the array at 3).

The key insight was that we didn't care about managing parent information if we had an object attribute whose value was primitive (i.e., string, number, or logical), since after we parsed the primitive value we'd be immediately back at the object level. If however an attribute held an object or an array, then we needed to keep track of these parent relationships a bit more closely. Implementing this distinction of simple versus complex object values meant I could avoid a lot of extra bookkeeping.

To allow ourselves not to care about these primitive values, we hold off on updating depth and parents until we start parsing the value that the key holds, rather than when parsing the key string. This places extra work on parsing values in "objects" (really in the key of an object), but it speeds things up nicely. This is the opening part of the depth code that is now completely avoided when parsing primitives (as values in objects):

<div style="background: #f0f0f0; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;"><span style="color: #007020;">#define INITIALIZE_PARENT_INFO(x) \</span>
<span style="color: #007020;">        ++current_depth; \</span>
<span style="color: #007020;">        if (current_depth &gt; 200){\</span>
<span style="color: #007020;">            goto S_ERROR_DEPTH_EXCEEDED; \</span>
<span style="color: #007020;">        }\</span>
<span style="color: #007020;">        parent_types[current_depth] = x; \</span>
<span style="color: #007020;">        parent_indices[current_depth] = current_data_index; \</span>
<span style="color: #007020;">        parent_sizes[current_depth] = 0;</span>
</pre>
</div>

This isn't the fanciest optimization but I really like it. It is an example of optimizing code by removing unnecessary logic. Ideally the compiler could do this as well but my experience has been that it often does not.

## Step 4: SIMD (Single Instruction, Multiple Data) - Parallelization via the Instruction Set ##

This idea came from [RapidJSON](http://rapidjson.org/) which is frequently held up as one of the fastest JSON parsers out there. The idea is that there exists a set of special instructions in the processor that can be used to execute a single instruction simultaneously on multiple elements of a data array (thus the SIMD term, single instruction multiple data). One danger of using these instructions is that they are processor dependent and you can run into problems transferring compiled code between computers. I'm currently only using one SIMD instruction, _mm_cmpistri(), which is part of what's known as the [SSE4.2 set of instructions](https://en.wikipedia.org/wiki/SSE4) which were made available in Intel processors in 2008 and AMD processors in 2011.

The use case suggested by RapidJSON is to skip whitespace. In particular, this is really handy if you need to skip whitespace in files with lots of indentation (i.e. for pretty-printed JSON). The parallel nature of the code comes in comparing a set of characters in your file to a specific set of characters, in this case, whitespace characters (spaces, tabs, newlines, carriage returns). The tricky part is that this function takes multiple cycles (although less if you were to implement it as standard code), and thus you want to try and call it only when you think you are going to skip a lot of whitespace.

This code in C is as follows:

```
//Hex of 9,     10,     13,     32
//      htab    \n      \r     space
#define INIT_LOCAL_WS_CHARS \
    const __m128i whitespace_characters = _mm_set1_epi32(0x090A0D20);

//We are trying to get to the next non-whitespace character as fast as possible
//Ideally, there are 0 or 1 whitespace characters to the next value
//
//With human-readable JSON code there may be many spaces for indentation
//e.g.    
//          {
//                   "key1":1,
//                   "key2":2,
// -- whitespace --  "key3":3, etc.
//
#define ADVANCE_TO_NON_WHITESPACE_CHAR  \
    /* Ideally, we want to quit early with a space, and then no-whitespace */ \
    if (*(++p) == ' '){ \
        ++p; \
    } \
    /* All whitespace are less than or equal to the space character (32) */ \
    if (*p <= ' '){ \
        chars_to_search_for_ws = _mm_loadu_si128((__m128i*)p); \
        ws_search_result = _mm_cmpistri(whitespace_characters, chars_to_search_for_ws, SIMD_SEARCH_MODE); \
        p += ws_search_result; \
        if (ws_search_result == 16) { \
            while (ws_search_result == 16){ \
                chars_to_search_for_ws = _mm_loadu_si128((__m128i*)p); \
                ws_search_result = _mm_cmpistri(whitespace_characters, chars_to_search_for_ws, SIMD_SEARCH_MODE); \
                p += ws_search_result; \
            } \
        } \
    } \
```

Note that we first try and match a space and then we also check if the next character could be a whitespace (the whitespace characters are all less than or equal to ' ') before calling the SIMD code.

I had a hard time understanding SIMD, and the "cmpistri" (compare implicit length strings return index) function in particular is very complex, with its functionality varying considerably based on the flags that are passed in. After some help on StackOverflow ([http://stackoverflow.com/questions/37266851/trouble-with-result-from-mm-cmpestri-in-c](http://stackoverflow.com/questions/37266851/trouble-with-result-from-mm-cmpestri-in-c)) I was able to get things working.

I also decided to use the same function to parse numbers. The reason for doing this, i.e. for skipping over numbers, is explained in the next section.

## Step 5: Parallelization via Multiple Cores ##

In the previous section I discussed parallelization on a single core using special processor instructions. In this section I expand the parallelization to multiple cores.

I spent a decent amount of time trying to think if I could parse the entire JSON file in parallel. Although I had concocted some ideas on how it might work, I decided against it for now.

However, I am able to parse parts of it in parallel. Specifically, I decided to search to the end of numbers and strings, and then to parse them properly later. This post-processing can easily be done in parallel. Since I was skipping over the numbers initially and parsing them later, I added similar SIMD code to advance to the end of the number by looking for digits (and other numeric characters).

I decided not to use SIMD for finding the end of a string because it can be slower for short strings. In general I wanted the parser to be fast for parsing relatively large numbers (6+ digits), but I have no such size expectations for strings. For strings I am currently just using a loop and looking for the end of the string.  I log the start and end indices of the string to go back later and parse it. The string "parsing" consists of handling any escape sequences as well as converting UTF-8 to UTF-16 (what Matlab uses for character arrays).

I decided to use the [OPENMP library](https://en.wikipedia.org/wiki/OpenMP) for doing the post-processing of numbers and strings (unicode and escape character handling). This made writing parallel code extremely easy. Here is the parallel code that parses numbers. Simply by adding the pragma statement iterations of this loop get split amongst all available cores/threads. On my 5 year old desktop, and on my 3 year old laptop, this is 2 cores (4 threads, hyperthreads?), which should be a decent speedup for number (and string) parsing. I should mention in general I'm assuming most machines have two cores (or more) and that in general it is faster to use this two step approach (skip/log first then process later) rather than doing processing right away using a single thread.

<div style="background: #ffffff; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;">  #pragma omp parallel
    {
        <span style="color: #333399; font-weight: bold;">int</span> tid <span style="color: #333333;">=</span> omp_get_thread_num();
        <span style="color: #333399; font-weight: bold;">int</span> error_location <span style="color: #333333;">=</span> <span style="color: #0000dd; font-weight: bold;">0</span>;
        <span style="color: #333399; font-weight: bold;">int</span> error_value;

        #pragma omp for
        <span style="color: #008800; font-weight: bold;">for</span> (<span style="color: #333399; font-weight: bold;">int</span> i <span style="color: #333333;">=</span> <span style="color: #0000dd; font-weight: bold;">0</span>; i <span style="color: #333333;">&lt;</span> n_numbers; i<span style="color: #333333;">++</span>){
            <span style="color: #888888;">//NaN values occupy an index space in numeric_p but have a null</span>
            <span style="color: #888888;">//value to indicate that they are NaN</span>
            <span style="color: #008800; font-weight: bold;">if</span> (numeric_p[i]){
                string_to_double_v3(<span style="color: #333333;">&amp;</span>numeric_p_double[i],numeric_p[i],i,<span style="color: #333333;">&amp;</span>error_location,<span style="color: #333333;">&amp;</span>error_value);
            }<span style="color: #008800; font-weight: bold;">else</span>{
                numeric_p_double[i] <span style="color: #333333;">=</span> MX_NAN;
            }
        }  
        
        <span style="color: #333333;">*</span>(error_locations <span style="color: #333333;">+</span> tid) <span style="color: #333333;">=</span> error_location;
        <span style="color: #333333;">*</span>(error_values <span style="color: #333333;">+</span> tid) <span style="color: #333333;">=</span> error_value;
    }
</pre>
</div>

Briefly, one clarification on the code above. My code throws errors when parsing, rather than passing out an error value to the caller. However Matlab states that no Matlab based calls, like mexErrMsgIdAndTxt() which is used to throw errors, should be used in parallel code. Thus, each thread keeps track of its own errors, and these are later combined.

## Step 6: String End Searching and End of File Handling ##

If we are searching for the end of a string to post-process later, then we need to find a terminating double-quote character. However, we also need to be careful of escapes that escape a double-quote, as well as the end of the file. Since we are skipping over the string (i.e. not parsing it immediately, see Step 5) we are focused on finding a double-quote character '"'. Once this has been encountered we can backtrack relatively easily to determine if the character indicates the end of the string, or if it has been escaped to indicate that the double-quote character is a part of the string itself.

In addition we also need to verify that the file doesn't end prematurely, and that the double-quote character hasn't been escaped (indicating that we need to continue parsing the string).

When reading from files, it is trivial to pad the read buffer with extra characters that are helpful to parsing. The same is currently done for strings (as an input), although unfortunately this requires memory reallocation. The question then is how many additional bytes to add, and what to put in them, and why.

I found the following buffer to be useful:

[0 '\' '"' 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

By including a '"', we ensure that we never read past the end of the JSON stream. An alternative and slower approach is to examine every character for both '"' and 0.

Since we are not looking for escaped characters initially, every time we encounter '"' we need to verify that it is the end of the string, and not a part of the string. This means that we need to look at the previous character and ensure that we don't see a '\' character.

By placing the '\' character between a null character and our '"' character, we do double-duty by checking for our escape character and entertaining the possibility of having encountered our sentinel '"' character. The alternative and slower approach is to have [0 '"'], and then check for both 0 and '\' every time we encounter a '"' character.

Finally, by adding sufficient characters to our buffer we ensure that we never read past the end of the stream when using SIMD.

<div style="background: #ffffff; border-width: 0.1em 0.1em 0.1em 0.8em; border: solid gray; overflow: auto; padding: 0.2em 0.6em; width: auto;">
<pre style="line-height: 125%; margin: 0;"><span style="color: #997700; font-weight: bold;">STRING_SEEK:</span>    

    <span style="color: #008800; font-weight: bold;">while</span> (<span style="color: #333333;">*</span>p <span style="color: #333333;">!=</span> <span style="color: #0044dd;">'"'</span>){
      <span style="color: #333333;">++</span>p;    
    }
    
    <span style="color: #888888;">//Back up to verify that we aren't escaped</span>
    <span style="color: #008800; font-weight: bold;">if</span> (<span style="color: #333333;">*</span>(<span style="color: #333333;">--</span>p) <span style="color: #333333;">==</span> <span style="color: #0044dd;">'\\'</span>){
        <span style="color: #888888;">//See documentation on the buffer we've added to the string</span>
        <span style="color: #008800; font-weight: bold;">if</span> (<span style="color: #333333;">*</span>(<span style="color: #333333;">--</span>p) <span style="color: #333333;">==</span> <span style="color: #0000dd; font-weight: bold;">0</span>){
            mexErrMsgIdAndTxt(<span style="background-color: #fff0f0;">"turtle_json:unterminated_string"</span>, 
                    <span style="background-color: #fff0f0;">"JSON string is not terminated with a double-quote character"</span>);
        }
        <span style="color: #888888;">//At this point, we either have a true end of the string, or we've</span>
        <span style="color: #888888;">//escaped the escape character</span>
        <span style="color: #888888;">//</span>
        <span style="color: #888888;">//for example:</span>
        <span style="color: #888888;">//1) "this is a test\"    =&gt; so we need to keep going</span>
        <span style="color: #888888;">//2) "testing\\"          =&gt; all done</span>
        <span style="color: #888888;">//</span>
        <span style="color: #888888;">//This of course could keep going ... \\\\"</span>
</pre>
</div>

I rewrote this section multiple times to try and keep this simple. At the end of the day the main message is as follows, by using the buffer we chose we can avoid a lot of unnecessary checks on every character on a string, while also making sure we catch errors and properly handle escaped double-quote characters.

## How to go Faster ##

Here are some additional things that could make this code go faster, as well as some general comments on speed.

1. Everything is parsed, even if you only want a part of the file. This isn't too tough for compiled code but I think it would be basically impossible to use effectively with a mix of compiled and interpreted code.
2. This parser is generic. One alternative is to use code that generates code for parsing a specific JSON file (e.g, [https://google.github.io/flatbuffers/](https://google.github.io/flatbuffers/)). 
3. I'm working with Matlab memory management which slows things down considerably. Here's the time to parse "1.json", a file that is used to do speed testing ([https://github.com/kostya/benchmarks#json](https://github.com/kostya/benchmarks#json)] - into tokens. It takes 558 ms to process the file on my desktop, of which 170 ms is from string allocation time. Ideally with strings you would only need to return a pointer (C,C++) to the start of the sub-string located in the larger file string (so called in-situ processing). This avoids a lot of memory allocation work but doesn't work so well for returning strings to users in Matlab.

    ```   
             elapsed_read_time: 0.1210 
            elapsed_parse_time: 0.2500 
               elapsed_pp_time: 0.3080 
          %---- Post Processing ------
           object_parsing_time: 0.0780 
            array_parsing_time: 0.0200 
           number_parsing_time: 0.0200 %OpenMP
 string_memory_allocation_time: 0.1700
           string_parsing_time: 0.0200 %OpenMP
          %------------------------------ 
        total_elapsed_time_mex: 0.6790
                 non_read_time: 0.5580       
    ```
    
4. To assist with later processing I determine if objects are homogenous (object_parsing_time). I also determine if arrays are homogenous (all numeric, all strings, all logical) and their type (e.g. 1d array, 2d array, jagged array, etc.) (array_parsing_time). Neither of these have been parallelized, even though it should be possible to do so.

5. Finally there is at least one optimization related to converting the tokenized data to Matlab data types. For the previously referenced benchmark test, the "opts" object is actually the same for all entries and contains the values 1 and true. Using mex code it is possible to simply increment a reference count every time the value is the same, rather than creating a new data type in memory (new mxArray). This should be easiest for scalar true/false values, and is something I believe Python does for standard scalar numbers as well (as tested with the id() function). This optimization has yet to be completed.

# Concluding Thoughts #

Even though I could make the code slightly faster, I'm ready to move on. At this point the parser is useable (i.e. it doesn't take 10s of seconds to load a 75 MB file). On my 2016 1.1 GHz m3 Macbook that 75 MB file parses in about 0.7 seconds (versus 0.73s for the mat file). On my i5-3570 3.4 GHz processor (released in Quarter 2 of 2012) it takes only 0.3 seconds, which is actually faster than the 0.55s it takes to read in the same data as a mat file (using '-v6').

I'm not entirely convinced of the utility of using JSON for scientific data exchange, especially compared to HDF5. Perhaps it allows easier editing of meta-data, but it requires a lot of extra processing to parse. The one feature that I think is really missing from this parser is the ability to work with schemas. Without schemas, there can be a lot of extra work on the user's end to verify that the data are delivered as expected.






