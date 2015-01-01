---
title: "Scientific Python on the BEAM"
description: The matplotlib book left me wondering how much of the scientific-Python world I could pull onto the Erlang VM. The answer became two projects, a discovery I didn't plan, and line charts drawn in the terminal.
published_date: 2014-12-31 22:00:00 -0600
tags:
  - lfe
  - erlang
  - python
  - scientific-computing
is_draft: false
data:
  author: Duncan McGreggor
  math: false
---
Writing a book about matplotlib did something I hadn't quite expected: it reignited an old love. Somewhere in the middle of all those chapters on architecture and event loops and big-data plotting, the physics student I used to be woke back up, and I started asking a question that had nothing to do with the deadline in front of me. Almost all of my daily work now lives on the Erlang VM — LFE, mostly — and the BEAM is a wonderful place to build concurrent, fault-tolerant systems. But it is not, by any stretch, a place people go to do science. There is no NumPy here. No SciPy. No matplotlib. So the question that wouldn't leave me alone was simply: *how much of that world could I bring over?*

## The problem

The BEAM gives you things the scientific-Python stack can only dream of: cheap processes by the million, supervision, distribution that actually works. What it does not give you is four decades of numerical libraries. You are not going to reimplement NumPy in Erlang, and you shouldn't want to — that code represents an enormous amount of hard, careful work that already exists and is already fast.

So the pragmatic move is not to *replace* Python but to *talk* to it. Run Python as a companion process, hand it the numerical work, and get the results back. The question is only how gracefully the two runtimes can be made to converse.

The tool that makes this possible is [ErlPort](http://erlport.org/), Dmitry Vasiliev's library for letting the Erlang VM speak to an external Python (or Ruby) process over Erlang's own port protocol. He's been quietly making the BEAM polyglot since 2009, and everything here rides on his work. I wrote up the basics of driving it from LFE [earlier this month](/articles/2014/12/erlport-using-python-from-erlang-lfe/), if you'd like the mechanics before the machinery. I'd been circling ErlPort for a while, looking for ways to run scientifically-minded languages on the BEAM — Julia had my attention around the same time, which back then looked like it might make an interesting modern alternative to FORTRAN for the numerical heavy lifting. Python is the one I chased here, and freshly: I'd just spent months up to my elbows in its scientific stack, so it was the obvious place to start.

<aside class="sidenote"><span class="sidenote__label">&bull; aside</span>The project is called `lsci` — "LFE scientific" — which I pronounce "Elsie." Every project deserves a name you can say out loud.</aside>

## Teaching LFE to speak NumPy

I started a project called `lsci` to be the scientific layer: an LFE wrapper for NumPy, SciPy, and — someday — matplotlib, all reached through ErlPort.

The part I'm happiest with is also the part with the least code in it, because I let the language write most of it for me. Rather than hand-wrap each NumPy function one at a time, I kept an arity table — a plain list of the array-creation routines and how many arguments each takes (`ones`, `zeros`, `eye`, `full`, `arange`, `linspace`, `meshgrid`, and the rest) — and a macro that walks that table at compile time and generates the ErlPort-calling wrapper for each entry. Adding a new NumPy function becomes a one-line edit to a table, not a new hand-written function. This is the kind of thing Lisps are quietly, unreasonably good at: the boilerplate writes itself, and the part you actually maintain is small enough to read in one sitting.

On the LFE side, a NumPy array comes back as an opaque handle — a reference you hold onto and keep passing back across the bridge for the next operation, rather than something you drag field-by-field into Erlang and back. You get the dot product of two arrays, an analog of Python's `array[key]` indexing, the array constructors above — all of it running in real NumPy, driven from parentheses.

## Plotting, and a confession

Of course, the whole reason a physicist reaches for this stuff is to *see* the numbers. So I wanted plotting — and here I have to tell on myself, because the dream and the delivery are not yet the same thing.

The dream is matplotlib, driven straight through the bridge: the very library I'd just written a book about, called from LFE. That is genuinely where this is headed, and in `lsci`'s own list of features, matplotlib sits under the plain heading "not started."

What actually works today is humbler and, I'll admit, more fun. The first plotting module renders line and scatter charts *in the terminal*, as ASCII, using ncurses. NumPy does the part it's good at — scaling the data and mapping it into the coordinate space — and then ncurses draws it, a `-` for a line, an `o` for a scatter point, right there in your shell. It is not going into anyone's publication. But there is something quietly delightful about a plot with no GUI at all, drawn in the same terminal where you started the REPL — IPython's spirit, minus every one of its windows. It was, all at once, a deliberate choice to stay native to the BEAM's no-frills world, a placeholder until matplotlib lands, and — let's be honest — a hack I enjoyed writing.

## The thing I didn't plan

I had set out to do *science* on the BEAM. But a few weeks in, building the machinery to run Python underneath `lsci`, it became clear that the machinery was the more valuable object. Running arbitrary Python from Erlang — reliably, under supervision — is useful to an enormous number of people who have no interest whatsoever in NumPy. The specific problem had grown a general tool inside it, and the general tool wanted its own life.

So I split it out. The bridge became its own project, `py` — "Distributed Python for the Erlang Ecosystem" — and `lsci` became just its first customer. And once the bridge stood on its own, I could give it the thing that makes the BEAM worth using in the first place: a proper OTP shape. `py` grew a real supervisor (`one_for_one`, restarting its Python worker if it dies), an application behaviour so it boots like any other OTP app, and a small scheduler so that several Python worker processes can sit behind one interface and share the load. That last piece is the one that makes me happiest: it means "call Python from Erlang" quietly becomes "call a *pool* of supervised Python workers from Erlang," which is a very different and much more Erlang-shaped promise. I cut it at version 0.0.2 on the 28th.

<aside class="sidenote"><span class="sidenote__label">&bull; aside</span>The lesson keeps re-teaching itself: the reusable thing is rarely the thing you set out to build. It's the thing you had to build in order to build the thing you set out to build.</aside>

## Where things stand

So at year's end: a bridge, `py`, that runs supervised, pooled Python under OTP and lets LFE call into it; a science library, `lsci`, sitting on top of it with NumPy's array machinery and a cheerful little ncurses plotter; and a long, inviting list of things not yet done — SciPy barely touched, matplotlib not started, and a dozen questions about how far the opaque-handle approach will scale before it groans. There is a great deal of road ahead. But the two runtimes are talking now, and that was the hard part.

I said this started as a question the book left me with — how much of scientific Python could live on the BEAM. The real answer, a month in, is: more than I expected, and by a more interesting route than I planned.

## Speaking of LFE

A couple of other things happened in LFE-land this month worth a nod, both in the spirit of making the language easier to live with.

The bigger one: LFE got its first Dockerfile. It's a modest thing — `FROM debian`, add the source, `make install`, and set the REPL as the default command — but it means you can now `docker run` your way into an LFE shell without installing a single thing on your host but Docker itself. Given that Docker only reached 1.0 back in June, this still feels a little like living in the future; ask me in a year whether it caught on. And a bit of housekeeping revival over in `lfest`, our little HTTP-routing library, which picked up a set of plain-text response helpers after a few quiet months.

Next time, I hope, with plots that have pixels.
