---
layout: post
title: Website Launch
author: Brendan Malone
create: 2016-11-17
modified: 2016-11-17
image:
    feature: images/beebop_home.jpg
categories: [Computers, Hacking]
tags: [Website, Markdown, Hackathon, Open Source]
---

I have always had some interest or wonder into what and how websites are powered. Like where is all this content stored? And how is it all organised? Only recently these questions were more-or-less answered for me.

<!--more-->


This was when i undertook a short course on [codecademy](https://www.codecademy.com/learn). It was definetly worth my while. 

So these are just some pointers that i found entirely useful for helping me develop and deploy a website on to the internet. As you can see, this website you are using is the outcome of my learning about this to date. It is by no means a finished product either. 


There are 3 main steps to achieve these ends. 

1. Generate a static site
2. Deploy the site to the Internet
3. Give the website a custom domain name (optional step).

I will just give a rather brief outline of these main steps but be aware that there are many little bumps and bungles to be encountered along the way as developing your own website will introduce you to problems specific to your use case. I have found though that a little intuition and iteration are to best means of finding the way through the issues that crop up. I have found that making a website is actually very fiddly and demands a lot of your time. I would not really describe myself as a computer literate either. More of a hack, but cobbling a few bits and pieces together of other peoples contributions has actually been the way i have floundered through to a result (a working website) that is mine and has my name all over it. It has my own personal brand, and thats what i wanted to achieve. I learned a lot in this process, so lets just get down to business.



## 1. Creating a Website
-----

Jekyll i have found is a really cool tool to quickly generate a website. Jekyll is a simple static site generator. Using Jekyll is a very common way of generating a "ready-to-publish static website" within seconds. You can learn more about [Jekyll](https://jekyllrb.com/) here.

This post just demonstrates the process of using Jekyll to generate a static website quickly then focus on deploying it. You could use any sort of content you wish however and still follow the steps of deployment covered later — just make sure that your HTML is inside of a file called index.html. You can go ahead and create your own static site from scratch, but thats not for me. I am just going to do something simple, but bear in mind there is a vast array of [Jekyll Themes](http://jekyllthemes.org/) to tickle anyones fancy. The use of Github here is necessary though, as you can just select to theme of your choice, clone it onto your computer, then begin filling it with your own content.

One catch is that Windows is not an offically supported platform for Jekyll. Consequently everything i do from here using Jekyll was development on Ubuntu 16.04. Before you install Jekyll, what you are going to need first is to install Ruby. More info on how to do this can be found at [brightbox](https://www.brightbox.com/docs/ruby/ubuntu/). There maybe a few other software to install as well, so after you install Ruby you can then check out the [Jekyll install instructions](https://jekyllrb.com/docs/installation/). Then in your terminal you can do:

```r
$ sudo gem install jekyll
```


 








End

