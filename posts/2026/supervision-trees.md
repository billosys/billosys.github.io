---
title: Supervision Trees Are a Philosophy, Not a Feature
description: Let-it-crash is not carelessness. It's a theory of where responsibility lives — enforced by the runtime rather than by anyone's good intentions.
published_date: 2026-06-18 09:00:00 -0600
tags:
  - erlang
  - otp
data:
  author: Duncan McGreggor
  minutes: 11
---
The first time you read a supervisor's `init/1`, it looks like configuration: a strategy, some intensity, a list of children. It reads like a YAML file that happens to be written in Erlang. That reading isn't wrong, exactly, but it misses the point so completely that people go on to build systems which technically use OTP and get almost none of its benefits.

<aside class="sidenote"><span class="sidenote__label">&bull; aside</span>"Configuration" and "declaration" look identical on the page. The difference is whether anything reads them at runtime and acts.</aside>

A supervisor is a claim about failure. It says: *these processes are my responsibility; when one of them dies in a way I don't understand, here is exactly what I will do about it, and here is how many times I'm willing to do it before I admit the problem is bigger than me and escalate to my own supervisor.*

## Where the responsibility lives

Consider a small ledger service. The worker holds the state; the supervisor holds a promise about that worker — nothing more, and nothing less.

```erlang
init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 10,
                 period => 60},
    Children = [#{id => ledger,
                  start => {ledger, start_link, []},
                  restart => permanent,
                  shutdown => 5000,
                  type => worker}],
    {ok, {SupFlags, Children}}.
```

Read `one_for_one` as a scope of blame. If the ledger crashes, restart the ledger and nothing else — because we have decided, in advance, that its failures are its own and not evidence that its siblings are also sick.

<aside class="sidenote"><span class="sidenote__label">&bull; strategies</span>Also `one_for_all` and `rest_for_one`, for children whose fates are genuinely linked.</aside>

> A crash is not an error to be prevented. It is a message about where a boundary should have been.

This is why "let it crash" is a philosophy and not a slogan. You aren't being cavalier about failure; you're being precise about it. You draw the supervision tree first, deciding where each kind of failure is allowed to stop, and only then do you write the code that runs inside those boundaries.
