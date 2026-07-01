---
title: "Consensus Without Ceremony: Raft in Anger"
description: The paper is elegant; production is not. Here is what leader election actually does when the network is having a genuinely bad day.
published_date: 2025-12-15 09:00:00 -0600
tags:
  - consensus
  - distributed-systems
data:
  author: Duncan McGregor
  minutes: 18
---
Raft is taught as a clean state machine: followers, candidates, a leader, and a term that only ever increases. In production the diagram is the same, but the transitions fire for reasons the paper politely abstracts away — a garbage-collection pause mistaken for a dead leader, a network partition that heals into two histories, a disk that fsyncs slower than the election timeout.

The value of Raft in anger is not that it prevents these events. It's that it gives you a small, testable vocabulary for reasoning about them after the fact. When the postmortem says "term 4,812 had two leaders for 900 milliseconds," you know exactly which invariant bent and where to look.
