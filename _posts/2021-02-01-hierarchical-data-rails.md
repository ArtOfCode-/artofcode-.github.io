---
layout: post
title: Working with hierarchical data structures in Rails
categories:
  - dev
tags:
  - rails
  - databases
excerpt_separator: '<!-- end_excerpt -->'
---

As many grizzled veterans of relational databases will know, [managing hierarchical data structures is hard][1]. A
database just isn't the right tool for the job  —  but, in many cases, it's the tool that's available. Sometimes the only
tool. Environments in which you can't control your stack or your backing stores are common, especially outside of open
source projects, which leaves developers in a mess when the need to store a hierarchy crops up halfway through a
project.

<!-- end_excerpt -->

![Example of a hierarchical data structure, showing a tree of categories. Each category is a sub-type of its parent.][2]

The difficulty raised by storing that structure in a database is one hurdle. If you happen to be using Rails, you have
another hurdle ahead: ActiveRecord is also the wrong tool for the job. It's not built to handle hierarchies beyond
simple parent-child relationships. Now, if you know that you're only ever going to have three levels in your hierarchy
then you can make it work with some extra joins and includes - but what if your structure is four levels deep? What about
ten? What if it's n levels?

Now before you swear off databases and Rails for a simpler life in the jungle... all hope is not lost. If you can't
influence the tools you're using and you must store your hierarchy in a database, you're going to hit two fundamental
problems: traversing up your structure, and traversing down your structure.

Before I get into these: take a look at the guide I linked earlier; that has some solutions for structuring your
hierarchy differently that may make your job easier.

## Traversing Up

I'll start with the easy one. Traversing up a tree to compose a "path" of parents to your selected node is,
theoretically, easy: there is only one parent for each node, so you can follow the links up the tree until you have the
full chain.

Let's give ourselves a Product model to demonstrate on:

```ruby
class Product < ApplicationRecord
  belongs_to :parent, class_name: 'Product', required: false
  has_many :children, class_name: 'Product', foreign_key: :parent_id
end
```

To create a parent chain on that model, you could add a method that simply loops through the parents:

```ruby
class Product < ApplicationRecord
  belongs_to :parent, class_name: 'Product', required: false
  has_many :children, class_name: 'Product', foreign_key: :parent_id
  def parent_chain
    Enumerator.new do |enum|
      parent_product = parent
      while !parent_product.nil?
        enum.yield parent_product
        parent_product = parent_product.parent
      end
    end.to_a.reverse + [self]
  end
end
```

Okay, maybe a little bit more fancy than necessary there. Still. This is all well and good, and for a single Product
this is absolutely fine. The downside here is that this approach runs a single query for every Product instance in the
chain. If your hierarchy is five levels deep, that's five queries. Again  —  for one product, that's okay, but if you
start wanting to do this on, say, a product list... you run into trouble real quick  — you're suddenly doing hundreds or
thousands of queries.

Did I say this was the easy one?

This is where I got stuck. Reluctantly, I [took the problem to Stack Overflow][3]. The [answer][4] I got there put me
almost all the way to solving it  —  in essence, you can tell Rails where to preload the data from, like an includes, and
recursively run that at each level of the hierarchy. Now, instead of running 500 queries for your product list, you're
only running one per layer of hierarchy.

The code I came out with in the end is a monkey-patch for `ActiveRecord::Relation` that adds in four hierarchical
preload methods. You can find it in [this gist][5], which for the sake of brevity I will not include here.

This approach cleans up the resulting code a bunch as well: instead of chained calls to includes, preloading a whole
chain can look like this instead:

```ruby
Product.all.deep_preload_chain(:parent)
```

This also works for referenced tables: perhaps you have an Order model, which `has_many :products`. You can create a
list of orders, with product parent chains preloaded, with this:

```ruby
Order.all.deep_preload_reference_chain(products: :parent)
```

That's got upwards traversal covered. What about the other way?

## Traversing Down

There was no pretty way to do this. There really wasn't.

Moving down the tree (i.e. to find a list of children of a certain node) is a more difficult proposition than moving up:
when you're moving up, there's only ever one parent; moving down, there can be multiple children on each parent node.
ActiveRecord's preloader didn't like that, despite my efforts to coax it to my way of thinking. So, I looked elsewhere.

MySQL 8.0+ has a wonderful new feature (that other databases have had rather longer, I should add) of recursive CTE's.
These let you specify an 'anchor point' - in our case, that'd be the node whose children we want to find  —  and then
recurse down the tree, finding all children of the previous node and putting everything together with a UNION.

This is where I went with this side of the problem. Putting together a recursive CTE for the product model we had
earlier looks something like this:

```sql
WITH RECURSIVE CTE (id, parent_id) AS (
  SELECT id, parent_id
  FROM products
  WHERE parent_id = PARENTID
  UNION ALL
  SELECT p.id, p.parent_id
  FROM products p
  INNER JOIN CTE ON p.parent_id = CTE.id
)
SELECT * FROM CTE;
```

That query sends you back a list of record IDs; all of those IDs are records that - somewhere along the line - have record
PARENTID in their parent chain. This list you can simply pass back into Product.where to get an `ActiveRecord::Relation`
out of it. I put the raw SQL for this query in lib/queries, so my code looks like this:

```ruby
def children
  query = File.read(Rails.root.join('lib/queries/cte.sql'))
  query = query.gsub('PARENTID', id.to_s)
  i = ActiveRecord::Base.connection.execute(query).to_a.map(&:first)
  Product.where(id: i)
end
```

---

And that's where I stopped. With those two fundamental operations, I've been able to do everything I've needed to do
for my app  —  there may be more operations necessary for a fully functional data structure, but given the effort these
two took... that's a job for another day. When those operations are actually necessary.



[1]: https://www.mysqltutorial.org/mysql-adjacency-list-tree/
[2]: ../images/posts/2021-02-01/structure.png
[3]: https://stackoverflow.com/q/53133500/3160466
[4]: https://stackoverflow.com/a/53134565/3160466
[5]: https://gist.github.com/ArtOfCode-/8efd6417cdad7baa7c663f9f11edbf6d
