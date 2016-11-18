---
layout: page
title: Publications
description: A list of my publications.
header-img: images/beebop_home.jpg
comments: false
modified: 2016-11-16
---


## Book
-----

<div class='panel-pub'>
<ol>
{% for article in site.data.book %}
    <li>
    <div class="title">
    <span class="title">{{ article.title }}</span>
    </div>
    <div class='author'>
    {% for author in article.author %}
        <span class='{{ author.role }}'>{{ author.family }}, {{ author.given_initial }}{% if author.role contains 'corr' %}*{% endif %}; </span>
    {% endfor %}
    </div>
    <div class="pubinfo">
    <span class="publisher">{{ article.publisher }}, </span><span class="city">{{ article.city }}, </span><span class="year">{{ article.year }}, </span> Pages: <span class="page">{{ article.page }}. </span>
    </div>
    <div class="url">
        <a href="{{ article.URL }}">{{ article.URL }}</a>
    </div>
    </li>
{% endfor %}
</ol>
</div>


## Journal Articles
-----

<div class='panel-pub'>
<ol>
{% for article in site.data.journal %}
    <li>
    <div class="title">
    <span class="title">{{ article.title }}</span>
    {% if article.fulltext %}
        <a title="fulltext" href="{{ site.url }}/downloads/journal/{{ article.fulltext }}"><i class="fa fa-file-pdf-o"></i></a>
    {% endif %}
    </div>
    <div class='author'>
    {% for author in article.author %}
        <span class='{{ author.role }}'>{{ author.family }}, {{ author.given_initial }}{% if author.role contains 'corr' %}*{% endif %}; </span>
    {% endfor %}
    </div>
    <div class="pubinfo">
    <span class="source">{{ article.journal.abbreviation }} </span><span class="year">{{ article.year }}, </span><span class="volume">{{ article.volume }}, </span><span class="page">{{ article.page }}.</span>{% if article.language != 'english' %}<span class="language"> (In {{ article.language }})</span>{% endif %}
    </div>
    <div class="url">
        <a href="{{ article.URL }}">{{ article.URL }}</a>
    </div>
    <div class="comment">
    Comments:  <span class="comment">{{ article.comment}}</span>
    </div>
    </li>
{% endfor %}
</ol>
</div>


## Book Chapter
-----

<div class='panel-pub'>
<ol>
{% for bookchap in site.data.bookchap %}
    <li>
    <div class="title">
    <span class="title">{{ bookchap.title }}</span>
    {% if bookchap.fulltext %}
        <a title="fulltext" href="{{ site.url }}/downloads/bookchap/{{ bookchap.fulltext }}"><i class="fa fa-file-pdf-o"></i></a>
    {% endif %}
    </div>
    <div class='author'>
    {% for author in bookchap.author %}
        <span class='{{ author.role }}'>{{ author.family }}, {{ author.given_initial }}; </span>
    {% endfor %}
    </div>
    <div class="booktitle">
    <span class="booktitle">{{ bookchap.booktitle }}</span>
    </div>
    Book Editors:
    {% for editor in bookchap.editor %}
        <span class='editor'>{{ editor.family }}, {{ editor.given_initial }}; </span>
    {% endfor %}
    
    <div class="pubinfo">
    <span class="publisher">{{ bookchap.publisher }}, </span><span class="city">{{ bookchap.city }}, </span><span class="year">{{ bookchap.year }}, </span> Pages: <span class="page">{{ bookchap.page }}. </span>
    </div>
    <div class="url">
        <a href="{{ bookchap.URL }}">{{ bookchap.URL }}</a>
    </div>
    </li>
{% endfor %}
</ol>
</div>


## Presentations and Posters
-----

<div class='panel-pub'>
<ol>
{% for presentation in site.data.meeting %}
    <li>
    <div class="title">
    <span class="title">{{ presentation.title }}</span>
    {% if presentation.fulltext %}
        <a title="fulltext" href="{{ site.url }}/downloads/meeting/{{ presentation.fulltext }}"><i class="fa fa-file-pdf-o"></i></a>
    {% endif %}
    </div>
    <div class='author'>
    {% for author in presentation.author %}
        <span class='{{ author.role }}'>{{ author.family }}, {{ author.given_initial }}; </span>
    {% endfor %}
    </div>
    <div class="pubinfo">
    <span class="source">{{ presentation.source }} </span><span class="city">{{ presentation.city }}, </span><span class="year">{{ presentation.year }}.</span>
    </div>
    </li>
{% endfor %}
</ol>
</div>

## Thesis
-----

<div class='panel-pub'>
<ol>
{% for thesis in site.data.thesis %}
    <li>
    <div class="title">
    <span class="title">{{ thesis.title }}</span>
    {% if thesis.fulltext %}
        <a title="fulltext" href="{{ site.url }}/downloads/thesis/{{ thesis.fulltext }}"><i class="fa fa-file-pdf-o"></i></a>
    {% endif %}
    </div>
    <div class='author'>
    {% for author in thesis.author %}
        <span class='{{ author.role }}'>{{ author.family }}, {{ author.given_initial }}</span>
    {% endfor %}
    </div>
    {% for advisor in thesis.advisor %}
        <span class='advisor'>{{ advisor.role }}: {{ advisor.family }}, {{ advisor.given_initial }}</span>
    {% endfor %}
    <div class="pubinfo">
    <span class="source">{{ thesis.source }} </span><span class="publisher">{{ thesis.publisher }}, </span><span class="year">{{ thesis.year }}.</span>
    </div>
    </li>
{% endfor %}
</ol>
</div>


