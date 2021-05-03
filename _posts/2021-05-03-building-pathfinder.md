---
layout: post
title: Building Railator & Pathfinder
categories:
  - dev
tags:
  - node.js
  - vue.js
  - ruby
excerpt_separator: '<!-- end_excerpt -->'
---

A while ago, I built [Railator](https://artofcode.co.uk/railator), for fun and to give me a chance to learn a few new
things. It's a very simple progressive web app that pulls train data from National Rail APIs and presents it. Much more
recently, I added [Pathfinder](https://artofcode.co.uk/pathfinder) to it, which is a London-only tool to find paths
(duh, really?) between any two given tram, DLR, tube, overground, or some rail stations. Again, this was mostly for fun
and because it might help me learn a few more things, but I did have some ideas about how it could end up being
real-world helpful for me. It turned out to be _way_ more complicated than I was expecting.

<!-- end_excerpt -->

## Part the First: Railator
Railator didn't come about through necessity, just through boredom. Nor was it an original idea: I scrolled through a
few lists of ideas for things to build, and hit on one that suggested a train-times client. Being a bit of a train nerd
as well as a programmer, that's what I went with. The original intention was to use it to learn Vue.JS, which I did. I
_also_ ended up learning a bunch of other things on the way, as it turned out to be way harder than I expected.

National Rail, the organisation that is the public face of the train operating companies in the UK, does _have_ an API,
but it's... not the nice easy experience I'm used to from a lot of things in the dev world. I'm used to signing up to
something, grabbing an API key, taking a quick look at documentation, firing off a request and getting nice easy JSON
back. Not so. Not only does the NR API have a ridiculous acronym (LDBSVWS), it's also a SOAP XML API. Have I ever heard
of one of these before, let alone actually used it? Nope.

Now there are proxy tools for most languages for interacting with SOAP APIs, but I was already halfway through building
my own interface to the API before I actually realised this. So, learning point one: SOAP, in all its terribleness. An
API request is not a nice simple HTTP GET with an API key as a parameter or header &mdash; it's a full HTTP POST request
with all the parameters and authentication embedded in an XML message:

```xml
<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:typ="http://thalesgroup.com/RTTI/2013-11-28/Token/types"
               xmlns:ldb="http://thalesgroup.com/RTTI/2017-10-01/ldbsv/">
  <soap:Header>
    <typ:AccessToken>
      <typ:TokenValue>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</typ:TokenValue>
    </typ:AccessToken>
  </soap:Header>
  <soap:Body>
    <ldb:GetDepartureBoardByCRSRequest>
      <ldb:numRows>150</ldb:numRows>
      <ldb:crs>KGX</ldb:crs>
      <ldb:time>2021-05-03T07:00:00+01:00</ldb:time>
      <ldb:timeWindow>60</ldb:timeWindow>
    </ldb:GetDepartureBoardByCRSRequest>
  </soap:Body>
</soap:Envelope>
```

That's... unattractive, but it's not necessarily bad, just not what I'm used to. That said, JavaScript is _not_ good at
working with XML, whereas it's basically built for JSON. So, whatever proxy interface I built had to have two functions:

 * Simplify access to the NR API
 * Translate HTTP requests using query parameters to SOAP XML requests, and SOAP XML responses to JSON responses.

I managed with surprising success to meet both of those goals. I built a tool that let me make simple HTTP requests from
my front end, which would translate that into SOAP format and send it off, then translate and simplify the SOAP response
it received into JSON that I could make use of. The format it returns is a little odd, but that's because it's basically
a direct translation from the XML, which can't be represented in JSON in quite the same way (for instance, how do you
represent attributes vs. tag values?).

The next challenge was to build the front end for it. This was (perhaps unsurprisingly) tricky: I was learning Vue as I
went, which is a very different way of writing HTML than I'm used to, and the data I was trying to display can be 
nuanced and fairly confusing. For instance, a train can have a scheduled, estimated, or actual time of arrival or
departure at a given station (ETA, STA, ATA and ETD, STD, ATD). There's an `arrivalType` and a `departureType` field
which tells you which field to look in to find the current information, and then depending on that type you may also
have other information to display (like how late the train is, if its ETA is past its STA).

In retrospect, although I managed and overall the code isn't _bad_, it is all packed into one or two files because I
didn't want to end up referencing dozens of smaller component files in the HTML. I could've used some sort of build
process here so that I could write the code split up into single-concern files and packed it all together for
production. Then again, you can't learn too many things in one go.

## Part the Second: Pathfinder
Having changed jobs relatively recently, and being a transport nerd, I kept finding myself musing about how London's
transport network is effectively a graph structure. There are plenty of ways for me to get between work and home, which
each take a different length of time. Thinking about that, my preferred route is actually _not_ the quickest route
&mdash; it's the "nicest" route. So on one hand, we have a graph with obvious edge lengths &mdash; the travel time
between points &mdash; but then is it possible to incorporate route "niceness" or other user preferences into that, and
maybe add in real-time information about delays and closures, and come up with a "best" route on request?

This was the idea with Pathfinder. It's still not quite there yet, but I've done a lot of the work to get it to
something approaching that idea.

### Endless Data Entry

This one actually involved much less programming and much more data collection and data entry. To even be able to start
defining the transport network as a graph, I had to have a list of nodes (stations), and then define the edges between
them. To do _that_, I had to know the edge weights. The easiest weights to get would probably have been the physical
distance between stations, but... that wouldn't have worked. Some parts of the network are faster than others; the same
distance doesn't necessarily take the same time.

So, instead, I went looking for data about travel times between stations. Freedom of Information requests are a
wonderful thing &mdash; someone made an FOI request about a year ago for exactly that data, which Transport for London
provided. Not in a very useful format, but... it was there. I spent an afternoon entering data from the Word files it
was in into a simple spreadsheet of three columns: origin, destination, time.

What that didn't get me was travel times for London Overground lines, or for the DLR. Fortunately, I found a [map] that
had travel times for both of those networks on it &mdash; rounded to the minute, instead of down to the second as I had
for the Tube data, but it'll have to do. That still left me without any data on main-line railway services, but
fortunately there's really only one route I care about, which I timed manually over a week or so on my way in and out
of work.

### Data Structures
Now I had what was, effectively, a graph in CSV form, by simply listing every edge. Now I needed to turn that into a
data structure that I could actually work with programmatically. I picked Ruby, mostly because I like Ruby, and partly
because I didn't feel like JavaScript would do a great job of it.

This took me right back to simple principles from school and early university: data structures, graphs, stacks, queues,
algorithms. I built a really simple undirected graph data structure, keeping all the operations as simple as possible:

```ruby
class Graph
  attr_accessor :vertices

  # O(1)
  def initialize
    @vertices = {}
  end

  # O(1)
  # Create an empty Vertex instance and add it, unless that key already exists.
  def add_vertex(key)
    return if @vertices.include? key

    @vertices[key] = Vertex.new(key)
  end

  # O(n)
  # Remove the vertex itself, plus any edges on other vertices referencing it.
  def remove_vertex(key)
    @vertices.delete key

    @vertices.each do |v|
      v.edges.delete key
    end
  end

  # O(1)
  # Set edge weight k1→k2 and k2→k1 to weight so the edge is bidirectional.
  def add_edge(k1, k2, weight)
    @vertices[k1].edges[k2] = weight
    @vertices[k2].edges[k1] = weight
  end

  # O(n)
  # Delete the edge on both vertices.
  def remove_edge(k1, k2)
    @vertices[k1].edges.delete k2
    @vertices[k2].edges.delete k1
  end
end
```

TL;DR: the class has one major attribute, which is a hash of the graph's vertices. Each vertex has a 'key' to reference
it by, which is the hash key, and the hash value is an instance of the even simpler Vertex class I added:

```ruby
class Vertex
  attr_accessor :key, :edges

  def initialize(key)
    self.key = key
    self.edges = {}
  end
end
```

TL;DR: Each vertex knows its own key, and contains a hash of its edges. Each hash key is the key of the vertex at the
other end of the edge, and the hash value is the edge weight.

From there, I wrote a script to take the CSV data and create a graph from it, giving each vertex the normalized station
name (capitalized, alphanumeric only) as the key, and each edge the travel time as its weight. Obviously I don't want to
be doing that every time I want to find a path, so I used Ruby's Marshal data format to dump the graph structure to a
file that can be loaded on-demand much faster than building the graph from scratch.

One of the problems I had here was how to represent interchanges. If you can go from A to B on one line, then B to C on
another line, clearly you _can_ get from A to C, but the travel time is not just `A→B + B→C`: you have to change
between lines, which also takes some time. If the lines are 1 and 2, then the time is actually 
`A(1)→B(1) + B(1)→B(2) + B(2)→C(2)`. (I did skip the problem of finding interchange times at every station for every
line combination by just defining a static interchange time of 3.5 minutes).

I ended up solving this by appending the line name onto the station name at every vertex then adding extra edges for the
interchanges &mdash; so stations that are served by lots of lines (looking at you, King's Cross and Stratford) are
actually represented by multiple vertices with interchange edges between them &mdash; though these edges are no
different from actual travel edges. This did mean I had to add to the graph generation script to detect these
interchange stations and add the interchange edges, because I wasn't about to add all those changes to the CSV data.

Still, I got there, and the generation script is still sub-100 lines, so that's not bad. Onwards...

### Algorithmic Interpretation
I still had to build a way of finding the shortest path between any two points on the graph. I know there are a few
algorithms that can do this, but I picked Dijkstra's as being the algorithm that made most sense to me. There's a nice
summary of the algorithm on its [Wikipedia page][wiki], which I based my implementation off.

I'd already implemented a couple of search algorithms when I was building the `Graph` class, that I thought would help
me here, but I turned out not to need those at all. Still, they're there if I do.

The Wikipedia description of the algorithm goes like this:

```
 1  function Dijkstra(Graph, source):
 2
 3      create vertex set Q
 4
 5      for each vertex v in Graph:            
 6          dist[v] ← INFINITY                 
 7          prev[v] ← UNDEFINED                
 8          add v to Q                     
 9      dist[source] ← 0                       
10     
11      while Q is not empty:
12          u ← vertex in Q with min dist[u]   
13                                             
14          remove u from Q
15         
16          for each neighbor v of u:           // only v that are still in Q
17              alt ← dist[u] + length(u, v)
18              if alt < dist[v]:              
19                  dist[v] ← alt
20                  prev[v] ← u
21
22      return dist[], prev[]
```

I tried to follow that as closely as possible, and came up with this:

```ruby
def shortest_path(start, target)
  verts = []
  distances = {}
  previous = {}

  @vertices.each do |key, vert|
    verts << key
    distances[key] = Float::INFINITY
    previous[key] = nil
  end

  distances[start] = 0

  until verts.empty?
    # N.B. extract_min here is just a simple method to iterate through a hash and find the minimum value.
    #      Not included here for brevity.
    current = extract_min(verts.map { |k| [k, distances[k]] }.to_h)
    verts.delete current

    if current.nil?
      raise ArgumentError, "No path exists between #{start} and #{target}"
    end

    if current == target
      # N.B. likewise, prev_sequence just iterates through the previous list in reverse to build the path.
      return [distances[current], prev_sequence(current, previous)]
    end

    @vertices[current].edges.each do |nb, nb_dist|
      next unless verts.include? nb
      alt = distances[current] + nb_dist
      if alt < distances[nb]
        distances[nb] = alt
        previous[nb] = current
      end
    end
  end
end
```

To my surprise, it worked almost straight off the bat. I guess that's what following instructions does for you...

### Integration Hell
The next part of the idea was to integrate TfL data about delays and closures so that it could be displayed to users,
and ultimately so that the system could pick a route around any closures and taking delays into account. Now TfL does
_have_ an API, but in much the same spirit as the NR API, it's a bit... weird. It's JSON, which helps, but its
documentation is all over the place and rather lacking in places &mdash; but hey, been there before, we can deal with
that.

My initial approach was to generate a route, then compile a list of every point it passes through and pass that to some
as-yet-unspecified TfL API to get a list of disruptions applying to those points. At this point, I (correctly) 
suspected that the TfL API wouldn't just take my normalized station names as input, so I went looking for what it did
want. Turns out it uses ATCO codes, which are a whole Thing in themselves. Codes are made up of transport point type,
a flag, an optional operator depending on point type, and a point code.

<table>
  <thead>
    <tr>
      <th>ATCO code</th>
      <th>Point type</th>
      <th>Flag</th>
      <th>Operator</th>
      <th>Point code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>940GZZLUBBB</code></td>
      <td><code>940</code><br/> MET — Metro Access</td>
      <td><code>G</code></td>
      <td><code>ZZLU</code><br/> London Underground</td>
      <td><code>BBB</code><br/> Bromley-by-Bow</td>
    </tr>
    <tr>
      <td><code>940GZZDLGRE</code></td>
      <td><code>940</code><br/> MET — Metro Access</td>
      <td><code>G</code></td>
      <td><code>ZZDL</code><br/> DLR</td>
      <td><code>GRE</code><br/> Greenwich</td>
    </tr>
    <tr>
      <td><code>940GZZCRADD</code></td>
      <td><code>940</code><br/> MET — Metro Access</td>
      <td><code>G</code></td>
      <td><code>ZZCR</code><br/> London Trams</td>
      <td><code>ADD</code><br/> Addiscombe</td>
    </tr>
    <tr>
      <td><code>910GESSEXRD</code></td>
      <td><code>910</code><br/> RLY — Rail Access</td>
      <td><code>G</code></td>
      <td>(blank)</td>
      <td><code>ESSEXRD</code><br/> Essex Road</td>
    </tr>
  </tbody>
</table>

Next problem: how do I translate between my normalized station names (i.e. KINGS CROSS) and these ATCO codes (i.e.
`940GZZLUKSX`)? While I can generate the first `940GZZLU` easily enough, there's no easy way of knowing what the
three-letter point code is for any given station. I figured that when the server starts, I'd have it download a list of
station names and codes from the TfL API &mdash; I can generate the normalized name from the full name, and then I'd
have the ATCO code.

The TfL API didn't want to cooperate. Turns out requesting a full list of every stop on the Tube, DLR, Overground, and
TfL Rail is quite a lot of data, who knew? Even with retries, I couldn't get the API to give me anything other than a
504 server error.

Back to data processing I went. I found and downloaded a list of every single transport point in the country. If you 
thought London was a lot of data, nationwide is a whole lot more. There's almost half a million rows, and the CSV file
is 132MB in size. That's not very manageable for trying to create a graph out of, so I spent a day processing that data
down to just points within 40 miles of central London, and just RLY and MET types (i.e. rail and metro access, which are
the types I'm interested in &mdash; I don't need buses, airports, ports, etc). That left me with around 1,000 points,
which is still a lot, but much more manageable for the generation script.

Instead of regenerating the graph with station names and then matching them up with their ATCO codes on the fly, I
regenerated the graph with the ATCO codes as the vertex keys. This turned out to be a smart decision, which let me
remove some of the data and code I had to maintain for normalizing station names, but without impacting how the front
end worked in the slightest. It also let me simplify the call from the Node server to the Ruby pathfinder script.

---

This is where I'm at at the moment. I have a functioning pathfinder that picks the shortest path between any two points
in London, based on travel time, and shows you any information about delays or disruptions on the route. I'm currently
still fighting the TfL API to tell me exactly what points are disrupted &mdash; sometimes it's the stop point, sometimes
it's the line that the disruption is stored on; some data I can cache and some I can't.

What I haven't yet got it to do, which I would like to, is to take length of delay and any closures into account, and
pick a route that avoids the closed bits and minimizes any delays. I haven't yet decided how I'm going to pass that data
into the script from the Node server that's fetching it, but... we'll see. Beyond that, there's the challenge of adding
in route "niceness", which is... completely subjective, so that'll be even more fun.



[map]: http://www.london-tubemap.com/assets/tubemap_journey-times_2.pdf
[wiki]: https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
