July 4, 2020

# How This Blog Works #

This blog is a place where I can highlight some of the code I've written or discuss other topics of interest. I try and keep it limited to things that I can speak about somewhat authoritatively or uniquely on. 

This blog is generally written in one of two related situations. First, while watching my kids play which currently requires my supervision and it is difficult to work on other things. Second, while helping my kids fall asleep by keeping monsters at bay. In both cases I can get a bit distracted ...

## Providing Feedback ##

Currently the website does not support direct feedback. Instead, I welcome feedback/comments either via:
- my gmail: jim.hokanson
- via GitHub Issues: [https://github.com/JimHokanson/blog](https://github.com/JimHokanson/blog)

## Hosting and Setup ##

This blog is written using markdown and hosted on GitHub at [https://github.com/JimHokanson/blog](https://github.com/JimHokanson/blog). I use GitHub Pages to "publish" the content so that it has more of a website feel. When I save my content on GitHub, GitHub automatically updates a website based on the changes I've made. The website link is [https://jimhokanson.github.io/blog/](https://jimhokanson.github.io/blog/). I was fortunate to still be able to purchase my domain name (via GoDaddy, although I probably would use someone different if I could do it again) so that now instead of going to **jimhokanson.github.io** you can go to **jimhokanson.com**.

GitHub Pages uses a program called [Jeykll](https://jekyllrb.com/) to transform the markdown documents to a static website. For those wondering what static means, it helps to first define the opposite of a static website, a dynamic website. When visiting a dynamic website a computer somewhere runs a bunch of code to produce the page, such as querying a database or merging various pieces of information into the page that you ultimately see. This is done on demand when you ask for the web page. A static website however produces the page ahead of time and gives everyone the same page. It's sort of like if you go to a pizza place and they have ready to go pizzas (static) or you can ask them for a custom pizza that they then need to make (dynamic). Static sites have a lot of advantages over dynamic sites and there are a lot of programs that have been created in the past few years that focus on producing static webpages (and static websites more generally) from a set of files.

Anyway, I've looked at Jeykll before and I think it is a lot of work to get it working. Technically you can get started pretty easily but I think it is pretty easy to spend days or weeks tweaking things to get your website to look and behave like you want. I have enough other things to do rather than focusing on web design, so I wanted to keep my Jekyll customization to an absolute minimum.

So, my GitHub Pages site is basically the default conversion process (from markdown to html) with only about 5 minutes worth of changes. First, I changed the default layout so that I could have header links at the top of each page. The changes can be seen [here](https://github.com/JimHokanson/blog/blob/master/_layouts/default.html). 

Unfortunately, this changed the theme from the default to something else. At the time I was doing this, the default theme wasn't a choice in GitHub's web interface, so I asked this [question on SO](https://stackoverflow.com/questions/59636030/modifying-the-default-github-pages-layout). The fix ended up being a one line change in another [file](https://github.com/JimHokanson/blog/blob/master/_config.yml).

Finally, I recently wrote a post that involved a bit of math. To render this I made another change to my default layout file so that it would load a math rendering library.

Those are the only 3 changes I've made (to 2 files). In contrast you  easily find starter Jeykll/Github Pages websites that you can copy (fork) on GitHub that contain many 10s of files. I didn't want to learn a whole other library, so I'm sticking with my current setup. 

## Limitations ##

This setup does have its limitations that one day I may try and address. These include:
- lack of RSS or notification when new articles are published
- lack of blog organization by tag or publish-by-date
- lack of a direct feedback mechanism

## Advantages ##

- entire site is kept locally on my machine as a git repository
- there is minimal lock-in to a vendor, and I could go elsewhere relatively easily
- the process works for me and the setup doesn't get in my way when writing  