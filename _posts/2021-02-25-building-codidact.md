---
layout: post
title: 'Building Codidact: Not Just Tech'
categories:
  - dev
tags:
  - codidact
  - sysadmin
  - scale
  - team-building
excerpt_separator: '<!-- end_excerpt -->'
---

I've been working on [Codidact](https://codidact.com) for the last 18 months or so. We've built up from nothing, planned
what we wanted to do, put systems up, started work, changed course, re-started work, switched systems, and welcomed
and lost a whole load of team members along the way. We've served just under 5 million requests and 50GB of data in the 
last month &mdash; which is not vast scale, but it's certainly much bigger scale than anything else anyone on our team
has worked with. We've all learned a lot along the way: our team is still small, and we've all got other commitments;
while everyone has things they're good at, we've all had to learn bits of other areas to be able to support each other
as well.

<!-- end_excerpt -->

The eternal problem facing a new organisation like Codidact is getting it out there. We've done some great work, but
unless we publicise it and engage people and develop our communities, it's not going to get us anywhere. The problem is
that this creates a vicious cycle: more community equals more load equals more scaling, which opens up capacity for more
community. "If you build it, they will come" is a nice sentiment, but it doesn't work in reality: perhaps with a niche
product it might, but when the market area has big players already, it's much more difficult.

## Start at the Start
Once upon a time, long long ago (okay, it was 2019)... there were [some problems](https://dearstack.artofcode.co.uk) at
Stack Exchange, which is one of the major players in the online Q&A space. We'll skip the details here, but suffice to
say that provided the catalyst for Codidact's start. While the original intention was simply "build an alternative", 
that very quickly turned into bigger plans: why build the _same_ thing when we could build something _different_ and,
hopefully, better?

Rather than going straight for building the platform, the first few months were a planning phase. We stood up a
[Discourse](https://discourse.org) instance and hashed out what, exactly, we wanted to build: what tech stack, what
features, how it should work, how the organisation should work, what colour the bike shed should be... etc. (People
_really_ like talking!)

We picked some people to lead the way: [Marc](https://meta.codidact.com/users/8064) as Tech Lead, to lead and
coordinate development; [Monica](https://meta.codidact.com/users/8046) as Docs Lead, to handle getting all our decisions
and software documented properly, and me as Team Lead, coordinating the organisation overall. Those roles have changed
and morphed over time: we now have [luap42](https://meta.codidact.com/users/8058) as our Head of Development (akin to
the original Tech Lead), Monica's role has morphed more towards community management and has become Head of Community,
and my role has kept the coordination but I also contribute to development, so I'm our Head of Operations.

## A Change of Course
Having laid out a full, detailed plan, picked who was doing what, when, why, and how, we then... ripped it all up again.
Well, not _quite_ like that. We'd originally picked C# ASP.NET Core to build our platform on, but as we started
development it became clear that a number of the developers who'd originally picked that and volunteered to contribute
had other commitments. Ah well, life happens.

While we'd been getting that development kicked off, we'd also launched an initial community, 
[Writing](https://writing.codidact.com/). Without our own platform built yet, we used a project that I'd made and
abandoned long before &mdash; QPixel. At the point we adopted it, it was little more than a basic Q&A platform; not only
that, but it was abandoned and out of date, and the design was... shall we say shocking? We spent a while bringing it
up to date again, and monkey-patched in a responsive design so that at least we could support mobile devices, and then
brought Writing online with an initial set of content imported from Stack Exchange.

At the point that development on our own platform ground to a halt, Writing had been around for a few months, and had
been running reasonably well; the platform wasn't quite what we wanted, but that was understandable because it was only
a temporary solution. Now, though, we changed course: instead of trying to keep a C# project alive, we moved to
developing QPixel up to our proposed standard instead.

This is where COVID-19 managed to _help_ us: being locked down at home and furloughed off work, I had developer time to
spare to get that effort started. I wasn't the only one: luap42 created [Co-Design](https://design.codidact.org/), the
design system that we then applied to QPixel to bring the design up to date and fully responsive. (I still credit the 
design change as being one of the _most_ impactful changes we made to QPixel: you can't tell how bad a design truly is 
until it's replaced with something better.)

## Minimum Viable Product
MVP. More than once I got asked what that acronym stood for and what that meant. Our "MVP" was the result of the
discussions we'd had way back at the start: what we'd agreed on that our software should be and what it should do.

We spent a good few months from that point developing QPixel. While the architecture had worked for us when we were just
trying to run a stop-gap Q&A site, it didn't work for what we wanted to do. We wanted different types of posts &mdash;
not just Q&A, but blog posts, wiki posts, challenge posts, the works; QPixel had a Question type and an Answer type, and
that was it. We wanted a different kind of scoring system so we could sort answers so the most agreed-upon answer would
rise to the top; QPixel used a simple sum: `up - down`. We'd also, when we deployed QPixel for Writing, patched in the
concept of meta: posts about the site itself &mdash; but the patch was limited and we wanted the ability to have
multiple categories on a site, not just main and meta.

This almost happened in stages. There were changes to be made that were essential for any further development to
happen, and there were changes for features that we wanted, but that weren't blocking anything else. Things like the
architecture changes were the big things that needed to happen soon, so we started from there and spent a month or two
making sure those were in place and working before moving on.

## Whack-a-Bug
Since the point we switched development to QPixel, we've made over 1300 commits, changing 750+ files, adding more than
22,000 lines and removing over 7,000 lines of code. All of those changes can be broadly separated into three categories:

 * Bug fixes
 * User feature/change requests
 * Planned features

Turns out, building a platform that people are actively using at the same time means they find everything that's wrong
with it! This is a good thing, because it means we find and squash the inevitable bugs quickly, but it does also slow
down progress on other development while effort gets diverted to issues that are currently affecting our users.

This also means that we didn't get to work on our planned features for MVP as quickly as we'd like. Again, when folks
are using the platform, how it works (or not) affects them in ways we couldn't have planned for, so our roadmap has
been... dynamic, shall we say? Instead of just running down a list of planned major features and adding those in,
there's been some work on planned features interspersed between fixing bugs or making the platform work for our users.

## Scale it Up
As I write this, we have 14 communities (plus Meta) active on our network, and we're
[still adding](https://meta.codidact.com/categories/10) to that. Some of those communities started from scratch, while
others brought in good content from Stack Exchange (with attribution, of course). As we've added more communities, the
number of posts and users on the network has steadily increased &mdash; right now, we're holding about 85k posts
totalling about half a gigabyte of data, and around 30k users. That's not _vast_ scale, but it's enough to have to think
about it &mdash; doing things inefficiently starts having an effect on production.

We've had to write and re-write utility scripts a number of times. These utilities help us make bulk modifications to
the data, when that's necessary, or ensure the data all says the same thing (_that's_ certainly caused a few bugs), or
help us keep track of how and when the system is being used and where it's going wrong. Many of them were originally
written for the original QPixel, which was never designed with scale in mind &mdash; and, being horribly inefficient
because of it, they started slowing production down, and in a few cases, crashing the server altogether.

Much of our core code has also been replaced, bit by bit, both as we've adapted it to make the platform do what we want
it to, and through necessity because of the shift in scale. I've found myself looking fairly often at database queries
in various places and finding old queries that hadn't been thought about with scale in mind, then rewriting them to
make sure we're loading the right data at the right point, and not issuing far more queries than we need to.

We're still dealing with the challenges that come with this shift in scale. Our last major upgrade 
[didn't go very well](https://meta.codidact.com/posts/280081) &mdash; again, because while it worked well enough on our
development environments, we hadn't thought enough about how that would change when meeting gigabytes of data. We ended
up doing that upgrade through a development environment because the production server didn't have the resources to do
it. I'm also looking at building some more tooling to keep an eye on long-running database queries for me so that I
don't have to look for them myself.

## Keepie Uppies
With increasing scale &mdash; both in content and in usage &mdash; comes additional demands on the hardware running the
site. This is a problem that we've struggled with from the start: as a brand-new organisation, we relied on the
generosity of individuals to provide what we needed to start with. One of our original admin team provided the Discourse
instance we used for initial discussions; another of our admins bought our domains and some simple hosting space, which
still powers [codidact.org](https://codidact.org). When we got around to putting up a live instance of QPixel, that
lived &mdash; and continues to live &mdash; on my own server space, which we've already upgraded once.

At the moment, we're running production on one server. That server runs:

 * nginx (reverse proxy and server for [codidact.com](https://codidact.com))
 * QPixel (application)
 * MySQL (database server)
 * Redis (cache server)

That's a lot for one server to run! We're not yet at the point where it's over capacity, but that point won't be too far
away.

One of the challenges involved with limited server resources is keeping the thing online and up to date. We still have
to deal with outages sometimes, when the server crashes or decides it's had a bad day, but as we've grown we've found
or built tools to help us stay up more and recover quicker. We've deployed systems that allow our leadership team to
ensure the application is up to date; we've deployed [status monitoring](https://status.codidact.org); we have a number
of trusted people who have access to get the server back online should it all crash.

## KBO
We're still building, of course &mdash; the work on bug fixes and new features hasn't stopped since. We've got one
major new feature in the works that we've wanted right from the start: a much improved comment system, including
threaded comments and a specific feedback thread for the post's author, among other improvements, and there are always
more bugs to fix and behaviours to tweak to work for the community.

We're working on continuing to build our organisation, too. We're still shoring up our (still relatively new) non-profit
organisation, and we're always looking for more people to join the team and help us learn and build as we go. One of
the biggest things we've built over the last 18 months is our ability to bring in different people with plenty of
different experience, and put it all to work to build a successful platform.
