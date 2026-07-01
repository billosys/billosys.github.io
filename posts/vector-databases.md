---
title: Vector Databases Are Just Indexes With Better Manners
description: Strip the marketing and a vector store is an index that has made peace with being approximately right. That peace is the whole engineering problem.
published_date: 2026-04-21 09:00:00 -0600
tags:
  - ai
  - infrastructure
data:
  author: Duncan McGregor
  minutes: 12
---
A vector database is an index. It answers "what is near this?" instead of "what equals this?", and it accepts being approximately right in exchange for answering at all at scale. Once you see it that way, the operational questions become familiar ones: recall versus latency, how the index is built, what happens when it's rebuilt under load.

The novelty is not the math. It's that the correctness contract is now probabilistic, and every layer above has to be honest about that. An approximate answer presented as an exact one is not a smaller bug — it's a category error you shipped.
