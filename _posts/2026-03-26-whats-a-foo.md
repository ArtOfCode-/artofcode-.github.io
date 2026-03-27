---
layout: post
title: Just what is a foo, anyway?
categories:
  - community
tags:
  - Codidact
  - LLM
  - AI
excerpt_separator: '<!-- end_excerpt -->'
draft: true
---

A [question](https://software.codidact.com/posts/295816) in our Software community's meta
category got me going yesterday, and there was more I wanted to write but didn't—so it's coming here instead.

<!-- end_excerpt -->

## The Point of Humans
The question went like this:

<blockquote>
<p><strong>What's the point of Q&A sites anymore?</strong></p>
<p>
Lately, whenever I consider asking a question on a site like Software Codidact, I end up just asking an LLM chatbot
instead. Just thinking of the effort of distilling a minimal working example, formatting the post correctly, and
anticipating the downvotes, is enough to have an aversion to the site. So what’s the point of these Q&A communities if
the friction to participate often outweighs the benefit, especially when a language model can give you an answer
instantly?
</p>
<cite><a href="https://software.codidact.com/posts/295816">ShadowsRanger on software.codidact.com</a></cite>
</blockquote>

I suppose it's a fair enough point. There's a proliferation of public, free LLMs now and they're _generally_ not bad at
giving reasonable answers to many things.

## Artificial Untelligence
My hangup about the move of these LLMs into our lives as an everyday tool stems from exactly _what they are_, and how 
misleadingly they've been marketed.

An LLM—Large Language Model—is at its core a _statistical_ model of language based on its training data. They're fed an 
input diet of massive amounts of text, images, code—whatever their authors want to train them on—and based on that input
they "learn" how language works, statistically. Fundamentally, because of how language works, some words are more likely
than others to occur following a particular word or string of words—for instance, after the string "the quick brown fox
jumps over the lazy", the word "dog" is likely to appear next.

This leads to a fundamental misunderstanding of how they work, which the AI companies are leaning into heavily. The
impression they want you to take away is that this "AI" _understands_ what you're saying, then reasons and critically
evaluates information like a human would to come to an answer. That's not the case—it's essentially predicting which
words are statistically most likely to occur following the prompt you provide.

## A Model Citizen
Here's a very simple example of a model:

![A simple graph of x=y from 1 to 10, with a trendline continuing to x=12][1]

The data points in this are my _training data_; the dotted trendline is my _model_. The model is a perfect fit to the
training data, and if you believe the model then for an input of 11, it suggests the output will also be 11. That may be
right—but what's to say that this data only follows x=y from 1 to 10, and then goes on to 13, 24, 35, ...?

LLMs work the same way, but with billions of input and output parameters and other parts to the system that allow for
some variation or "creativity" in their output. In the same way, though, even if the model is a perfect fit to the
training data, it's still only trained on _what went in_; it's impossible to know if an answer is _correct_ purely from
extrapolating statistics.

## Claim & Disclaim
"AI can make mistakes. Always check it yourself." _Suuuuuure._ Nobody's doing that.

This disclaimer is there in every AI product, and it bugs me. It's clearly a legal disclaimer meant to absolve the 
company of responsibility for their product spitting out wrong information. That's not why it bugs me, though.
My working theory is that people read "AI can make mistakes" in the same way as "humans can make mistakes"—but those are
two very different things. Humans can make mistakes of knowledge or reasoning, but we're used to making judgements about
that based on someone's level of confidence, expertise, and knowledge. An LLM has a perfect "memory", but because it's
only making statistical predictions, that doesn't matter—the statistics might still come up with something entirely
untrue. This has generally been termed "hallucination" in the AI world.

That's not something we're used to judging, as humans—it's like someone being confidently wrong, but it's not someone
who makes a habit of that; it's someone who's _often right_ about a wide variety of topics being _absolutely certain_ of
an answer, and still being wrong. It's a confidence trickster taken to the next level: something building your
confidence in it by feeding you correct answers until you believe it'll be right next time, and then just... making
something up. It's like telling a young child that someone has to paint the sky to keep it blue: completely made up, but
they'll still believe you.

## So What's the Point?



[1]: ../images/posts/2026-03-26/example-model.png
