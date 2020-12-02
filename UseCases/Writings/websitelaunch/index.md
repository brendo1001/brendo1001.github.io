---
layout: page
title: Create and launch a website
description: "My own original content"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-04-27
---

I have always had some interest or wonder into what and how websites are powered. Like where is all this content stored? And how is it all organised? Only recently these questions were more-or-less answered for me. This blog provides a pipeline of work to create, set up and deploy a functional website.


This was when i undertook a short course on [codecademy](https://www.codecademy.com/learn). It was definitely worth my while. 

So these are just some pointers that i found entirely useful for helping me develop and deploy a website on to the internet. As you can see, this website you are using is the outcome of my learning about this to date. It is by no means a finished product either. 


There are 3 main steps to achieve these ends. 

1. Generate a static site
2. Deploy the site to the Internet
3. Give the website a custom domain name (optional step).

I will just give a rather brief outline of these main steps but be aware that there are many little bumps and bungles to be encountered along the way as developing your own website will introduce you to problems specific to your use case. I have found though that a little intuition and iteration are the best means of finding the way through the issues that crop up. I have found that making a website is actually very fiddly and demands a lot of your time. I would not really describe myself as a computer literate either. More of a hack, but cobbling a few bits and pieces together of other peoples contributions has actually been the way i have floundered through to a result (a working website) that is mine and has my name all over it. It has my own personal brand, and that is what i wanted to achieve. I learned a lot in this process, so lets just get down to business.



## 1. Creating a Website
-----


Jekyll i have found is a really cool tool to quickly generate a website. Jekyll is a simple static site generator. Using Jekyll is a very common way of generating a "ready-to-publish static website" within seconds. You can learn more about [Jekyll](https://jekyllrb.com/) here.

This post just demonstrates the process of using Jekyll to generate a static website quickly then focus on deploying it. You could use any sort of content you wish however and still follow the steps of deployment covered later on. Just make sure that your HTML is inside of a file called index.html. You can go ahead and create your own static site from scratch, but that is not for me. I am just going to do something simple, but bear in mind there is a vast array of [Jekyll Themes](http://jekyllthemes.org/) to tickle anyone's fancy. The use of Github here is necessary though, as you can just select the theme of your choice, clone it onto your computer, then begin filling it with your own content.


One catch is that Windows is not an officially supported platform for Jekyll. Consequently everything i do from here using Jekyll was development on Ubuntu 16.04. Before you install Jekyll, what you are going to need first is to install Ruby. More info on how to do this can be found at [brightbox](https://www.brightbox.com/docs/ruby/ubuntu/). There maybe a few other software to install as well, so after you install Ruby you can then check out the [Jekyll install instructions](https://jekyllrb.com/docs/installation/). Further helpful links for installing other possible denpendencies can be found [here](https://stackoverflow.com/questions/32459990/unable-to-install-json-1-8-3-in-ruby-2-2-1?lq=1). You will note from all these addtional resources and help that getting Ruby and Jekyll installed can be tedious and varies on a use by use basis. Then in your terminal you can do:


```r
$ sudo gem install jekyll
```

With Jekyll now installed we use Jekyll's new command and specify a directory name. The directory will contain all of your site's default content that can be customized later. For example, to generate a website in a directory called my-own-site, we can type:
 
```r
$ jekyll new my-own-site
```

You can use Jekyll to view your site locally. On the web, a server hosts your site's files and makes your website available for everyone to see. However, viewing a website locally means that you're viewing the site on your own computer (hence the term "locally" or "local"). The site is not, however, available on the public Internet. Instead, your computer is acting as the server that hosts your site. You can view your site locally by using Jekyll's serve command, like so:

```r
$ jekyll serve
```
This command starts a local server that will server the files to your computer. The serve command will also come in handy when you want to preview changes you make to your site.

The website that Jekyll generates offers a standard directory structure, as well as components that help speed up development. It's important to understand Jekyll's default directory structure and contents of your site. [See here](https://jekyllrb.com/docs/structure/) for more details.  

## 2. Deploy Website
-----

There are many different ways to deploy a website to the public Internet. One of them uses GitHub Pages to deploy your website. GitHub Pages is a service offered by [GitHub](https://github.com/). Specifically, GitHub Pages are public webpages that are hosted and published through GitHub. GitHub Pages offers extensive integration and support for Jekyll. By using both, we can benefit from:

* Easy setup
* Troubleshooting your site
* Updating and maintaining your site

Obviously one caveat to successfully deploy your site, is that you will need a GitHub account.

In order to publish your site using GitHub Pages, you'll need to create a repository (repo) on GitHub. A GitHub repository is an online, central storage place where you can store files and all the versions of those files. We'll use the repo create just before to store the contents of the basic website. A repo's name must also follow GitHub Pages' naming convention, otherwise the site will not publish at all. Specifically, the repo's name must be in the following format:

```r
your-user-name.github.io
```

In the example above, you would replace your-user-name with your actual GitHub user name. Now we can upload the site that that was created (`new my-own-site`) to GitHub. We'll use Git to push (upload) the contents of your site's directory to your new repo. To do so, we'll first initialize a Git repository in the site's directory. First, use the `cd` command to navigate to the site's directory. Once inside the `new my-own-site` directory, initialize a Git repository with the following command:

```r
$ git init
```

Next, Git needs to know what repo will store your site's content. In this case, the repo will be the one you created on GitHub earlier. To specify the repo using Git, we'll have to add the remote and label it as the origin.

The remote is the URL of the repo that will store your site's contents. The origin is an alias for the remote. You can think of an alias as an abbreviation or a substitute name. This means that instead of having to always type the lengthy remote URL over and over again, you can simply refer to it as origin later on. In the terminal, you can add the remote with the following command:

```r
$ git remote add origin https://github.com/your-user-name/your-user-name.github.io.git
```

Git also needs to know exactly which files should be pushed to your repo. In this case, we want to push all of your site's content to the repo. This means we will do the following two things (in order):

1. Add all of your site's content to the Git staging area

```r
$ git add .
```

2. Save your changes using Git's commit command and the following commit message:

```r
$ git commit -m "Save my work"
```

We now use Git to help deploy the site. This time, we'll use Git's push command and push the contents of your site up to the repo using the following command:

```r
$ git push -u origin master
```

The site will now be published on the public Internet. You can now navigate to your newly published website in your preferred browser. The URL for your GitHub Pages site is: 

```r
your-user-name.github.io
```

where your-user-name is your actual GitHub username.


## 2. Give the website a custom domain name
-----

By now we have deployed the site and GitHub Pages has assigned it a default URL, or domain name. The next step is to purchase your own custom domain name and assign it to your GitHub Pages website. This will result in you being able to access your site using both your new domain name and your default GitHub Pages domain name.

Before you choose a custom domain name, it's important to first understand what domain names actually are. Domain names are human-friendly names that identify servers on the Internet. A global system known as the Domain Name System (DNS) is used for storing which domain names correspond to which servers. For example, Github's's domain name is `https://github.com`. When you type the domain name into your browser, your computer asks the DNS to identify which servers should receive the request in order to load the website.

**Note:** This part of website deployment is optional. Nevertheless, you can follow through the steps required to purchase a custom domain name and assign it to your GitHub Pages site. From my own experience a custom domain name costs about $15 AUS. 

Often, the most time consuming part of buying a domain name is actually deciding what you'd like it to be. Be aware that not all domain names are available; many have already been claimed by others. Here we are going to use Amazon Web Services (AWS) to purchase your custom domain. [AWS](https://aws.amazon.com/) is an industry standard suite of web infrastructure services used frequently by developers. The specific service we're going to use to purchase your domain name is called `Route 53`. To begin the process you will need to establish an account with AWS if you do not have one already. Creating an AWS account is free - there are no required purchases. The only purchase that you'll (optionally) make will be the purchase of your custom domain name.

**Important Instructions**
After logging into your account, you'll land on the AWS console. The console displays the many different services. Here we are going to focus on a service called "Route 53," under the "Networking" category. Route 53 can be used to purchase domain names and create DNS records. Once in here, click on the "Get Started Now" button under the "Domain Registration" section. On the next page, locate the two buttons at the top of the page. Click on the button titled "Register Domain".

Now it's time to select a domain name and make sure it's available. Route 53 allows you to search the availability of a domain name you have in mind. It also offers many suffixes, like `.com`, `.io`, `.me`, and `.soil`. If the domain name you want is unavailable as a `.com` for example, you can try using a different suffix. The suffixes of domain names are known as top-level domains (TLDs). Different TLDs cost different annual prices.

**Note:** `.com` domains are the most popular and are therefore generally unavailable (or expensive).


With your new domain name established,you might notice that it doesn't work yet - you can't visit it in your web browser. We have to connect it to your GitHub Pages website first. There are two steps required:

1. Inform GitHub of the new domain name we'll be using (the one you purchased)
2. Set up DNS records in Route 53 that direct to GitHub

To perform these steps, open GitHub and access the repo you created earlier titled `your-user-name.github.io`. Click the "New file" button. Name the new file `CNAME`. Do not add a file name extension. In the file, on line 1, type the custom domain name you just purchased in the following format: `yourcustomdomain.com`. You may have purchased a domain name with a TLD other than .com. In that case, make sure to use that TLD when creating the `CNAME` file. Commit the new file. Under the title of the repo, click on "Settings." Scroll down to the section titled "GitHub Pages" and confirm that there is a message similar to the following: Your site is published at `http://yourcustomdomain.com`. Try navigating to your website in your browser using your new domain name. It still doesn't work! Time to move onto the next step.

The new `CNAME` file in your repo informs GitHub that you're assigning a new custom domain name to your GitHub Pages site. What we do now is let the rest of the Internet know that we want to associate the custom domain name with your GitHub Pages site. We can do this by creating DNS records, which are globally accessible records that map domain names to servers. The DNS records are created inside of a Hosted Zone in Route 53. A Hosted Zone is essentially a group of DNS records for a single domain.

**Important Instructions**
In your AWS account Access Route 53 again. On the left side of the page, click on the title that says "Hosted Zones." Notice that you have a Hosted Zone for your new domain name. Click on it to open it.

Domain names are associated with the correct DNS records by setting the domain name's name servers. After a domain name is typed into a browser, the computer first retrieves the name servers that correspond to that domain name. The name servers are important because they're responsible with providing the computer with other important information (in the form of DNS records) associated with the domain name. Setting your domain's name servers is important. The DNS is a global system, which means that anyone can create DNS records. We must verify that the DNS records we create were actually created by the owner of the domain name (in this case, you). By doing this, the owner of a domain name ensures that only they have exclusive control over their domain's DNS records.

Notice that the Hosted Zone for your domain name already has an `NS (Name server)` record. This record contains four values. These are the Hosted Zone's unique name servers. Take note of these values and copy them down somewhere. On the left hand side, under "Domains," click on "Registered domains." Then, click on your domain name. On the right hand side of the page, locate the section titled "Name Servers." Notice that these are the same name servers that your Hosted Zone's `NS` record contained. Route 53 did this for you automatically.

Now that your domain name is associated with the correct name servers, it's time to create some additional DNS records within the Hosted Zone. The records that we'll create will be used by the name servers to help locate your site when a computer wants to load it. Specifically, the name servers will be responsible for providing that computer with important information stored in the records.

There are several different types of DNS records. We're going to start by creating an `A` record, which stands for Address record. An `A` record directs a domain name to an IP address. This record will associate our new custom domain name with Github's servers.

**Important Instructions**
Inside of your Hosted Zone, click on the button at the top labeled "Create Record Set." A form will appear to the right. Leave the "Name:" field blank. Set the "Type:" field to A - IPv4 address.
Leave the "TTL (Seconds)" value at the default of 300. In the "Value" text box, enter the following IP addresses (keep them on separate lines and note that these IP addresses were only from the orginals ones listed from about 2018): 

```r
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```
These IP addresses belong to GitHub. We are specifying that when your custom domain name is requested, the DNS should direct the request to GitHub. Read more information about this [here](https://help.github.com/articles/setting-up-an-apex-domain/#configuring-a-records-with-your-dns-provider). Click the "Save Record Set" button at the bottom of the form.

When setting up a website, it's also conventional to also set up a `www` subdomain. `www` stands for `world wide web`. Subdomains are part of a main (or root) domain. For example, `www.yourcustomdomain.com` is a subdomain of the `yourcustomdomain.com` root domain. We can set up a subdomain using a `CNAME` record, which stands for Canonical Name. A `CNAME` record specifies that a domain name will be used as an alias, or substitute, for the true (canonical) domain name.


**Important Instructions**
Inside of your Hosted Zone, click on the button at the top labeled "Create Record Set". A form will appear to the right. In the "Name:" field, enter only `www`. Set the "Type: " field to `CNAME - Canonical name`. This step sets up the subdomain. In the `Value` text box, enter the domain name that GitHub assigned to you earlier (the canonical domain name:

```r
your-user-name.github.io
```

Click the "Save Record Set" button at the bottom of the form.


W have now created two DNS records: an `A` record for `yourcustomdomain.com` and a `CNAME` record for `www.yourcustomdomain.com`. Let's make sure they both work.

**Important Instructions**
Try opening your website using your root domain in the web browser. You should see your new GitHub Pages site. Try opening your website using your `www` subdomain in the web browser. You should see your new GitHub Pages site.

Success! The website should now display in the browser when you navigate to your custom domain name.


### Final Points

1. We have used Jekyll to create a static website, then used Github pages to host it on the internet. We then set up a custom domain so that the website can be widely seen on the Internet.

2. There is much to learn in terms of building content for your website. You should also look into the many Jekyll content templates that are available.

3. I find building Jekyll website content to be relatively easy as you only have to learn Markdown. Jekyll does the amazing job of converting it all in html. I have found though that even with this efficiency, building content can take an age. 

4. The `jekyll serve` command is super useful. You can make changes and quickly check the result by deploying the site locally.



