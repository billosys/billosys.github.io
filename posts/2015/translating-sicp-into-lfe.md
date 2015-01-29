---
title: "Translating SICP into LFE"
description: The Wizard Book is getting an LFE edition — why I'm porting Abelson and Sussman across, a paragraph at a time, what has to change on the way (procedures, for one), and what must never change.
published_date: 2015-01-28 21:12:00 -0600
tags:
  - lfe
  - sicp
  - lisp
  - books
is_draft: false
data:
  author: Duncan McGreggor
  math: false
---
Last year I finally read the book that people had been recommending to me, in one form or another, for most of my career: *Structure and Interpretation of Computer Programs*, by Harold Abelson and Gerald Jay Sussman with Julie Sussman. You likely know it by its other names — SICP, the Wizard Book — and you likely know at least one person who speaks of it the way climbers speak of a particular mountain. I had always nodded politely and kept it on the list.

I should not have waited. Working through it did something I did not expect: it was not so much that I learned new techniques — though I did — but that the book kept handing me *clarity*, section after section, about things I had been doing for twenty years. Clarity about programming, certainly. But more than that, clarity about analytical reasoning itself — how to take a problem apart, how to name the pieces, how to build a vocabulary of abstractions and then think *in* it. The gamer in me keeps describing the experience as a Draught of Intelligence +10. I drank it, and I have not been the same since.

And then came the itch that follows any experience like that: the scramble to share it. Here is the strange thing about SICP in our corner of the world — nearly every programmer I know has heard of it, most can quote its reputation, many have a friend who swears by it. Very few have read it. Some of that is time, but some of it is distance: the book speaks Scheme, and for a working Erlang programmer, Scheme is a language from another family, with other idioms, read in translation on a foreign VM. The material deserves better than "someday."

I had a precedent close at hand. In 2014 I had adapted Conrad Barski's *Casting SPELs in Lisp* for LFE, with Conrad's generous encouragement, and the online interactions around that little book taught me that adaptation is real work with real rewards — that carrying a text into your community's dialect is a way of *giving* it to them. And SICP, wonderfully, is a book that has been set free — via Creative Commons — its full text available online from MIT Press. The pieces sat next to each other for a while. Then, a couple of weeks ago, they clicked.

## So, the announcement

I am translating SICP into [LFE](http://lfe.io/), and you can read it as it grows: the book lives at [lfe.gitbooks.io/sicp](http://lfe.gitbooks.io/sicp/content/), with the source at [github.com/lfe/sicp](https://github.com/lfe/sicp). It is free, it always will be, and issues and pull requests are welcome — this is an LFE community project that happens to be flowing through my keyboard.

Work started on January 12th. I will confess the start was not measured: the first commit laid down the whole publishing skeleton — build tooling and cover art, with the front matter following the same day — and by the end of that first week I had made 197 commits against the repository. Not a typo. The book lit the same fire in me as a translator that it did as a reader, and the first week was a (barely) controlled burn. Chapter 1 is now nearly complete — everything through "Functions as Arguments" is translated, with the exercises — and three sections remain before I can turn to Chapter 2. This week has been quieter, which is why you are getting a blog post instead of commits.

## The method, such as it is

You might reasonably wonder whether there is tooling involved — some clever Scheme-to-LFE transpiler seeded with the original text. There is not. The method is embarrassingly medieval: I work from the [online edition](https://mitpress.mit.edu/sicp/) a paragraph at a time — read it, carry it across by hand, rewrite what needs rewriting, and convert every code example from Scheme into LFE. One Markdown file per section, exercises in their own files, GitBook builds it, and a small Makefile publishes it.

I chose the manual road on purpose. Translation-by-tool would preserve the words; the point is to preserve the *teaching*, and the teaching lives in details a tool would faithfully copy straight into wrongness — code that is idiomatic in Scheme and merely legal in LFE, terminology that meant one thing in 1985 Cambridge and means another on a mailing list today. Every paragraph gets asked: what are you *for*, and how do you do that job in this dialect? Mostly the answer is "exactly as written." The interesting cases are the rest.

## What changes in translation

### Procedures become functions

The first editorial decision arrived in the first week, and it is the one I expect to field the most mail about. SICP says *procedure*, everywhere and with precision — it is the book's word for the thing you define and apply. I am translating it as *function*.

The reason is simple: I want the book's vocabulary to be the vocabulary you actually live in. On the Erlang mailing lists, in the IRC channels, in the papers and the conference talks of our community, the things we define and apply are called functions. A reader who internalizes SICP's lessons in SICP's dialect and then walks into an Erlang code review has to carry a private dictionary in her head; I would rather she didn't have to. The terminology of the LFE edition should match what she will read and write every day.

I will be honest about two things. First, this is a judgment call, and the purists have a point they are welcome to make — Scheme's "procedure" was chosen carefully, precisely because those things are not mathematical functions. Second, the conversion is not yet complete: I made the call early — one of the chapter files was renamed for it in the first week — but earlier sections still carry stray "procedures" that I sweep out as I find them. If you spot one, you have found not an editorial position but a broom that hasn't reached that room yet. File an issue.

### The evaluation model comes first — and it differs

Translation gets interesting the moment SICP starts explaining how Lisp *evaluates*, because there the languages truly part ways. Where Scheme has `define` doing double duty for values and procedures, the LFE edition has to introduce the forms we really use — `set` for binding values in the REPL, `defun` for defining functions — so where the original writes `(define x 3)`, the LFE text teaches:

```lisp
(set x 3)
```

That looks like a cosmetic swap. It is not, quite — it changes the shape of the "special forms are exceptions to the evaluation rule" discussion that follows, and the LFE edition's version of that discussion now names the special forms an LFE programmer will meet first. Getting that section right mattered to me, because it is the book's first act of *model-building*: here is the simple rule, here are the marked exceptions, hold both. That move — build the model, then flag its limits — is the book's whole pedagogy in miniature, and it survives translation untouched.

<aside class="sidenote"><span class="sidenote__label">&bull; aside</span>The footnotes are coming across too, including Alan Perlis's "syntactic sugar causes cancer of the semicolon." Some things must never be lost in translation.</aside>

### Pattern matching, where LFE gets to show off

Then there are the places where the target language is not merely different but *better suited to the material*, and the translator's job is to resist false modesty. SICP's treatment of tree recursion builds on Fibonacci, which the original expresses with a `cond`. LFE inherits pattern matching from Erlang, so the cases move out of the body and into the heads of the function clauses:

```lisp
(defun fib
  ((0) 0)
  ((1) 1)
  ((n) (+ (fib (- n 1))
          (fib (- n 2)))))
```

The base cases and the recursive case are now *visually* the mathematical definition — three clauses, three lines of the recurrence. When the section then develops the iterative version, the state variables ride in the argument list and a guard (`(when (>= n 0))`) polices the domain. None of this changes Abelson and Sussman's argument about processes and their shapes; it renders the argument in a notation where, I would say, it lands harder. A Scheme reader sees the recurrence encoded; an LFE reader sees it *drawn*.

### And the parts that keep me honest

Lest that sound triumphal: the translation work is full of small humblings. Early on I caught myself writing `(defun (cube x) ...)` — a perfectly Scheme-shaped definition, and perfectly wrong in LFE, where it must be `(defun cube (x) ...)`. Twenty years of Lisp across half a dozen dialects, and the source text's accent still bleeds into my typing. Those fixes are in the commit history for anyone who wants a laugh; I am leaving them there. A translation whose seams were never visible is a translation you should trust less.

## What must not change

The temptation in any adaptation is to improve things, and it is mostly a temptation to be resisted. The book's spine — the substitution model, the slow deliberate build from combinations to abstractions to higher-order functions — is not mine to renovate. Neither are the exercises, which are where the book actually happens to you; Alyssa P. Hacker and Louis Reasoner keep their jobs in the LFE edition. When the "Functions as Arguments" section develops `sum-integers`, `sum-cubes`, and `pi-sum` and then asks you to *see* the template they share:

```lisp
(defun <name> (a b)
  (if (> a b)
      0
      (+ (<term> a)
         (<name> (<next> a) b))))
```

— that moment, where three concrete functions collapse into one abstraction and sigma notation walks in the door, is the reading experience I am trying to deliver intact. My changes are all in service of removing friction between you and that moment, never in service of my own cleverness. Where I do depart — modernizing an example here, aligning terminology there — the preface says so plainly, because a translation owes its reader a statement of its liberties.

And if Scheme is no obstacle for you, let me point you at the mountain itself: the [original](https://mitpress.mit.edu/sicp/) is free, and it is one of the finest books our field has produced. The LFE edition exists for the reader whose daily language lives on the BEAM, not to replace anything.

## Why LFE gets to do this

There is a deeper reason this project feels right, beyond one translator's enthusiasm. LFE — Robert Virding's Lisp, which he began sketching in 2007 and set flying on the Erlang VM in 2008 — sits at a junction that did not exist when SICP was written: a Lisp-2 with Scheme's teaching tradition at its back and OTP's industrial machinery under its feet. A book about building abstractions, running on the platform our industry uses to build systems that stay up. The reader who works through the LFE edition ends the book *already home*: the REPL she has been typing exercises into is an Erlang node, and the functions she has been abstracting are a module declaration away from living inside OTP. No second translation required.

Chapter 1 has three sections to go, and Chapter 2 — data abstraction, the part of the book where the wizardry gets structural — is waiting. I have also been spelunking in the prehistory of Lisp for the edition's preface, on the theory that a translated classic deserves to know its own lineage, and that research keeps unearthing things I did not expect; more on that another time.

The wizards wrote a book good enough to outlive its dialect. Carrying it to mine is the most fun I've had at a keyboard in years. Back to it.
