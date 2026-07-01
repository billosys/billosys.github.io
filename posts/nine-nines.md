---
title: Nine Nines and the Cost of the Last One
description: Every additional nine is one decimal point away and an order of magnitude harder. The question is never whether you can afford it, but who pays.
published_date: 2026-05-09 09:00:00 -0600
tags:
  - reliability
  - distributed-systems
data:
  author: Duncan McGregor
  minutes: 9
---
Availability is quoted in nines because the decimal point is the honest unit. Three nines is a good year with a bad afternoon. Five nines is five minutes of downtime across the whole year — less than a single deploy gone wrong.

Each nine you add doesn't cost a little more; it costs an order of magnitude more, and it buys you an order of magnitude less slack. The interesting engineering question is not "can we hit it" but "who absorbs the cost when we don't" — the on-call engineer, the customer, or the balance sheet.

> Reliability is a budget, not a virtue. Spend it where a failure is unrecoverable, and let the rest degrade gracefully.
